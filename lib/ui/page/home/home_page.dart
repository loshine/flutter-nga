import 'dart:async';

import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/data/entity/user.dart';
import 'package:flutter_nga/data/repository/user_repository.dart';
import 'package:flutter_nga/plugins/login.dart';
import 'package:flutter_nga/ui/page/favourite_topic_list/favourite_topic_list_page.dart';
import 'package:flutter_nga/ui/page/forum_group/forum_group_tabs.dart';
import 'package:flutter_nga/ui/page/history/topic_history_list_page.dart';
import 'package:flutter_nga/ui/widget/avatar_widget.dart';
import 'package:flutter_nga/utils/palette.dart';
import 'package:flutter_nga/utils/route.dart';
import 'package:fluttertoast/fluttertoast.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var _index = 0;
  UserInfo _userInfo;
  String _nickname;
  StreamSubscription _subscription;
  GlobalKey<TopicHistoryListState> _historyStateKey;
  List<Widget> pageList;

  _HomePageState() {
    _historyStateKey = GlobalKey<TopicHistoryListState>();
    pageList = [
      ForumGroupTabsPage(),
      FavouriteTopicListPage(),
      TopicHistoryListPage(key: _historyStateKey),
    ];
  }

  String get _titleText {
    if (_index == 0) {
      return 'NGA';
    } else if (_index == 1) {
      return '贴子收藏';
    } else {
      return '浏览历史';
    }
  }

  List<Widget> _getActionsByPage(int index) {
    List<Widget> actions = [];
    if (_index == 0) {
      actions.add(IconButton(
        icon: Icon(Icons.search),
        onPressed: () => Routes.navigateTo(context, Routes.SEARCH),
      ));
    } else if (_index == 2) {
      actions.add(IconButton(
        icon: Icon(Icons.delete_forever),
        onPressed: () => _historyStateKey.currentState.showCleanDialog(),
      ));
    }
    return actions;
  }

  void _setSelection(int i) {
    Routes.pop(context);
    setState(() {
      _index = i;
    });
  }

  void _maybeGoLogin(BuildContext context) async {
    User user = await Data().userRepository.getDefaultUser();
    if (user == null) {
      Routes.pop(context);
      AndroidLogin.startLogin()
          .then((result) => debugPrint("goAndroidLogin result: $result"))
          .catchError((e) => debugPrint(e.toString()));
//    Navigator.of(context).push(MaterialPageRoute(builder: (_) => LoginPage()));
    }
  }

  double _getElevation() {
    return _index == 0 ? 0 : 4;
  }

  void _setUser(User user) async {
    if (this.mounted) {
      if (user != null) {
        Data()
            .userRepository
            .getUserInfoByName(user.nickname)
            .then((userInfo) => setState(() => _userInfo = userInfo));
        setState(() => _nickname = user.nickname);
      }
    }
  }

  @override
  void initState() {
    Data().userRepository.getDefaultUser().then((user) => _setUser(user));
    _subscription = AndroidLogin.cookieStream.listen(
      (cookies) {
        if (cookies.contains(TAG_CID)) {
          Data()
              .userRepository
              .saveLoginCookies(cookies)
              .then((user) => _setUser(user))
              .whenComplete(() {
            Fluttertoast.showToast(
              msg: "登录成功",
              gravity: ToastGravity.CENTER,
            );
          });
        }
      },
      onError: (e) => debugPrint(e.toString()),
    );
    super.initState();
  }

  @override
  void dispose() {
    // 关闭数据库
    Data().close();
    // 取消监听
    if (_subscription != null) {
      _subscription.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: _getElevation(),
        title: Text(_titleText),
        actions: _getActionsByPage(_index),
      ),
      backgroundColor: Palette.colorBackground,
      drawer: Drawer(
        child: Column(
          children: [
            InkWell(
              onTap: () => _maybeGoLogin(context),
              child: Container(
                height: 240.0,
                width: double.infinity,
                color: Palette.colorBackground,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: AvatarWidget(
                        _userInfo != null ? _userInfo.avatar : "",
                        size: 56,
                        username: _nickname,
                      ),
                    ),
                    Text(_nickname ?? "点击登陆"),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Container(
                color: Palette.colorBackground,
                child: Column(
                  children: [
                    Divider(height: 1),
                    Container(
                      padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
                      height: 56,
                      child: Align(
                        child: Text(
                          "模块",
                          style: TextStyle(color: Colors.black45),
                          textAlign: TextAlign.left,
                          textDirection: TextDirection.ltr,
                        ),
                        alignment: Alignment.centerLeft,
                      ),
                    ),
                    Material(
                      child: InkWell(
                        child: ListTile(
                          leading: Icon(Icons.forum),
                          title: Text("论坛"),
                          selected: _index == 0,
                        ),
                        onTap: () => _setSelection(0),
                      ),
                      color: Palette.colorBackground,
                    ),
                    Material(
                      child: InkWell(
                        child: ListTile(
                          leading: Icon(CommunityMaterialIcons.archive),
                          title: Text("贴子收藏"),
                          selected: _index == 1,
                        ),
                        onTap: () => _setSelection(1),
                      ),
                      color: Palette.colorBackground,
                    ),
                    Material(
                      child: InkWell(
                        child: ListTile(
                          leading: Icon(CommunityMaterialIcons.history),
                          title: Text("浏览历史"),
                          selected: _index == 2,
                        ),
                        onTap: () => _setSelection(2),
                      ),
                      color: Palette.colorBackground,
                    ),
                    Divider(height: 1),
                    Container(
                      padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
                      height: 56,
                      child: Align(
                        child: Text(
                          "其它",
                          style: TextStyle(color: Colors.black45),
                          textAlign: TextAlign.left,
                          textDirection: TextDirection.ltr,
                        ),
                        alignment: Alignment.centerLeft,
                      ),
                    ),
                    Material(
                      child: InkWell(
                        child: ListTile(
                          leading: Icon(Icons.settings),
                          title: Text("设置"),
                        ),
                        onTap: () =>
                            Routes.navigateTo(context, Routes.SETTINGS),
                      ),
                      color: Palette.colorBackground,
                    ),
                    Material(
                      child: InkWell(
                        child: ListTile(
                          leading: Icon(Icons.info_outline),
                          title: Text("关于"),
                        ),
                        onTap: () {
                          // TODO: 点击关于
                        },
                      ),
                      color: Palette.colorBackground,
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
      body: pageList[_index],
    );
  }
}
