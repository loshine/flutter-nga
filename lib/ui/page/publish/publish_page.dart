import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/data/entity/topic_tag.dart';
import 'package:flutter_nga/ui/page/topic_detail/forum_tag_dialog.dart';
import 'package:flutter_nga/ui/widget/attachment_widget.dart';
import 'package:flutter_nga/ui/widget/emoticon_group_tabs_widget.dart';
import 'package:flutter_nga/ui/widget/font_style_widget.dart';
import 'package:flutter_nga/utils/code_utils.dart' as codeUtils;
import 'package:flutter_nga/utils/dimen.dart';
import 'package:flutter_nga/utils/route.dart';
import 'package:fluttertoast/fluttertoast.dart';

class PublishPage extends StatefulWidget {
  const PublishPage({
    this.tid,
    this.fid,
    this.content,
    Key? key,
  }) : super(key: key);

  final int? tid;
  final int? fid;
  final String? content;

  @override
  _PublishPageState createState() => _PublishPageState();
}

class _PublishPageState extends State<PublishPage> {
  final _bottomData = [
    CommunityMaterialIcons.incognito_off,
    CommunityMaterialIcons.emoticon,
    CommunityMaterialIcons.format_text,
    CommunityMaterialIcons.attachment,
  ];

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

  StringBuffer _attachments = StringBuffer();
  StringBuffer _attachmentsCheck = StringBuffer();

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
          actions: [
            IconButton(
              icon: Icon(Icons.send),
              onPressed: _publish,
            ),
          ],
        ),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              children: [
                TextField(
                  maxLines: 1,
                  controller: _subjectController,
                  decoration: InputDecoration(
                    labelText: "标题(可选)",
                    suffixIcon: InkWell(
                      child: Icon(
                        CommunityMaterialIcons.tag_multiple,
                        color: Theme.of(context).iconTheme.color,
                      ),
                      onTap: _showTagDialog,
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
                Expanded(
                  child: TextField(
                    maxLines: null,
                    controller: _contentController,
                    decoration: InputDecoration(
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
        SizedBox(
          height: _bottomPanelVisible
              ? Dimen.bottomPanelHeight + kToolbarHeight
              : kToolbarHeight,
          child: Column(
            children: [
              Container(
                color: Theme.of(context).primaryColor,
                height: kToolbarHeight,
                width: double.infinity,
                child: Row(children: _getBottomBarData()),
              ),
              Container(
                color: Theme.of(context).colorScheme.surfaceContainer,
                width: double.infinity,
                height: _bottomPanelVisible ? Dimen.bottomPanelHeight : 0,
                child: _currentBottomPanelChild,
              )
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _getBottomBarData() {
    return _bottomData
        .asMap()
        .map((i, iconData) {
          return MapEntry(
            i,
            Expanded(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  child: Container(
                    height: kToolbarHeight,
                    child: Icon(
                      i == 0
                          ? (_isAnonymous
                              ? CommunityMaterialIcons.incognito
                              : iconData)
                          : iconData,
                      color: Colors.white,
                    ),
                  ),
                  onTap: () {
                    if (i == 0) {
                      _incognitoIconClicked();
                    } else if (i == 1) {
                      _emoticonIconClicked();
                    } else if (i == 2) {
                      _formatTextIconClicked();
                    } else if (i == 3) {
                      _attachmentIconClicked();
                    }
                  },
                ),
              ),
            ),
          );
        })
        .values
        .toList();
  }

  void _hideBottomPanel() {
    setState(() {
      _bottomPanelVisible = false;
    });
  }

  void _incognitoIconClicked() {
    Fluttertoast.showToast(
      msg: _isAnonymous ? "关闭匿名" : "开启匿名",
    );
    setState(() {
      _isAnonymous = !_isAnonymous;
    });
  }

  void _emoticonIconClicked() {
    togglePanel(_emoticonGroupTabsWidget);
  }

  void _formatTextIconClicked() {
    togglePanel(_fontStyleWidget);
  }

  void _attachmentIconClicked() {
    togglePanel(_attachmentWidget);
  }

  void togglePanel(Widget widget) {
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
    final tab = codeUtils.urlEncode("\t");
    _attachments.write(tab);
    _attachments.write(codeUtils.urlEncode(attachments));
    _attachmentsCheck.write(tab);
    _attachmentsCheck.write(codeUtils.urlEncode(attachmentsCheck));
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
      Fluttertoast.showToast(msg: "内容过短或过长(6~65530 byte)");
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
        Fluttertoast.showToast(
          msg: message,
        );
        Routes.pop(context);
      } catch (err) {
        Fluttertoast.showToast(
          msg: err.toString(),
        );
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
        Fluttertoast.showToast(
          msg: message,
        );
        Routes.pop(context);
      } catch (err) {
        Fluttertoast.showToast(
          msg: err.toString(),
        );
      }
    }
  }
}
