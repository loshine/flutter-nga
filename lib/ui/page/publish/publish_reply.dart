import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/data/entity/topic_tag.dart';
import 'package:flutter_nga/plugins/android_gbk.dart';
import 'package:flutter_nga/ui/page/topic_detail/forum_tag_dialog.dart';
import 'package:flutter_nga/ui/widget/attachment_widget.dart';
import 'package:flutter_nga/ui/widget/emoticon_group_tabs_widget.dart';
import 'package:flutter_nga/ui/widget/font_style_widget.dart';
import 'package:flutter_nga/utils/dimen.dart';
import 'package:flutter_nga/utils/palette.dart';
import 'package:flutter_nga/utils/route.dart';
import 'package:fluttertoast/fluttertoast.dart';

class PublishPage extends StatefulWidget {
  const PublishPage({
    this.tid,
    this.fid,
    Key key,
  }) : super(key: key);

  final int tid;
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

  List<String> _selectedTags = [];
  List<TopicTag> _tagList = [];

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
      tid: widget.tid,
      fid: widget.fid,
      callback: _inputCallback,
      attachmentCallback: _attachmentCallback,
    );
    _currentBottomPanelChild = _emoticonGroupTabsWidget;
    KeyboardVisibility.onChange.listen((bool visible) {
      _keyboardVisible = visible;
      if (visible && _bottomPanelVisible) {
        _hideBottomPanel();
      }
    });
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
          title: Text(widget.tid != null ? "回帖" : "发帖"),
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
                        children: _selectedTags.map((content) {
                          return ActionChip(
                            label: Text(
                              content,
                              style: TextStyle(color: Colors.white),
                            ),
                            backgroundColor: Palette.colorPrimary,
                            onPressed: () {
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
          fid: widget.fid,
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
    if (widget.tid != null) {
      try {
        String message = await Data().topicRepository.createReply(
            widget.tid,
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
        Routes.pop(context);
      } catch (err) {
        Fluttertoast.showToast(
          msg: err.message,
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
        Routes.pop(context);
      } catch (err) {
        Fluttertoast.showToast(
          msg: err.message,
          gravity: ToastGravity.CENTER,
        );
      }
    }
  }
}
