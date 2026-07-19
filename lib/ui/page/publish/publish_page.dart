import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class PublishPage extends StatefulWidget {
  const PublishPage({
    super.key,
    this.tid,
    this.fid,
    this.content,
  });

  final int? tid;
  final int? fid;
  final String? content;

  @override
  _PublishPageState createState() => _PublishPageState();
}

class _PublishPageState extends State<PublishPage> {
  /// 宽屏断点：大于此宽度时面板以对话框形式展示
  static const double _wideBreakpoint = 600;

  /// 宽屏下编辑区域最大宽度
  static const double _contentMaxWidth = 720;

  bool _keyboardVisible = false;
  bool _bottomPanelVisible = false;
  bool _isAnonymous = false;

  List<String> _selectedTags = [];
  List<TopicTag> _tagList = [];

  final _subjectController = TextEditingController();
  final _contentController = TextEditingController();

  late Widget _emoticonGroupTabsWidget;
  late Widget _fontStyleWidget;
  late Widget _attachmentWidget;

  late Widget _currentBottomPanelChild;
  final _selectionList = [0, 0];

  final StringBuffer _attachments = StringBuffer();
  final StringBuffer _attachmentsCheck = StringBuffer();

  bool get _isWide =>
      MediaQuery.sizeOf(context).width >= _wideBreakpoint;

