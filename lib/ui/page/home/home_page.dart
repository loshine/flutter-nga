import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_nga/store/home_drawer_header_store.dart';
import 'package:flutter_nga/store/home_store.dart';
import 'package:flutter_nga/ui/page/conversation/conversation_list_page.dart';
import 'package:flutter_nga/ui/page/favourite_topic_list/favourite_topic_list_page.dart';
import 'package:flutter_nga/ui/page/forum_group/forum_group_tabs.dart';
import 'package:flutter_nga/ui/page/history/topic_history_list_page.dart';
import 'package:flutter_nga/ui/page/home/home_drawer.dart';
import 'package:flutter_nga/ui/page/notification/notification_list_page.dart';
import 'package:flutter_nga/utils/palette.dart';
import 'package:flutter_nga/utils/route.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => HomeDrawerHeaderStore()),
      ],
      child: _HomePage(),
    );
  }
}

class _HomePage extends StatefulWidget {
  const _HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<_HomePage> {
  GlobalKey<TopicHistoryListState> _historyStateKey;
  List<Widget> pageList;
  final _store = HomeStore();

  _HomePageState() {
    _historyStateKey = GlobalKey<TopicHistoryListState>();
    pageList = [
      ForumGroupTabsPage(),
      FavouriteTopicListPage(),
      TopicHistoryListPage(key: _historyStateKey),
      ConversationListPage(),
      NotificationListPage(),
    ];
  }

  String get _titleText {
    if (_store.index == 0) {
      return 'NGA';
    } else if (_store.index == 1) {
      return '贴子收藏';
    } else if (_store.index == 2) {
      return '浏览历史';
    } else if (_store.index == 3) {
      return '短消息';
    } else if (_store.index == 4) {
      return '提醒信息';
    }
    return '';
  }

  List<Widget> _getActionsByPage(int index) {
    List<Widget> actions = [];
    if (_store.index == 0) {
      actions.add(IconButton(
        icon: Icon(Icons.search),
        onPressed: () => Routes.navigateTo(context, Routes.SEARCH),
      ));
    } else if (_store.index == 2) {
      actions.add(IconButton(
        icon: Icon(Icons.delete_forever),
        onPressed: () => _historyStateKey.currentState.showCleanDialog(),
      ));
    }
    return actions;
  }

  void _setSelection(int i) {
    Routes.pop(context);
    _store.setIndex(i);
  }

  double _getElevation() {
    return _store.index == 0 ? 0 : 4;
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) {
        return Scaffold(
          appBar: AppBar(
            elevation: _getElevation(),
            title: Text(_titleText),
            actions: _getActionsByPage(_store.index),
          ),
          backgroundColor: Palette.colorBackground,
          drawer: Drawer(
            child: Column(
              children: [
                HomeDrawerHeader(),
                Expanded(
                  child: Container(
                    color: Palette.colorBackground,
                    child: Column(
                      children: [
                        Divider(height: 1),
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 16),
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
                              leading:
                                  Icon(CommunityMaterialIcons.view_dashboard),
                              title: Text("论坛"),
                              selected: _store.index == 0,
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
                              selected: _store.index == 1,
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
                              selected: _store.index == 2,
                            ),
                            onTap: () => _setSelection(2),
                          ),
                          color: Palette.colorBackground,
                        ),
                        Material(
                          child: InkWell(
                            child: ListTile(
                              leading: Icon(Icons.message),
                              title: Text("短消息"),
                              selected: _store.index == 3,
                            ),
                            onTap: () => _setSelection(3),
                          ),
                          color: Palette.colorBackground,
                        ),
                        Material(
                          child: InkWell(
                            child: ListTile(
                              leading: Icon(Icons.notifications_rounded),
                              title: Text("提醒信息"),
                              selected: _store.index == 4,
                            ),
                            onTap: () => _setSelection(4),
                          ),
                          color: Palette.colorBackground,
                        ),
                        Divider(height: 1),
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 16),
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
          body: pageList[_store.index],
        );
      },
    );
  }
}
