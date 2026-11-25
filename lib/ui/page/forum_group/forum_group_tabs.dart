import 'dart:math';

import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:flutter_nga/data/entity/forum.dart';
import 'package:flutter_nga/providers/forum/forum_category_list_provider.dart';
import 'package:flutter_nga/providers/home/home_provider.dart';
import 'package:flutter_nga/providers/settings/design_style_provider.dart';
import 'package:flutter_nga/ui/page/forum_group/favourite_forum_group_page.dart';
import 'package:flutter_nga/ui/widget/adaptive/adaptive_controls.dart';
import 'package:flutter_nga/ui/widget/keep_alive_tab_view.dart';
import 'package:flutter_nga/utils/app_toast.dart';
import 'package:flutter_nga/utils/dimen.dart';
import 'package:flutter_nga/utils/hooks/easy_refresh_hooks.dart';
import 'package:flutter_nga/utils/hooks/material_tab_controller_hook.dart';
import 'package:flutter_nga/utils/hooks/scroll_to_top.dart';

import 'forum_category_page.dart';

class ForumGroupTabsPage extends HookConsumerWidget {
  const ForumGroupTabsPage({super.key, this.scrollToTop, this.onForumTap});

  /// 首页触发「回到顶部」时，滚动当前 Tab
  final ScrollToTopSignal? scrollToTop;

  /// 自定义点击版块回调（供 macOS 三栏工作区在不离开侧边栏的情况下打开版块）
  final ValueChanged<Forum>? onForumTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    usePostFrameEffect(() {
      ref.read(forumCategoryListProvider.notifier).ensureLoaded();
    });

    final categoryState = ref.watch(forumCategoryListProvider);
    final categories = categoryState.categories;
    final tabSignals = useScrollToTopSignals(
      1 + (categories.isEmpty ? 1 : categories.length),
    );

    final tabLabels = <String>['我的收藏'];
    final tabs = <Tab>[const Tab(text: '我的收藏')];
    final tabBarViews = <Widget>[
      KeepAliveTabView(
        child: FavouriteForumGroupPage(
          scrollToTop: tabSignals[0],
          onForumTap: onForumTap,
        ),
      ),
    ];

    if (categories.isEmpty) {
      // 首次启动且无缓存时，用占位 Tab 展示加载中 / 失败重试
      tabLabels.add('版块');
      tabs.add(const Tab(text: '版块'));
      tabBarViews.add(const _ForumCategoryPlaceholder());
    } else {
      for (final (i, category) in categories.indexed) {
        tabLabels.add(category.name);
        tabs.add(Tab(text: category.name));
        tabBarViews.add(
          KeepAliveTabView(
            child: ForumCategoryPage(
              category: category,
              scrollToTop: tabSignals[i + 1],
              onForumTap: onForumTap,
            ),
          ),
        );
      }
    }

    // 分类数量变化时会重建 controller，尽量保留当前选中的 Tab
    final selectedIndex = useRef(0);
    final activeIndex = useState(0);
    final tabController = useMaterialTabController(
      initialLength: tabs.length,
      initialIndex: min(selectedIndex.value, tabs.length - 1),
      keys: [tabs.length],
    );

    useEffect(() {
      void listener() {
        selectedIndex.value = tabController.index;
        activeIndex.value = tabController.index;
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

    useEffect(() {
      final signal = scrollToTop;
      if (signal == null) return null;
      void listener() => tabSignals[tabController.index].fire();
      signal.addListener(listener);
      return () => signal.removeListener(listener);
    }, [scrollToTop, tabSignals, tabController]);

    final isApple = context.isAppleStyle;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        if (isApple)
          Container(
            height: 44,
            decoration: BoxDecoration(
              color: colorScheme.surface,
              border: Border(
                bottom: BorderSide(
                  color: colorScheme.outlineVariant,
                  width: 0.5,
                ),
              ),
            ),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              itemCount: tabLabels.length,
              separatorBuilder: (_, _) => const SizedBox(width: 6),
              itemBuilder: (context, index) {
                final selected = activeIndex.value == index;
                return GestureDetector(
                  onTap: () => tabController.animateTo(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected
                          ? colorScheme.primary
                          : colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      tabLabels[index],
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: selected
                            ? colorScheme.onPrimary
                            : colorScheme.onSurface,
                      ),
                    ),
                  ),
                );
              },
            ),
          )
        else
          Material(
            color: colorScheme.surface,
            child: TabBar(
              controller: tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              tabs: tabs,
            ),
          ),
        Expanded(
          child: TabBarView(controller: tabController, children: tabBarViews),
        ),
      ],
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
      return const Center(child: AppActivityIndicator());
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
