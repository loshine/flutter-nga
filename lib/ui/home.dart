import 'package:flutter/material.dart';
import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/ui/forum/forum_group_tabs.dart';
import 'package:flutter_nga/ui/match/match_tabs.dart';
import 'package:flutter_nga/ui/user/login.dart';
import 'package:flutter_nga/utils/palette.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var _index = 0;

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

  void _goLogin(BuildContext context) {
    Navigator.of(context).pop();
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => LoginPage()));
  }

  double _getElevation() {
    return _index == 0 ? 0 : 4;
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
              onTap: () => _goLogin(context),
              child: Container(
                height: 240.0,
                width: double.infinity,
                color: Palette.colorBackground,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image(
                      image: AssetImage("assets/images/logo.png"),
                      width: 96.0,
                      height: 96.0,
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        "TO-DOs",
                      ),
                    )
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
                        onTap: () {
                          _setSelection(0);
                        },
                      ),
                      color: Palette.colorBackground,
                    ),
                    Material(
                      child: InkWell(
                        child: ListTile(
                          leading: SvgPicture.asset(
                            'images/medal.svg',
                            fit: BoxFit.none,
                            height: 24,
                            width: 24,
                            color: _index == 1
                                ? Palette.colorPrimary
                                : Palette.colorIcon,
                          ),
                          title: Text("赛事"),
                          selected: _index == 1,
                        ),
                        onTap: () {
                          _setSelection(1);
                        },
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
                          // TODO: 点击设置
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

  @override
  void dispose() {
    // 关闭数据库
    Data().close();
    super.dispose();
  }
}
