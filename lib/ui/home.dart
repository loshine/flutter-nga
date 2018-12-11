import 'package:flutter/material.dart';
import 'package:flutter_nga/ui/forum/forum_group_tabs.dart';
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
    ForumGroupTabsPage(),
  ];

  void _setSelection(int i) {
    setState(() {
      _index = i;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(widget.title),
      ),
      backgroundColor: Palette.colorBackground,
      drawer: Drawer(
        child: Column(
          children: [
            Container(
              height: 240.0,
              width: double.infinity,
              color: Palette.colorBackground,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image(
                    image: AssetImage("assets/images/logo.png"),
                    width: 100.0,
                    height: 100.0,
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
            Divider(height: 1),
            Expanded(
              child: Container(
                color: Palette.colorBackground,
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(
                        Icons.forum,
                      ),
                      title: Text("论坛"),
                      onTap: () {
                        _setSelection(0);
                      },
                    ),
                    ListTile(
                      leading: SvgPicture.asset(
                        'images/medal.svg',
                        fit: BoxFit.none,
                        height: 24,
                        width: 24,
                        color: Palette.colorIcon,
                      ),
                      title: Text("赛事"),
                      onTap: () {
                        _setSelection(1);
                      },
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
