import 'dart:math';

import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_nga/providers/forum/forum_category_list_provider.dart';
import 'package:flutter_nga/providers/home/home_provider.dart';
import 'package:flutter_nga/ui/page/forum_group/favourite_forum_group_page.dart';
import 'package:flutter_nga/ui/widget/keep_alive_tab_view.dart';
import 'package:flutter_nga/utils/app_toast.dart';
import 'package:flutter_nga/utils/dimen.dart';
import 'package:flutter_nga/utils/hooks/easy_refresh_hooks.dart';
import 'package:flutter_nga/utils/hooks/material_tab_controller_hook.dart';

import 'forum_category_page.dart';

class ForumGroupTabsPage extends HookConsumerWidget {
  const ForumGroupTabsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    usePostFrameEffect(() {
      ref.read(forumCategoryListProvider.notifier).ensureLoaded();
    });

    final categoryState = ref.watch(forumCategoryListProvider);
    final categories = categoryState.categories;

    List<Tab> tabs = [const Tab(text: "我的收藏")];
    List<Widget> tabBarViews = [
      KeepAliveTabView(child: FavouriteForumGroupPage())
    ];

    if (categories.isEmpty) {
      // 首次启动且无缓存时，用占位 Tab 展示加载中 / 失败重试
      tabs.add(const Tab(text: "版块"));
      tabBarViews.add(const _ForumCategoryPlaceholder());
    } else {
      tabs.addAll(categories.map((category) => Tab(text: category.name)));
      tabBarViews.addAll(categories.map((category) => KeepAliveTabView(
            child: ForumCategoryPage(category: category),
          )));
    }

    // 分类数量变化时会重建 controller，尽量保留当前选中的 Tab
    final selectedIndex = useRef(0);
    final tabController = useMaterialTabController(
      initialLength: tabs.length,
      initialIndex: min(selectedIndex.value, tabs.length - 1),
      keys: [tabs.length],
    );

    useEffect(() {
      void listener() {
        selectedIndex.value = tabController.index;
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

class _ForumCategoryPlaceholder extends ConsumerWidget {
  const _ForumCategoryPlaceholder();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(forumCategoryListProvider);
    final error = state.error;
    if (error == null || state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Dimen.spacingL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(error, textAlign: TextAlign.center),
            const SizedBox(height: Dimen.spacingL),
            FilledButton.tonal(
              onPressed: () => ref
                  .read(forumCategoryListProvider.notifier)
                  .refresh()
                  .catchError(AppToast.error),
              child: const Text("重试"),
            ),
          ],
        ),
      ),
    );
  }
}
