import 'package:flutter/material.dart';
import 'package:flutter_nga/providers/home/home_provider.dart';
import 'package:flutter_nga/providers/settings/blocklist_settings_provider.dart';
import 'package:flutter_nga/providers/settings/interface_settings_provider.dart';
import 'package:flutter_nga/ui/page/conversation/conversation_list_page.dart';
import 'package:flutter_nga/ui/page/favourite_topic_list/favourite_topic_list_page.dart';
import 'package:flutter_nga/ui/page/forum_group/forum_group_tabs.dart';
import 'package:flutter_nga/ui/page/history/topic_history_list_page.dart';
import 'package:flutter_nga/ui/page/notification/notification_list_page.dart';
import 'package:flutter_nga/ui/widget/custom_forum_dialog.dart';
import 'package:flutter_nga/utils/route.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

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

  /// M3 NavigationBar/Rail 导航目的地
  static const _destinations = [
    NavigationDestination(
      icon: Icon(Icons.dashboard_outlined),
      selectedIcon: Icon(Icons.dashboard),
      label: '论坛',
    ),
    NavigationDestination(
      icon: Icon(Icons.bookmark_outline),
      selectedIcon: Icon(Icons.bookmark),
      label: '收藏',
    ),
    NavigationDestination(
      icon: Icon(Icons.history_outlined),
      selectedIcon: Icon(Icons.history),
      label: '历史',
    ),
    NavigationDestination(
      icon: Icon(Icons.mail_outlined),
      selectedIcon: Icon(Icons.mail),
      label: '消息',
    ),
    NavigationDestination(
      icon: Icon(Icons.notifications_outlined),
      selectedIcon: Icon(Icons.notifications),
      label: '提醒',
    ),
  ];

  /// 响应式断点：大于此宽度使用 NavigationRail
  static const double _railBreakpoint = 600.0;

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

  List<Widget> _getActionsByPage(
      BuildContext context, WidgetRef ref, int index) {
    return switch (index) {
      0 => [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => Routes.navigateTo(context, Routes.SEARCH),
          ),
          _buildMoreMenu(context),
        ],
      2 => [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _historyStateKey.currentState?.showCleanDialog(),
          ),
          _buildMoreMenu(context),
        ],
      _ => [_buildMoreMenu(context)],
    };
  }

  /// 右上角菜单，替代 Drawer 的设置/关于入口
  Widget _buildMoreMenu(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: (value) {
        switch (value) {
          case 'settings':
            Routes.navigateTo(context, Routes.SETTINGS);
          case 'about':
            Routes.navigateTo(context, Routes.ABOUT);
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'settings',
          child: ListTile(
            leading: Icon(Icons.settings_outlined),
            title: Text('设置'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        const PopupMenuItem(
          value: 'about',
          child: ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('关于'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }

  Widget? _getFloatingActionButton(
      BuildContext context, WidgetRef ref, int index) {
    if (index == 0) {
      final fabVisible = ref.watch(forumGroupFabVisibleProvider);
      if (!fabVisible) return null;
      return FloatingActionButton(
        tooltip: '添加自定义版面',
        onPressed: () => showDialog(
          context: context,
          builder: (_) => const CustomForumDialog(),
        ),
        child: const Icon(Icons.add),
      );
    } else if (index == 3) {
      return FloatingActionButton(
        tooltip: '新建短消息',
        onPressed: () =>
            Routes.navigateTo(context, "${Routes.SEND_MESSAGE}?mid=0"),
        child: const Icon(Icons.edit_outlined),
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(homeIndexProvider);
    final pageList = _buildPageList();
    final width = MediaQuery.sizeOf(context).width;
    final isLargeScreen = width >= _railBreakpoint;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        if (index != 0) {
          ref.read(homeIndexProvider.notifier).setIndex(0);
          return;
        }

        Navigator.of(context).pop();
      },
      child: isLargeScreen
          ? _buildLargeScreenLayout(context, ref, index, pageList)
          : _buildMobileLayout(context, ref, index, pageList),
    );
  }

  /// 移动端布局：AppBar + Content + BottomNavigationBar
  Widget _buildMobileLayout(
    BuildContext context,
    WidgetRef ref,
    int index,
    List<Widget> pageList,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitleText(index)),
        scrolledUnderElevation: index == 0 ? 0 : 2,
        actions: _getActionsByPage(context, ref, index),
        automaticallyImplyLeading: false,
      ),
      body: pageList[index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) =>
            ref.read(homeIndexProvider.notifier).setIndex(i),
        destinations: _destinations,
      ),
      floatingActionButton: _getFloatingActionButton(context, ref, index),
    );
  }

  /// 大屏布局：NavigationRail 延伸全屏高度，与 AppBar 并列
  Widget _buildLargeScreenLayout(
    BuildContext context,
    WidgetRef ref,
    int index,
    List<Widget> pageList,
  ) {
    return Row(
      children: [
        // NavigationRail 独立于 Scaffold，占据全屏高度
        NavigationRail(
          selectedIndex: index,
          onDestinationSelected: (i) =>
              ref.read(homeIndexProvider.notifier).setIndex(i),
          labelType: NavigationRailLabelType.all,
          destinations: _destinations
              .map((d) => NavigationRailDestination(
                    icon: d.icon,
                    selectedIcon: d.selectedIcon,
                    label: Text(d.label),
                  ))
              .toList(),
        ),
        const VerticalDivider(thickness: 1, width: 1),
        // 内容区域包含 AppBar
        Expanded(
          child: Scaffold(
            appBar: AppBar(
              title: Text(_getTitleText(index)),
              scrolledUnderElevation: index == 0 ? 0 : 2,
              actions: _getActionsByPage(context, ref, index),
              automaticallyImplyLeading: false,
            ),
            body: pageList[index],
            floatingActionButton: _getFloatingActionButton(context, ref, index),
          ),
        ),
      ],
    );
  }
}
