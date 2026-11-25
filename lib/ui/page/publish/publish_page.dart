import 'package:community_material_icon/community_material_icon.dart';
import 'package:cupertino_ui/cupertino_ui.dart' show CupertinoIcons;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:material_ui/material_ui.dart';

import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/data/entity/topic_tag.dart';
import 'package:flutter_nga/providers/settings/design_style_provider.dart';
import 'package:flutter_nga/ui/page/topic_detail/forum_tag_dialog.dart';
import 'package:flutter_nga/ui/widget/adaptive/app_icons.dart';
import 'package:flutter_nga/ui/widget/adaptive/app_scaffold.dart';
import 'package:flutter_nga/ui/widget/attachment_widget.dart';
import 'package:flutter_nga/ui/widget/emoticon_group_tabs_widget.dart';
import 'package:flutter_nga/ui/widget/font_style_widget.dart';
import 'package:flutter_nga/ui/widget/m3_dialog.dart';
import 'package:flutter_nga/ui/widget/readable_width.dart';
import 'package:flutter_nga/utils/app_toast.dart';
import 'package:flutter_nga/utils/code_utils.dart' as code_utils;
import 'package:flutter_nga/utils/dimen.dart';
import 'package:flutter_nga/utils/motion.dart';

enum _BottomPanel { emoticon, font, attachment }

class PublishPage extends HookWidget {
  const PublishPage({
    super.key,
    this.tid,
    this.fid,
    this.content,
    this.asDialog = false,
  });

  final int? tid;
  final int? fid;
  final String? content;

  /// 桌面端是否以居中模态弹窗形式展示（不占满全屏、不预留红绿灯安全区、顶栏展示关闭按钮）
  final bool asDialog;

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
    final submitting = useState(false);
    final pageRoute = ModalRoute.of(context);
    final hasAttachments = useState(false);

