import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/data/entity/topic_tag.dart';
import 'package:flutter_nga/ui/page/topic_detail/forum_tag_dialog.dart';
import 'package:flutter_nga/ui/widget/attachment_widget.dart';
import 'package:flutter_nga/ui/widget/emoticon_group_tabs_widget.dart';
import 'package:flutter_nga/ui/widget/font_style_widget.dart';
import 'package:flutter_nga/utils/code_utils.dart' as code_utils;
import 'package:flutter_nga/utils/dimen.dart';
import 'package:flutter_nga/utils/motion.dart';
import 'package:flutter_nga/utils/route.dart';
import 'package:flutter_nga/utils/app_toast.dart';

enum _BottomPanel { emoticon, font, attachment }

class PublishPage extends HookWidget {
  const PublishPage({
    super.key,
    this.tid,
    this.fid,
    this.content,
  });

  final int? tid;
  final int? fid;
  final String? content;

  /// 宽屏断点：大于此宽度时面板以对话框形式展示
  static const double _wideBreakpoint = 600;

  /// 宽屏下编辑区域最大宽度
  static const double _contentMaxWidth = 720;

  @override
  Widget build(BuildContext context) {
    final subjectController = useTextEditingController();
    final contentController = useTextEditingController(text: content ?? "");
    final isAnonymous = useState(false);
    final openPanel = useState<_BottomPanel?>(null);
    final selectedTags = useState(<String>[]);
    final tagList = useRef(<TopicTag>[]);
    final selection = useRef((start: 0, end: 0));
    final attachments = useRef(StringBuffer());
    final attachmentsCheck = useRef(StringBuffer());
    final wasKeyboardVisible = useRef(false);

    final keyboardVisible = MediaQuery.viewInsetsOf(context).bottom > 0;
    final isWide = MediaQuery.sizeOf(context).width >= _wideBreakpoint;

    // 键盘弹出时收起底部面板
    if (keyboardVisible &&
        !wasKeyboardVisible.value &&
        openPanel.value != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        openPanel.value = null;
      });
    }
    wasKeyboardVisible.value = keyboardVisible;

    useEffect(() {
      void listener() {
        final sel = contentController.selection;
        if (sel.start > -1) {
          selection.value = (
            start: sel.start,
            end: sel.end > -1 ? sel.end : selection.value.end,
          );
        }
        if (sel.end > -1) {
          selection.value = (
            start: selection.value.start,
            end: sel.end,
          );
        }
      }

      contentController.addListener(listener);
      return () => contentController.removeListener(listener);
    }, [contentController]);

    void inputCallback(startTag, endTag, hasEnd) {
      final start = selection.value.start;
      final end = selection.value.end;
      final text = contentController.text;
      final left = text.substring(0, start);
      final right = text.substring(end, text.length);
      if (start == end) {
        contentController.text =
            "$left$startTag${hasEnd ? endTag : ""}$right";
        final position = left.length + (startTag.length as int);
        contentController.selection = TextSelection(
          extentOffset: position,
          baseOffset: position,
        );
      } else {
        final selected = text.substring(start, end);
        if (hasEnd) {
          contentController.text = "$left$startTag$selected$endTag$right";
          final position = left.length +
              (startTag.length as int) +
              selected.length +
              (endTag.length as int);
          contentController.selection = TextSelection(
            extentOffset: position,
            baseOffset: position,
          );
        } else {
          contentController.text = "$left$startTag$right";
          final position = left.length + (startTag.length as int);
          contentController.selection = TextSelection(
            extentOffset: position,
            baseOffset: position,
          );
        }
      }
    }

    void attachmentCallback(att, attCheck) {
      final tab = code_utils.urlEncode("\t");
      attachments.value.write(tab);
      attachments.value.write(code_utils.urlEncode(att));
      attachmentsCheck.value.write(tab);
      attachmentsCheck.value.write(code_utils.urlEncode(attCheck));
    }

    Widget panelChild(_BottomPanel panel) => switch (panel) {
          _BottomPanel.emoticon =>
            EmoticonGroupTabsWidget(callback: inputCallback),
          _BottomPanel.font => FontStyleWidget(callback: inputCallback),
          _BottomPanel.attachment => AttachmentWidget(
              tid: tid,
              fid: fid,
              callback: inputCallback,
              attachmentCallback: attachmentCallback,
            ),
        };

    void togglePanel(_BottomPanel panel) {
      if (keyboardVisible) {
        SystemChannels.textInput.invokeMethod('TextInput.hide');
      }
      if (openPanel.value == panel) {
        openPanel.value = null;
      } else {
        openPanel.value = panel;
      }
    }

    void openPanelAction(_BottomPanel panel, String title) {
      if (isWide) {
        showDialog(
          context: context,
          builder: (_) => _PanelDialog(
            title: title,
            child: panelChild(panel),
          ),
        );
      } else {
        togglePanel(panel);
      }
    }

    void showTagDialog() {
      showDialog(
        context: context,
        builder: (dialogContext) {
          return ForumTagDialog(
            fid: fid!,
            tagList: tagList.value,
            onSelected: (tag) {
              if (!selectedTags.value.contains(tag)) {
                selectedTags.value = [...selectedTags.value, tag];
              }
              Routes.pop(dialogContext);
            },
            onLoadComplete: (list) => tagList.value = list,
          );
        },
      );
    }

    Future<void> publish() async {
      final body = contentController.text;
      final len = body.codeUnits.length;
      if (len < 6 || len > 65530) {
        AppToast.warning("内容过短或过长(6~65530 byte)");
        return;
      }
      try {
        final String message;
        if (tid != null) {
          message = await Data().topicRepository.createReply(
            tid,
            fid,
            subjectController.text,
            body,
            isAnonymous.value,
            attachments.value.toString(),
            attachmentsCheck.value.toString(),
          );
        } else if (fid != null) {
          message = await Data().topicRepository.createTopic(
            fid,
            subjectController.text,
            body,
            isAnonymous.value,
            attachments.value.toString(),
            attachmentsCheck.value.toString(),
          );
        } else {
          return;
        }
        AppToast.success(message);
        if (context.mounted) Routes.pop(context);
      } catch (err) {
        AppToast.error(err);
      }
    }

    final bottomPadding = MediaQuery.paddingOf(context).bottom;
    final colorScheme = Theme.of(context).colorScheme;
    final panelOpen = openPanel.value != null;

    return PopScope(
      canPop: !panelOpen,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (panelOpen) openPanel.value = null;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(tid != null ? "回帖" : "发帖"),
        ),
        body: Column(
          children: [
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints:
                      const BoxConstraints(maxWidth: _contentMaxWidth),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: Column(
                      children: [
                        TextField(
                          maxLines: 1,
                          controller: subjectController,
                          decoration: InputDecoration(
                            labelText: "标题(可选)",
                            suffixIcon: IconButton(
                              tooltip: '选择标签',
                              icon: const Icon(
                                  CommunityMaterialIcons.tag_multiple),
                              onPressed: showTagDialog,
                            ),
                          ),
                          keyboardType: TextInputType.text,
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: Wrap(
                            spacing: 8.0,
                            runSpacing: 4.0,
                            children: selectedTags.value.map((tag) {
                              return InputChip(
                                label: Text(tag),
                                onDeleted: () {
                                  selectedTags.value = selectedTags.value
                                      .where((t) => t != tag)
                                      .toList();
                                },
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: TextField(
                            maxLines: null,
                            expands: true,
                            textAlignVertical: TextAlignVertical.top,
                            controller: contentController,
                            decoration: const InputDecoration(
                              labelText: "回复内容",
                              alignLabelWithHint: true,
                            ),
                            keyboardType: TextInputType.multiline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            AnimatedSize(
              duration: Motion.durationMedium2,
              curve: Motion.emphasized,
              alignment: Alignment.topCenter,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: double.infinity,
                    height: kToolbarHeight + (panelOpen ? 0 : bottomPadding),
                    padding: EdgeInsets.only(
                        bottom: panelOpen ? 0 : bottomPadding),
                    color: colorScheme.surfaceContainer,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          tooltip: isAnonymous.value ? '关闭匿名' : '开启匿名',
                          isSelected: isAnonymous.value,
                          icon: const Icon(CommunityMaterialIcons.incognito_off),
                          selectedIcon:
                              const Icon(CommunityMaterialIcons.incognito),
                          onPressed: () {
                            AppToast.info(
                                isAnonymous.value ? "关闭匿名" : "开启匿名");
                            isAnonymous.value = !isAnonymous.value;
                          },
                        ),
                        IconButton(
                          tooltip: '表情',
                          isSelected:
                              openPanel.value == _BottomPanel.emoticon,
                          icon: const Icon(CommunityMaterialIcons.emoticon),
                          onPressed: () =>
                              openPanelAction(_BottomPanel.emoticon, '表情'),
                        ),
                        IconButton(
                          tooltip: '格式',
                          isSelected: openPanel.value == _BottomPanel.font,
                          icon:
                              const Icon(CommunityMaterialIcons.format_text),
                          onPressed: () =>
                              openPanelAction(_BottomPanel.font, '格式'),
                        ),
                        IconButton(
                          tooltip: '附件',
                          isSelected:
                              openPanel.value == _BottomPanel.attachment,
                          icon:
                              const Icon(CommunityMaterialIcons.attachment),
                          onPressed: () => openPanelAction(
                              _BottomPanel.attachment, '附件'),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    color: colorScheme.surfaceContainer,
                    height: panelOpen
                        ? Dimen.bottomPanelHeight + bottomPadding
                        : 0,
                    padding: EdgeInsets.only(
                        bottom: panelOpen ? bottomPadding : 0),
                    child: panelOpen
                        ? panelChild(openPanel.value!)
                        : null,
                  ),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          tooltip: '发送',
          onPressed: publish,
          child: const Icon(Icons.send),
        ),
      ),
    );
  }
}

/// 宽屏下面板（表情/格式/附件）的居中对话框容器
class _PanelDialog extends StatelessWidget {
  final String title;
  final Widget child;

  const _PanelDialog({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Dialog(
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: 560,
        height: 420,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 8, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(title, style: textTheme.titleMedium),
                  ),
                  IconButton(
                    tooltip: '关闭',
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