  @override
  void initState() {
    super.initState();
    _contentController.text = widget.content ?? "";
    _contentController.addListener(() {
      if (_contentController.selection.start > -1) {
        _selectionList[0] = _contentController.selection.start;
      }
      if (_contentController.selection.end > -1) {
        _selectionList[1] = _contentController.selection.end;
      }
    });
    _emoticonGroupTabsWidget =
        EmoticonGroupTabsWidget(callback: _inputCallback);
    _fontStyleWidget = FontStyleWidget(callback: _inputCallback);
    _attachmentWidget = AttachmentWidget(
      tid: widget.tid,
      fid: widget.fid,
      callback: _inputCallback,
      attachmentCallback: _attachmentCallback,
    );
    _currentBottomPanelChild = _emoticonGroupTabsWidget;
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _onKeyboardVisibilityChanged(bool visible) {
    setState(() {
      _keyboardVisible = visible;
    });
    if (visible && _bottomPanelVisible) {
      _hideBottomPanel();
    }
  }

  @override
  Widget build(BuildContext context) {
    // 使用 MediaQuery 检测键盘
    final keyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;
    if (keyboardVisible != _keyboardVisible) {
      _onKeyboardVisibilityChanged(keyboardVisible);
    }
    return PopScope(
      canPop: !_bottomPanelVisible,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_bottomPanelVisible) {
          _hideBottomPanel();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.tid != null ? "回帖" : "发帖"),
        ),
        body: _buildBody(),
        floatingActionButton: FloatingActionButton(
          tooltip: '发送',
          onPressed: _publish,
          child: const Icon(Icons.send),
        ),
      ),
    );
  }

  Widget _buildBody() {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        // 编辑区域：宽屏下限制最大宽度并居中
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
                      controller: _subjectController,
                      decoration: InputDecoration(
                        labelText: "标题(可选)",
                        suffixIcon: IconButton(
                          tooltip: '选择标签',
                          icon: const Icon(
                              CommunityMaterialIcons.tag_multiple),
                          onPressed: _showTagDialog,
                        ),
                      ),
                      keyboardType: TextInputType.text,
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: Wrap(
                        spacing: 8.0, // gap between adjacent chips
                        runSpacing: 4.0, // gap between line
                        children: _selectedTags.map((content) {
                          return InputChip(
                            label: Text(content),
                            onDeleted: () {
                              setState(() {
                                _selectedTags.remove(content);
                              });
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
                        controller: _contentController,
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
        // 底部工具栏 + 面板（窄屏），整体高度动画
        AnimatedSize(
          duration: Motion.durationMedium2,
          curve: Motion.emphasized,
          alignment: Alignment.topCenter,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildToolbar(bottomPadding),
              Container(
                width: double.infinity,
                color: colorScheme.surfaceContainer,
                height: _bottomPanelVisible
                    ? Dimen.bottomPanelHeight + bottomPadding
                    : 0,
                padding: EdgeInsets.only(
                    bottom: _bottomPanelVisible ? bottomPadding : 0),
                child:
                    _bottomPanelVisible ? _currentBottomPanelChild : null,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// M3 风格工具栏：tonal 背景 + IconButton 选中态
  Widget _buildToolbar(double bottomPadding) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      height:
          kToolbarHeight + (_bottomPanelVisible ? 0 : bottomPadding),
      padding:
          EdgeInsets.only(bottom: _bottomPanelVisible ? 0 : bottomPadding),
      color: colorScheme.surfaceContainer,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            tooltip: _isAnonymous ? '关闭匿名' : '开启匿名',
            isSelected: _isAnonymous,
            icon: const Icon(CommunityMaterialIcons.incognito_off),
            selectedIcon: const Icon(CommunityMaterialIcons.incognito),
            onPressed: _incognitoIconClicked,
          ),
          IconButton(
            tooltip: '表情',
            isSelected: _bottomPanelVisible &&
                _currentBottomPanelChild == _emoticonGroupTabsWidget,
            icon: const Icon(CommunityMaterialIcons.emoticon),
            onPressed: () =>
                _openPanel(_emoticonGroupTabsWidget, '表情'),
          ),
          IconButton(
            tooltip: '格式',
            isSelected: _bottomPanelVisible &&
                _currentBottomPanelChild == _fontStyleWidget,
            icon: const Icon(CommunityMaterialIcons.format_text),
            onPressed: () => _openPanel(_fontStyleWidget, '格式'),
          ),
          IconButton(
            tooltip: '附件',
            isSelected: _bottomPanelVisible &&
                _currentBottomPanelChild == _attachmentWidget,
            icon: const Icon(CommunityMaterialIcons.attachment),
            onPressed: () => _openPanel(_attachmentWidget, '附件'),
          ),
        ],
      ),
    );
  }

  /// 窄屏从底部弹出面板，宽屏以居中对话框展示
  void _openPanel(Widget child, String title) {
    if (_isWide) {
      showDialog(
        context: context,
        builder: (_) => _PanelDialog(title: title, child: child),
      );
    } else {
      _togglePanel(child);
    }
  }

  void _hideBottomPanel() {
    setState(() {
      _bottomPanelVisible = false;
    });
  }

  void _incognitoIconClicked() {
    AppToast.info(_isAnonymous ? "关闭匿名" : "开启匿名");
    setState(() {
      _isAnonymous = !_isAnonymous;
    });
  }

  void _togglePanel(Widget widget) {
    if (_keyboardVisible) {
      SystemChannels.textInput.invokeMethod('TextInput.hide');
    }
    setState(() {
      if (_currentBottomPanelChild == widget && _bottomPanelVisible) {
        _bottomPanelVisible = false;
      } else {
        _currentBottomPanelChild = widget;
        _bottomPanelVisible = true;
      }
    });
  }

  void _inputCallback(startTag, endTag, hasEnd) {
    final leftPartString =
        _contentController.text.substring(0, _selectionList[0]);
    final rightPartString = _contentController.text
        .substring(_selectionList[1], _contentController.text.length);
    if (_selectionList[0] == _selectionList[1]) {
      // 未选中词语
      _contentController.text =
          "$leftPartString$startTag${hasEnd ? endTag : ""}$rightPartString";
      int position = leftPartString.length + (startTag.length as int);
      _contentController.selection = TextSelection(
        extentOffset: position,
        baseOffset: position,
      );
    } else {
      // 选中了词语
      final selectionString = _contentController.text
          .substring(_selectionList[0], _selectionList[1]);
      if (hasEnd) {
        _contentController.text =
            "$leftPartString$startTag$selectionString$endTag$rightPartString";
        int position = leftPartString.length +
            (startTag.length as int) +
            selectionString.length +
            (endTag.length as int);
        _contentController.selection = TextSelection(
          extentOffset: position,
          baseOffset: position,
        );
      } else {
        _contentController.text = "$leftPartString$startTag$rightPartString";
        int position = leftPartString.length + (startTag.length as int);
        _contentController.selection = TextSelection(
          extentOffset: position,
          baseOffset: position,
        );
      }
    }
  }

  void _attachmentCallback(attachments, attachmentsCheck) async {
    final tab = code_utils.urlEncode("\t");
    _attachments.write(tab);
    _attachments.write(code_utils.urlEncode(attachments));
    _attachmentsCheck.write(tab);
    _attachmentsCheck.write(code_utils.urlEncode(attachmentsCheck));
  }

  void _showTagDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return ForumTagDialog(
          fid: widget.fid!,
          tagList: _tagList,
          onSelected: (tag) {
            if (!_selectedTags.contains(tag)) {
              setState(() {
                _selectedTags.add(tag);
              });
            }
            Routes.pop(context);
          },
          onLoadComplete: (list) => _tagList = list,
        );
      },
    );
  }

  void _publish() async {
    final content = _contentController.text;
    final len = content.codeUnits.length;
    if (len < 6 || len > 65530) {
      AppToast.warning("内容过短或过长(6~65530 byte)");
      return;
    }
    if (widget.tid != null) {
      try {
        String message = await Data().topicRepository.createReply(
            widget.tid,
            widget.fid,
            _subjectController.text,
            content,
            _isAnonymous,
            _attachments.toString(),
            _attachmentsCheck.toString());
        AppToast.success(message);
        Routes.pop(context);
      } catch (err) {
        AppToast.error(err.toString());
      }
    } else if (widget.fid != null) {
      try {
        String message = await Data().topicRepository.createTopic(
            widget.fid,
            _subjectController.text,
            content,
            _isAnonymous,
            _attachments.toString(),
            _attachmentsCheck.toString());
        AppToast.success(message);
        Routes.pop(context);
      } catch (err) {
        AppToast.error(err.toString());
      }
    }
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
