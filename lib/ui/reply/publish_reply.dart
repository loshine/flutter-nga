import 'dart:io';

import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/data/entity/topic.dart';
import 'package:flutter_nga/data/entity/topic_tag.dart';
import 'package:flutter_nga/ui/widget/emoticon_group_tabs_widget.dart';
import 'package:flutter_nga/ui/widget/font_style_widget.dart';
import 'package:flutter_nga/utils/dimen.dart';
import 'package:flutter_nga/utils/palette.dart';
import 'package:image_picker/image_picker.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';

class PublishReplyPage extends StatefulWidget {
  const PublishReplyPage(this.topic, {Key key}) : super(key: key);

  final Topic topic;

  @override
  _PublishReplyState createState() => _PublishReplyState();
}

class _PublishReplyState extends State<PublishReplyPage> {
  final _bottomData = [
    CommunityMaterialIcons.ninja,
    CommunityMaterialIcons.emoticon,
    CommunityMaterialIcons.format_text,
    Icons.image,
    CommunityMaterialIcons.keyboard
  ];

  bool _keyboardVisible = false;
  bool _bottomPanelVisible = false;
  bool _isAnonymous = false;

  List<String> _tagList = [];

  final _emoticonGroupTabsWidget = EmoticonGroupTabsWidget();
  final _fontStyleWidget = FontStyleWidget();

  Widget _currentBottomPanelChild;

  @override
  void initState() {
    super.initState();
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
              onPressed: () => debugPrint("回帖"),
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
                    child: Builder(
                        builder: (BuildContext c) =>
                            Row(children: _getBottomBarData(c))),
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

  List<Widget> _getBottomBarData(BuildContext c) {
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
                      _ninjaIconClicked(c);
                    } else if (iconData == CommunityMaterialIcons.emoticon) {
                      _emoticonIconClicked();
                    } else if (iconData == CommunityMaterialIcons.format_text) {
                      _formatTextIconClicked();
                    } else if (iconData == Icons.image) {
                      File image = await ImagePicker.pickImage(
                          source: ImageSource.gallery);
                    } else if (iconData == CommunityMaterialIcons.keyboard) {
                      _keyboardIconClicked();
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

  void _keyboardIconClicked() {
    if (_keyboardVisible) {
      SystemChannels.textInput.invokeMethod('TextInput.hide');
    } else {
      if (_bottomPanelVisible) {
        _hideBottomPanel();
      }
      SystemChannels.textInput.invokeMethod('TextInput.show');
    }
  }

  void _hideBottomPanel() {
    setState(() {
      _bottomPanelVisible = false;
    });
  }

  void _ninjaIconClicked(BuildContext c) {
    if (_keyboardVisible) {
      SystemChannels.textInput.invokeMethod('TextInput.hide');
    }
    Scaffold.of(c)
        .showSnackBar(SnackBar(content: Text(_isAnonymous ? "关闭匿名" : "开启匿名")));
    setState(() {
      _isAnonymous = !_isAnonymous;
    });
  }

  void _emoticonIconClicked() {
    if (_keyboardVisible) {
      SystemChannels.textInput.invokeMethod('TextInput.hide');
    }
    setState(() {
      if (_currentBottomPanelChild == _emoticonGroupTabsWidget &&
          _bottomPanelVisible) {
        _bottomPanelVisible = false;
      } else {
        _currentBottomPanelChild = _emoticonGroupTabsWidget;
        _bottomPanelVisible = true;
      }
    });
  }

  void _formatTextIconClicked() {
    if (_keyboardVisible) {
      SystemChannels.textInput.invokeMethod('TextInput.hide');
    }
    setState(() {
      if (_currentBottomPanelChild == _fontStyleWidget &&
          _bottomPanelVisible) {
        _bottomPanelVisible = false;
      } else {
        _currentBottomPanelChild = _fontStyleWidget;
        _bottomPanelVisible = true;
      }
    });
  }

  void _showTagDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              Text("主题分类"),
              Text(
                " (下滑有更多标签)",
                style: TextStyle(
                    fontSize: Dimen.caption, color: Palette.colorTextSecondary),
              )
            ],
          ),
          content: FutureBuilder(
            future: Data().topicRepository.getTopicTagList(widget.topic.fid),
            builder:
                (BuildContext context, AsyncSnapshot<List<TopicTag>> snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                  return Text('Press button to start.');
                case ConnectionState.active:
                case ConnectionState.waiting:
                  return Text('Awaiting result...');
                case ConnectionState.done:
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    return SizedBox(
                      width: 0,
                      height: 240,
                      child: ListView.builder(
                        itemCount: snapshot.data.length,
                        itemBuilder: (context, position) {
                          final content = snapshot.data[position].content;
                          return InkWell(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Text("$content"),
                            ),
                            onTap: () {
                              if (!_tagList.contains(content)) {
                                setState(() {
                                  _tagList.add(content);
                                });
                              }
                              Navigator.of(context).pop();
                            },
                          );
                        },
                      ),
                    );
                  }
              }
            },
          ),
        );
      },
    );
  }
}
