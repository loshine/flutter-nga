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
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(blocklistSettingsProvider.notifier).init();
      ref.read(blocklistSettingsProvider.notifier).loopSyncBlockList();
      ref.read(interfaceSettingsProvider.notifier).init();
    });
    return const _HomePageContent();
  }
}

class _HomePageContent extends HookConsumerWidget {
  const _HomePageContent();

  static final GlobalKey<TopicHistoryListPageState> _historyStateKey =
      GlobalKey<TopicHistoryListPageState>();

  List<Widget> _buildPageList() {
    return [
      const ForumGroupTabsPage(),
      const FavouriteTopicListPage(),
      TopicHistoryListPage(key: _historyStateKey),
      const ConversationListPage(),
      const NotificationListPage(),
    ];
  }

  String _getTitleText(int index) {
    const titles = ['NGA', '贴子收藏', '浏览历史', '短消息', '提醒信息'];
    return titles.elementAtOrNull(index) ?? '';
  }

  List<Widget> _getActionsByPage(BuildContext context, int index) {
    return switch (index) {
      0 => [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => Routes.navigateTo(context, Routes.SEARCH),
          ),
        ],
      2 => [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _historyStateKey.currentState?.showCleanDialog(),
          ),
        ],
      _ => [],
    };
  }

  Widget? _getFloatingActionButton(BuildContext context, int index) {
    return switch (index) {
      0 => FloatingActionButton(
          tooltip: '添加自定义版面',
          onPressed: () => showDialog(
            context: context,
            builder: (_) => const CustomForumDialog(),
          ),
          child: const Icon(Icons.add),
        ),
      3 => FloatingActionButton(
          tooltip: '新建短消息',
          onPressed: () =>
              Routes.navigateTo(context, "${Routes.SEND_MESSAGE}?mid=0"),
          child: const Icon(Icons.edit_outlined),
        ),
      _ => null,
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(homeIndexProvider);
    final pageList = _buildPageList();
    final scaffoldKey = GlobalKey<ScaffoldState>();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        if (scaffoldKey.currentState?.isDrawerOpen == true) {
          Navigator.of(context).pop();
          return;
        }

        if (index != 0) {
          ref.read(homeIndexProvider.notifier).setIndex(0);
          return;
        }

        Navigator.of(context).pop();
      },
      child: Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          title: Text(_getTitleText(index)),
          scrolledUnderElevation: index == 0 ? 0 : 2,
          actions: _getActionsByPage(context, index),
        ),
        drawer: Drawer(
          child: Column(
            children: [
              const HomeDrawerHeader(),
              HomeDrawerBody(
                currentSelection: index,
                onSelectedCallback: (i) {
                  Routes.pop(context);
                  ref.read(homeIndexProvider.notifier).setIndex(i);
                },
              ),
            ],
          ),
        ),
        body: pageList[index],
        floatingActionButton: _getFloatingActionButton(context, index),
      ),
    );
  }
}
