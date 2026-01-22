import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/providers/home/home_provider.dart';
import 'package:flutter_nga/ui/page/forum_group/favourite_forum_group_page.dart';
import 'package:flutter_nga/ui/widget/keep_alive_tab_view.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'forum_group_page.dart';

class ForumGroupTabsPage extends HookConsumerWidget {
  const ForumGroupTabsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final list = Data().forumRepository.getForumGroups();

    List<Tab> tabs = [const Tab(text: "我的收藏")];
    List<Widget> tabBarViews = [
      KeepAliveTabView(child: FavouriteForumGroupPage())
    ];

    tabs.addAll(list.map((group) => Tab(text: group.name)));
    tabBarViews.addAll(list
        .map((group) => KeepAliveTabView(child: ForumGroupPage(group: group))));

    final tabController = useTabController(initialLength: tabs.length);

    useEffect(() {
      void listener() {
        // 更新 FAB 可见性：只有第一个 tab (我的收藏) 才显示
        ref
            .read(forumGroupFabVisibleProvider.notifier)
            .setVisible(tabController.index == 0);
      }

      tabController.addListener(listener);
      // 初始化状态
      Future.microtask(() => listener());
      return () => tabController.removeListener(listener);
    }, [tabController]);

    return Scaffold(
      appBar: PreferredSize(
        child: AppBar(
          bottom: TabBar(
            controller: tabController,
            isScrollable: true,
            tabs: tabs,
          ),
        ),
        preferredSize: const Size.fromHeight(kToolbarHeight),
      ),
      body: TabBarView(
        controller: tabController,
        children: tabBarViews,
      ),
    );
  }
}
