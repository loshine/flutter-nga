import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_nga/store/common/interface_settings_store.dart';
import 'package:flutter_nga/store/home/home_drawer_header_store.dart';
import 'package:flutter_nga/store/home/home_store.dart';
import 'package:flutter_nga/ui/page/conversation/conversation_list_page.dart';
import 'package:flutter_nga/ui/page/favourite_topic_list/favourite_topic_list_page.dart';
import 'package:flutter_nga/ui/page/forum_group/forum_group_tabs.dart';
import 'package:flutter_nga/ui/page/history/topic_history_list_page.dart';
import 'package:flutter_nga/ui/page/home/home_drawer.dart';
import 'package:flutter_nga/ui/page/notification/notification_list_page.dart';
import 'package:flutter_nga/ui/widget/custom_forum_dialog.dart';
import 'package:flutter_nga/utils/route.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Provider.of<InterfaceSettingsStore>(context).init();
    return MultiProvider(
      providers: [
        Provider(create: (_) => HomeDrawerHeaderStore()),
      ],
      child: _HomePage(),
    );
  }
}

class _HomePage extends StatefulWidget {
  const _HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<_HomePage> {
  GlobalKey<TopicHistoryListState>? _historyStateKey;
  late List<Widget> pageList;
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
        onPressed: () => _historyStateKey!.currentState!.showCleanDialog(),
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
        final key = GlobalKey<ScaffoldState>();
        return WillPopScope(
          child: Scaffold(
            key: key,
            appBar: AppBar(
              elevation: _getElevation(),
              title: Text(_titleText),
              actions: _getActionsByPage(_store.index),
            ),
            backgroundColor: Theme.of(context).backgroundColor,
            drawer: Drawer(
              child: Column(
                children: [
                  HomeDrawerHeader(),
                  HomeDrawerBody(
                    currentSelection: _store.index,
                    onSelectedCallback: _setSelection,
                  )
                ],
              ),
            ),
            body: pageList[_store.index],
            floatingActionButton: _getFloatingActionButton(),
          ),
          onWillPop: () async {
            if (key.currentState!.isDrawerOpen || _store.index == 0) {
              return true;
            } else {
              _store.setIndex(0);
              return false;
            }
          },
        );
      },
    );
  }

  FloatingActionButton? _getFloatingActionButton() {
    FloatingActionButton? fab;
    if (_store.index == 0) {
      fab = FloatingActionButton(
        tooltip: '添加自定义版面',
        onPressed: () => showDialog(
          context: context,
          builder: (_) => CustomForumDialog(),
        ),
        child: Icon(
          CommunityMaterialIcons.plus,
          color: Colors.white,
        ),
      );
    } else if (_store.index == 3) {
      fab = FloatingActionButton(
        tooltip: '新建短消息',
        onPressed: () =>
            Routes.navigateTo(context, "${Routes.SEND_MESSAGE}?mid=0"),
        child: Icon(
          CommunityMaterialIcons.email_plus,
          color: Colors.white,
        ),
      );
    }
    return fab;
  }
}
