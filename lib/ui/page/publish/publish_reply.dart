import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/data/entity/topic.dart';
import 'package:flutter_nga/plugins/android_gbk.dart';
import 'package:flutter_nga/ui/widget/attachment_widget.dart';
import 'package:flutter_nga/ui/widget/emoticon_group_tabs_widget.dart';
import 'package:flutter_nga/ui/widget/font_style_widget.dart';
import 'package:flutter_nga/ui/widget/forum_tag_dialog.dart';
import 'package:flutter_nga/utils/dimen.dart';
import 'package:flutter_nga/utils/palette.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';

class PublishPage extends StatefulWidget {
  const PublishPage({
    this.topic,
    this.fid,
    Key key,
  }) : super(key: key);

  final Topic topic;
  final int fid;

  @override
  _PublishReplyState createState() => _PublishReplyState();
}

class _PublishReplyState extends State<PublishPage> {
  final _bottomData = [
    CommunityMaterialIcons.ninja,
    CommunityMaterialIcons.emoticon,
    CommunityMaterialIcons.format_text,
    CommunityMaterialIcons.attachment,
  ];

  bool _keyboardVisible = false;
  bool _bottomPanelVisible = false;
  bool _isAnonymous = false;

  List<String> _tagList = [];

  final _subjectController = TextEditingController();
  final _contentController = TextEditingController();

  Widget _emoticonGroupTabsWidget;
  Widget _fontStyleWidget;
  Widget _attachmentWidget;

  Widget _currentBottomPanelChild;
  final _selectionList = [0, 0];

  StringBuffer _attachments = StringBuffer();
  StringBuffer _attachmentsCheck = StringBuffer();

  @override
  void initState() {
    super.initState();
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
      topic: widget.topic,
      callback: _inputCallback,
      attachmentCallback: _attachmentCallback,
    );
    _currentBottomPanelChild = _emoticonGroupTabsWidget;
    KeyboardVisibilityNotification().addNewListener(
      onChange: (bool visible) {
        // called when the keyboard visibility changes
        _keyboardVisible = visible;
        if (visible && _bottomPanelVisible) {
          _hideBottomPanel();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_bottomPanelVisible) {
          _hideBottomPanel();
          return false;
        } else {
          return true;
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("回帖"),
          actions: [
            IconButton(
              icon: Icon(Icons.send),
              onPressed: _publish,
            ),
          ],
        ),
        body: Column(
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
                            color: Palette.colorIcon,
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
                        children: _tagList.map((content) {
                          return ActionChip(
                            label: Text(
                              content,
                              style: TextStyle(color: Colors.white),
                            ),
                            backgroundColor: Palette.colorPrimary,
                            onPressed: () {
                              setState(() {
                                _tagList.remove(content);
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
                          border: InputBorder.none,
                          labelText: "回复内容",
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
                    color: Palette.colorPrimary,
                    height: kToolbarHeight,
                    width: double.infinity,
                    child: Row(children: _getBottomBarData()),
                  ),
                  Container(
                    color: Palette.colorBackground,
                    width: double.infinity,
                    height: _bottomPanelVisible ? Dimen.bottomPanelHeight : 0,
                    child: _currentBottomPanelChild,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
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
                      iconData,
                      color: iconData == CommunityMaterialIcons.ninja &&
                              !_isAnonymous
                          ? Colors.white30
                          : Colors.white,
                    ),
                  ),
                  onTap: () async {
                    if (iconData == CommunityMaterialIcons.ninja) {
                      _ninjaIconClicked();
                    } else if (iconData == CommunityMaterialIcons.emoticon) {
                      _emoticonIconClicked();
                    } else if (iconData == CommunityMaterialIcons.format_text) {
                      _formatTextIconClicked();
                    } else if (iconData == CommunityMaterialIcons.attachment) {
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

  void _ninjaIconClicked() {
    Fluttertoast.showToast(
      msg: _isAnonymous ? "关闭匿名" : "开启匿名",
      gravity: ToastGravity.CENTER,
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
      int position = leftPartString.length + startTag.length;
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
            startTag.length +
            selectionString.length +
            endTag.length;
        _contentController.selection = TextSelection(
          extentOffset: position,
          baseOffset: position,
        );
      } else {
        _contentController.text = "$leftPartString$startTag$rightPartString";
        int position = leftPartString.length + startTag.length;
        _contentController.selection = TextSelection(
          extentOffset: position,
          baseOffset: position,
        );
      }
    }
  }

  void _attachmentCallback(attachments, attachmentsCheck) async {
    final tab = await AndroidGbk.urlEncode("\t");
    _attachments.write(tab);
    _attachments.write(await AndroidGbk.urlEncode(attachments));
    _attachmentsCheck.write(tab);
    _attachmentsCheck.write(await AndroidGbk.urlEncode(attachmentsCheck));
  }

  void _showTagDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return ForumTagDialog(
          fid: widget.topic.fid,
          onSelected: (tag) {
            if (!_tagList.contains(tag)) {
              setState(() {
                _tagList.add(tag);
              });
            }
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  void _publish() async {
    if (widget.topic != null) {
      try {
        String message = await Data().topicRepository.createReply(
            widget.topic.tid,
            widget.topic.fid,
            _subjectController.text,
            _contentController.text,
            _isAnonymous,
            _attachments.toString(),
            _attachmentsCheck.toString());
        Fluttertoast.showToast(
          msg: message,
          gravity: ToastGravity.CENTER,
        );
        Navigator.pop(context);
      } catch (error) {
        Fluttertoast.showToast(
          msg: error.message,
          gravity: ToastGravity.CENTER,
        );
      }
    } else if (widget.fid != null) {
      try {
        String message = await Data().topicRepository.createTopic(
            widget.fid,
            _subjectController.text,
            _contentController.text,
            _isAnonymous,
            _attachments.toString(),
            _attachmentsCheck.toString());
        Fluttertoast.showToast(
          msg: message,
          gravity: ToastGravity.CENTER,
        );
        Navigator.pop(context);
      } catch (error) {
        Fluttertoast.showToast(
          msg: error.message,
          gravity: ToastGravity.CENTER,
        );
      }
    }
  }
}
