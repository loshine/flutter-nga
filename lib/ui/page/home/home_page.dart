import 'dart:async';

import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/data/entity/user.dart';
import 'package:flutter_nga/data/repository/user_repository.dart';
import 'package:flutter_nga/plugins/login.dart';
import 'package:flutter_nga/ui/page/forum/forum_group_tabs.dart';
import 'package:flutter_nga/ui/page/match/match_tabs.dart';
import 'package:flutter_nga/ui/page/settings/settings.dart';
import 'package:flutter_nga/ui/widget/avatar_widget.dart';
import 'package:flutter_nga/utils/palette.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var _index = 0;
  User user;
  UserInfo _userInfo;
  String _nickname;
  StreamSubscription _subscription;
  final pageList = [
    ForumGroupTabsPage(),
    MatchTabsPage(),
  ];

  void _setSelection(int i) {
    Navigator.pop(context);
    setState(() {
      _index = i;
    });
  }

  void _maybeGoLogin(BuildContext context) async {
    User user = await Data().userRepository.getDefaultUser();
    if (user == null) {
      Navigator.of(context).pop();
      AndroidLogin.startLogin()
          .then((result) => debugPrint("goAndroidLogin result: $result"))
          .catchError((e) => debugPrint(e.toString()));
//    Navigator.of(context).push(MaterialPageRoute(builder: (_) => LoginPage()));
    }
  }

  double _getElevation() {
    return _index == 0 ? 0 : 4;
  }

  void setUser(User user) async {
    if (this.mounted) {
      setState(() => this.user = user);
      if (user != null) {
        Data()
            .userRepository
            .getUserInfo(user.nickname)
            .then((userInfo) => setState(() => _userInfo = userInfo));
        setState(() => _nickname = user.nickname);
      }
    }
  }

  @override
  void initState() {
    Data().userRepository.getDefaultUser().then((user) => setUser(user));
    _subscription = AndroidLogin.cookieStream.listen(
      (cookies) {
        if (cookies.contains(TAG_CID)) {
          Data()
              .userRepository
              .saveLoginCookies(cookies)
              .then((user) => setUser(user));
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
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: _getElevation(),
        title: Text(widget.title),
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
                          leading: Icon(
                            CommunityMaterialIcons.medal,
                            size: 24,
                            color: _index == 1
                                ? Palette.colorPrimary
                                : Palette.colorIcon,
                          ),
                          title: Text("赛事"),
                          selected: _index == 1,
                        ),
                        onTap: () => _setSelection(1),
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
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => SettingsPage()));
                        },
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