    // 标题、标签、附件有内容，或正文与带入的初始内容（引用 / 回复）不同，
    // 视为有未提交的编辑，返回前需要确认。
    final initialContent = content ?? "";
    final textEdited = useListenableSelector(
      Listenable.merge([subjectController, contentController]),
      () =>
          subjectController.text.trim().isNotEmpty ||
          (contentController.text != initialContent &&
              contentController.text.trim().isNotEmpty),
    );
    final hasEdits =
        textEdited || selectedTags.value.isNotEmpty || hasAttachments.value;

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
          selection.value = (start: selection.value.start, end: sel.end);
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
        contentController.text = "$left$startTag${hasEnd ? endTag : ""}$right";
        final position = left.length + (startTag.length as int);
        contentController.selection = TextSelection(
          extentOffset: position,
          baseOffset: position,
        );
      } else {
        final selected = text.substring(start, end);
        if (hasEnd) {
          contentController.text = "$left$startTag$selected$endTag$right";
          final position =
              left.length +
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
      hasAttachments.value = true;
    }

    Widget panelChild(_BottomPanel panel) => switch (panel) {
      _BottomPanel.emoticon => EmoticonGroupTabsWidget(callback: inputCallback),
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
          builder: (_) => _PanelDialog(title: title, child: panelChild(panel)),
        );
      } else {
        togglePanel(panel);
      }
    }

    void showTagDialog() {
      ForumTagDialog.show(
        context,
        fid: fid!,
        tagList: tagList.value,
        onSelected: (tag) {
          if (!selectedTags.value.contains(tag)) {
            selectedTags.value = [...selectedTags.value, tag];
          }
        },
        onLoadComplete: (list) => tagList.value = list,
      );
    }

    Future<void> publish() async {
      if (submitting.value) return;
      final body = contentController.text;
      final len = body.codeUnits.length;
      if (len < 6 || len > 65530) {
        AppToast.warning("内容过短或过长(6~65530 byte)");
        return;
      }
      submitting.value = true;
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
        // 提交期间可能打开了标签、面板等对话框，先关掉它们再关闭编辑页，
        // 避免只关掉对话框、内容留在页面上被再次提交。
        if (context.mounted) {
          final navigator = Navigator.of(context);
          if (pageRoute != null) navigator.popUntil((r) => r == pageRoute);
          navigator.pop(true);
        }
      } catch (err) {
        AppToast.error(err);
      } finally {
        if (context.mounted) submitting.value = false;
      }
    }

    Future<void> confirmDiscard() async {
      final discard = await showDialog<bool>(
        context: context,
        builder: (_) => const M3ConfirmDialog(
          title: '放弃编辑？',
          content: '已输入的内容不会保存。',
          cancelText: '继续编辑',
          confirmText: '放弃',
          destructive: true,
        ),
      );
      // Navigator.pop 不经过 PopScope 拦截，直接关闭页面。
      if (discard == true && context.mounted) Navigator.of(context).pop();
    }

    final bottomPadding = MediaQuery.paddingOf(context).bottom;
    final colorScheme = Theme.of(context).colorScheme;
    final isApple = context.isAppleStyle;
    final panelOpen = openPanel.value != null;
    final isMacOS = !kIsWeb && defaultTargetPlatform == TargetPlatform.macOS;
    final toolbarBg = isApple
        ? colorScheme.surfaceContainerLow
        : colorScheme.surfaceContainer;

    return PopScope(
      // 提交中不允许返回：请求结束后会自动关闭页面或恢复编辑。
      canPop: !submitting.value && !panelOpen && !hasEdits,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop || submitting.value) return;
        if (panelOpen) {
          openPanel.value = null;
        } else {
          confirmDiscard();
        }
      },
      child: CallbackShortcuts(
        bindings: {
          SingleActivator(
            LogicalKeyboardKey.enter,
            meta: isMacOS,
            control: !isMacOS,
          ): publish,
        },
        child: AppScaffold(
          embedded: asDialog,
          leading: asDialog
              ? IconButton(
                  tooltip: '关闭',
                  icon: Icon(AppIcons.close(context), size: 18),
                  onPressed: () => Navigator.of(context).maybePop(),
                )
              : null,
          title: Text(tid != null ? "回帖" : "发帖"),
          actions: [
            if (asDialog && !isApple)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilledButton.icon(
                  onPressed: submitting.value ? null : publish,
                  icon: submitting.value
                      ? const SizedBox.square(
                          dimension: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send, size: 16),
                  label: const Text('发送'),
                ),
              ),
          ],
          body: Column(
            children: [
              Expanded(
                child: ReadableWidth(
                  maxWidth: _contentMaxWidth,
                  child: isApple
                      ? _buildAppleEditor(
                          context,
                          subjectController: subjectController,
                          contentController: contentController,
                          selectedTags: selectedTags,
                          onShowTags: fid != null ? showTagDialog : null,
                        )
                      : _buildMaterialEditor(
                          subjectController: subjectController,
                          contentController: contentController,
                          selectedTags: selectedTags,
                          onShowTags: fid != null ? showTagDialog : null,
                        ),
                ),
              ),
              AnimatedSize(
                duration: Motion.resolveDuration(
                  context,
                  Motion.durationMedium2,
                ),
                curve: Motion.emphasized,
                alignment: Alignment.topCenter,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: double.infinity,
                      height:
                          (isApple && asDialog ? 44.0 : kToolbarHeight) +
                          (panelOpen ? 0 : bottomPadding),
                      padding: EdgeInsets.only(
                        bottom: panelOpen ? 0 : bottomPadding,
                      ),
                      decoration: BoxDecoration(
                        color: toolbarBg,
                        border: isApple
                            ? Border(
                                top: BorderSide(
                                  color: colorScheme.outlineVariant,
                                  width: 0.5,
                                ),
                              )
                            : null,
                      ),
                      child: ReadableWidth(
                        maxWidth: _contentMaxWidth,
                        alignment: Alignment.center,
                        child: isApple
                            ? _buildAppleToolbar(
                                context,
                                asDialog: asDialog,
                                isMacOS: isMacOS,
                                isAnonymous: isAnonymous.value,
                                openPanel: openPanel.value,
                                onToggleAnonymous: () {
                                  AppToast.info(
                                    isAnonymous.value ? "关闭匿名" : "开启匿名",
                                  );
                                  isAnonymous.value = !isAnonymous.value;
                                },
                                onOpenPanel: openPanelAction,
                              )
                            : Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  IconButton(
                                    tooltip: isAnonymous.value
                                        ? '关闭匿名'
                                        : '开启匿名',
                                    isSelected: isAnonymous.value,
                                    icon: const Icon(
                                      CommunityMaterialIcons.incognito_off,
                                    ),
                                    selectedIcon: const Icon(
                                      CommunityMaterialIcons.incognito,
                                    ),
                                    onPressed: () {
                                      AppToast.info(
                                        isAnonymous.value ? "关闭匿名" : "开启匿名",
                                      );
                                      isAnonymous.value = !isAnonymous.value;
                                    },
                                  ),
                                  IconButton(
                                    tooltip: '表情',
                                    isSelected:
                                        openPanel.value ==
                                        _BottomPanel.emoticon,
                                    icon: const Icon(
                                      CommunityMaterialIcons.emoticon,
                                    ),
                                    onPressed: () => openPanelAction(
                                      _BottomPanel.emoticon,
                                      '表情',
                                    ),
                                  ),
                                  IconButton(
                                    tooltip: '格式',
                                    isSelected:
                                        openPanel.value == _BottomPanel.font,
                                    icon: const Icon(
                                      CommunityMaterialIcons.format_text,
                                    ),
                                    onPressed: () => openPanelAction(
                                      _BottomPanel.font,
                                      '格式',
                                    ),
                                  ),
                                  IconButton(
                                    tooltip: '附件',
                                    isSelected:
                                        openPanel.value ==
                                        _BottomPanel.attachment,
                                    icon: const Icon(
                                      CommunityMaterialIcons.attachment,
                                    ),
                                    onPressed: () => openPanelAction(
                                      _BottomPanel.attachment,
                                      '附件',
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      color: toolbarBg,
                      height: panelOpen
                          ? Dimen.bottomPanelHeight + bottomPadding
                          : 0,
                      padding: EdgeInsets.only(
                        bottom: panelOpen ? bottomPadding : 0,
                      ),
                      child: panelOpen ? panelChild(openPanel.value!) : null,
                    ),
                  ],
                ),
              ),
            ],
          ),
          primaryAction: asDialog && !isApple
              ? null
              : AppPrimaryAction(
                  tooltip: '发送',
                  loading: submitting.value,
                  onPressed: publish,
                  icon: const Icon(Icons.send),
                  appleIcon: Icon(AppIcons.send(context)),
                  appleLabel: '发送',
                ),
        ),
      ),
    );
  }

  /// Apple / macOS Mail 风格的简洁编辑区：无框标题行 + 0.5pt 细分隔线 + 胶囊标签 + 纯净正文区。
  Widget _buildAppleEditor(
    BuildContext context, {
    required TextEditingController subjectController,
    required TextEditingController contentController,
    required ValueNotifier<List<String>> selectedTags,
    required VoidCallback? onShowTags,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final hintColor = colorScheme.onSurfaceVariant.withValues(alpha: 0.65);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 6, 10, 6),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  maxLines: 1,
                  controller: subjectController,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface,
                  ),
                  decoration: InputDecoration(
                    hintText: '标题(可选)',
                    hintStyle: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: hintColor,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: false,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  keyboardType: TextInputType.text,
                ),
              ),
              if (onShowTags != null)
                IconButton(
                  tooltip: '选择标签',
                  icon: Icon(
                    CupertinoIcons.tag,
                    size: 17,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  onPressed: onShowTags,
                ),
            ],
          ),
        ),
        if (selectedTags.value.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 8),
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final tag in selectedTags.value)
                  Container(
                    padding: const EdgeInsets.fromLTRB(10, 4, 6, 4),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          tag,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () {
                            selectedTags.value = selectedTags.value
                                .where((t) => t != tag)
                                .toList();
                          },
                          child: Icon(
                            CupertinoIcons.xmark,
                            size: 12,
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        Divider(height: 0.5, thickness: 0.5, color: colorScheme.outlineVariant),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 14),
            child: TextField(
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              controller: contentController,
              style: TextStyle(
                fontSize: 14.5,
                height: 1.55,
                color: colorScheme.onSurface,
              ),
              decoration: InputDecoration(
                hintText: '回复内容',
                hintStyle: TextStyle(fontSize: 14.5, color: hintColor),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              keyboardType: TextInputType.multiline,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMaterialEditor({
    required TextEditingController subjectController,
    required TextEditingController contentController,
    required ValueNotifier<List<String>> selectedTags,
    required VoidCallback? onShowTags,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        children: [
          TextField(
            maxLines: 1,
            controller: subjectController,
            decoration: InputDecoration(
              labelText: "标题(可选)",
              suffixIcon: onShowTags != null
                  ? IconButton(
                      tooltip: '选择标签',
                      icon: const Icon(CommunityMaterialIcons.tag_multiple),
                      onPressed: onShowTags,
                    )
                  : null,
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
    );
  }

  /// Apple 风格底部工具栏：SF Symbols 图标；桌面弹窗内左侧紧凑排列工具并附带「匿名」胶囊和快捷键提示。
  Widget _buildAppleToolbar(
    BuildContext context, {
    required bool asDialog,
    required bool isMacOS,
    required bool isAnonymous,
    required _BottomPanel? openPanel,
    required VoidCallback onToggleAnonymous,
    required void Function(_BottomPanel panel, String title) onOpenPanel,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final inactiveColor = colorScheme.onSurfaceVariant;

    Widget toolButton({
      required String tooltip,
      required IconData icon,
      required bool selected,
      required VoidCallback onPressed,
    }) {
      return IconButton(
        tooltip: tooltip,
        isSelected: selected,
        icon: Icon(
          icon,
          size: asDialog ? 17 : 20,
          color: selected ? colorScheme.primary : inactiveColor,
        ),
        onPressed: onPressed,
      );
    }

    if (!asDialog) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          toolButton(
            tooltip: isAnonymous ? '关闭匿名' : '开启匿名',
            icon: isAnonymous
                ? CupertinoIcons.eye_slash_fill
                : CupertinoIcons.eye_slash,
            selected: isAnonymous,
            onPressed: onToggleAnonymous,
          ),
          toolButton(
            tooltip: '表情',
            icon: CupertinoIcons.smiley,
            selected: openPanel == _BottomPanel.emoticon,
            onPressed: () => onOpenPanel(_BottomPanel.emoticon, '表情'),
          ),
          toolButton(
            tooltip: '格式',
            icon: CupertinoIcons.textformat,
            selected: openPanel == _BottomPanel.font,
            onPressed: () => onOpenPanel(_BottomPanel.font, '格式'),
          ),
          toolButton(
            tooltip: '附件',
            icon: CupertinoIcons.paperclip,
            selected: openPanel == _BottomPanel.attachment,
            onPressed: () => onOpenPanel(_BottomPanel.attachment, '附件'),
          ),
        ],
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          toolButton(
            tooltip: '表情',
            icon: CupertinoIcons.smiley,
            selected: openPanel == _BottomPanel.emoticon,
            onPressed: () => onOpenPanel(_BottomPanel.emoticon, '表情'),
          ),
          toolButton(
            tooltip: '格式',
            icon: CupertinoIcons.textformat,
            selected: openPanel == _BottomPanel.font,
            onPressed: () => onOpenPanel(_BottomPanel.font, '格式'),
          ),
          toolButton(
            tooltip: '附件',
            icon: CupertinoIcons.paperclip,
            selected: openPanel == _BottomPanel.attachment,
            onPressed: () => onOpenPanel(_BottomPanel.attachment, '附件'),
          ),
          const SizedBox(width: 6),
          Tooltip(
            message: isAnonymous ? '关闭匿名' : '开启匿名',
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: onToggleAnonymous,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 140),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isAnonymous
                      ? colorScheme.primary.withValues(alpha: 0.14)
                      : colorScheme.onSurfaceVariant.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isAnonymous
                          ? CupertinoIcons.eye_slash_fill
                          : CupertinoIcons.eye_slash,
                      size: 13,
                      color: isAnonymous ? colorScheme.primary : inactiveColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '匿名',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isAnonymous
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: isAnonymous
                            ? colorScheme.primary
                            : inactiveColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Spacer(),
          Text(
            isMacOS ? '⌘↵ 发送' : 'Ctrl+Enter 发送',
            style: TextStyle(
              fontSize: 11.5,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(width: 6),
        ],
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
    final colorScheme = Theme.of(context).colorScheme;
    final isApple = context.isAppleStyle;

    if (isApple) {
      return Dialog(
        backgroundColor: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: colorScheme.outlineVariant, width: 0.5),
            ),
            child: SizedBox(
              width: 540,
              height: 400,
              child: Column(
                children: [
                  SizedBox(
                    height: 44,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 8, 0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: '关闭',
                            icon: Icon(
                              CupertinoIcons.xmark,
                              size: 16,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Divider(
                    height: 0.5,
                    thickness: 0.5,
                    color: colorScheme.outlineVariant,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: child,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

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
                  Expanded(child: Text(title, style: textTheme.titleMedium)),
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
