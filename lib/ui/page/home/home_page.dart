import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nga/providers/home/home_provider.dart';
import 'package:flutter_nga/providers/settings/blocklist_settings_provider.dart';
import 'package:flutter_nga/providers/settings/interface_settings_provider.dart';
import 'package:flutter_nga/ui/page/conversation/conversation_list_page.dart';
import 'package:flutter_nga/ui/page/favourite_topic_list/favourite_topic_list_page.dart';
import 'package:flutter_nga/ui/page/forum_group/forum_group_tabs.dart';
import 'package:flutter_nga/ui/page/history/topic_history_list_page.dart';
import 'package:flutter_nga/ui/page/home/home_drawer.dart';
import 'package:flutter_nga/ui/page/notification/notification_list_page.dart';
import 'package:flutter_nga/ui/widget/custom_forum_dialog.dart';
import 'package:flutter_nga/utils/route.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class HomePage extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Initialize settings on first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(blocklistSettingsProvider.notifier).init();
      ref.read(blocklistSettingsProvider.notifier).loopSyncBlockList();
      ref.read(interfaceSettingsProvider.notifier).init();
    });
    return _HomePage();
  }
}

class _HomePage extends HookConsumerWidget {
  _HomePage({Key? key}) : super(key: key);

  final GlobalKey<TopicHistoryListPageState> _historyStateKey =
      GlobalKey<TopicHistoryListPageState>();

  List<Widget> _buildPageList() {
    return [
      ForumGroupTabsPage(),
      FavouriteTopicListPage(),
      TopicHistoryListPage(key: _historyStateKey),
      ConversationListPage(),
      NotificationListPage(),
    ];
  }

  String _getTitleText(int index) {
    switch (index) {
      case 0:
        return 'NGA';
      case 1:
        return '贴子收藏';
      case 2:
        return '浏览历史';
      case 3:
        return '短消息';
      case 4:
        return '提醒信息';
      default:
        return '';
    }
  }

  List<Widget> _getActionsByPage(BuildContext context, int index) {
    List<Widget> actions = [];
    if (index == 0) {
      actions.add(IconButton(
        icon: Icon(Icons.search),
        onPressed: () => Routes.navigateTo(context, Routes.SEARCH),
      ));
    } else if (index == 2) {
      actions.add(IconButton(
        icon: Icon(Icons.delete_forever),
        onPressed: () => _historyStateKey.currentState!.showCleanDialog(),
      ));
    }
    return actions;
  }

  double _getElevation(int index) {
    return index == 0 ? 0 : 4;
  }

  FloatingActionButton? _getFloatingActionButton(BuildContext context, int index) {
    if (index == 0) {
      return FloatingActionButton(
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
    } else if (index == 3) {
      return FloatingActionButton(
        tooltip: '新建短消息',
        onPressed: () =>
            Routes.navigateTo(context, "${Routes.SEND_MESSAGE}?mid=0"),
        child: Icon(
          CommunityMaterialIcons.email_plus,
          color: Colors.white,
        ),
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(homeIndexProvider);
    final pageList = _buildPageList();
    final scaffoldKey = GlobalKey<ScaffoldState>();

    return WillPopScope(
      child: Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          elevation: _getElevation(index),
          title: Text(_getTitleText(index)),
          actions: _getActionsByPage(context, index),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        drawer: Drawer(
          child: Column(
            children: [
              HomeDrawerHeader(),
              HomeDrawerBody(
                currentSelection: index,
                onSelectedCallback: (i) {
                  Routes.pop(context);
                  ref.read(homeIndexProvider.notifier).setIndex(i);
                },
              )
            ],
          ),
        ),
        body: pageList[index],
        floatingActionButton: _getFloatingActionButton(context, index),
      ),
      onWillPop: () async {
        if (scaffoldKey.currentState!.isDrawerOpen || index == 0) {
          return true;
        } else {
          ref.read(homeIndexProvider.notifier).setIndex(0);
          return false;
        }
      },
    );
  }
}
