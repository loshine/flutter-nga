import 'dart:io';

import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/ui/widget/expression_group_tabs_widget.dart';
import 'package:flutter_nga/utils/dimen.dart';
import 'package:flutter_nga/utils/palette.dart';
import 'package:image_picker/image_picker.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';

class PublishReplyPage extends StatefulWidget {
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

  @override
  void initState() {
    super.initState();
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
                          onTap: () => debugPrint("选标签"),
                        ),
                      ),
                      keyboardType: TextInputType.text,
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
            Container(
              color: Palette.colorPrimary,
              height: _keyboardVisible ? kToolbarHeight : 0,
              width: double.infinity,
              child: Builder(
                  builder: (BuildContext c) =>
                      Row(children: _getBottomBarData(c))),
            ),
          ],
        ),
        bottomNavigationBar: BottomSheet(
            onClosing: () {},
            builder: (BuildContext c) {
              return SizedBox(
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
                      child: EmoticonGroupTabsWidget(),
                    )
                  ],
                ),
              );
            }),
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

  void _emoticonIconClicked() {
    if (_keyboardVisible) {
      SystemChannels.textInput.invokeMethod('TextInput.hide');
    }
    setState(() {
      _bottomPanelVisible = !_bottomPanelVisible;
    });
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

  void _formatTextIconClicked() {
    Data().topicRepository.getTopicTagList(-7).then((list) {
      debugPrint(list.map((tag) => tag.content).reduce((sum, s) => "$sum, $s"));
    });
  }
}
