import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_nga/providers/home/home_drawer_header_provider.dart';
import 'package:flutter_nga/providers/home/home_provider.dart';
import 'package:flutter_nga/providers/notification/unread_count_provider.dart';
import 'package:flutter_nga/providers/settings/blocklist_settings_provider.dart';
import 'package:flutter_nga/providers/settings/interface_settings_provider.dart';
import 'package:flutter_nga/ui/page/forum_group/forum_group_tabs.dart';
import 'package:flutter_nga/ui/page/mine/mine_page.dart';
import 'package:flutter_nga/ui/widget/adaptive_layout.dart';
import 'package:flutter_nga/ui/widget/custom_forum_dialog.dart';
import 'package:flutter_nga/utils/dimen.dart';
import 'package:flutter_nga/utils/hooks/easy_refresh_hooks.dart';
import 'package:flutter_nga/utils/hooks/scroll_to_top.dart';
import 'package:flutter_nga/utils/motion.dart';
import 'package:flutter_nga/utils/route.dart';

class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    usePostFrameEffect(() {
      ref.read(blocklistSettingsProvider.notifier).init();
      ref.read(blocklistSettingsProvider.notifier).loopSyncBlockList();
      ref.read(interfaceSettingsProvider.notifier).init();
      // 首页启动时预刷新用户信息与未读计数，确保在社区页即可看到「我的」角标
      Future.microtask(() async {
        try {
          await ref.read(homeDrawerHeaderProvider.notifier).refresh();
        } catch (_) {
          // 离线或未初始化时忽略，进入「我的」页仍会再次尝试
        }
        if (!context.mounted) return;
        if (ref.read(homeDrawerHeaderProvider) != null) {
          ref.read(unreadCountProvider.notifier).refresh();
        }
      });
    });
    return const _HomePageContent();
  }
}

class _HomePageContent extends HookConsumerWidget {
  const _HomePageContent();

  List<NavigationDestination> _buildDestinations(int unreadTotal) {
    Widget withBadge(Widget icon) {
      return Badge.count(
        count: unreadTotal,
        isLabelVisible: unreadTotal > 0,
        child: icon,
      );
    }

    return [
      const NavigationDestination(
        icon: Icon(Icons.forum_outlined),
        selectedIcon: Icon(Icons.forum),
        label: '社区',
      ),
      NavigationDestination(
        icon: withBadge(const Icon(Icons.person_outline)),
        selectedIcon: withBadge(const Icon(Icons.person)),
        label: '我的',
      ),
    ];
  }

  List<Widget> _buildPageList(ScrollToTopSignal communityScrollToTop) {
    return [
      ForumGroupTabsPage(scrollToTop: communityScrollToTop),
      const MinePage(),
    ];
  }

  String _getTitleText(int index) {
    const titles = ['FNGA', '我的'];
    return titles.elementAtOrNull(index) ?? '';
  }

  List<Widget> _getActionsByPage(
    BuildContext context,
    WidgetRef ref,
    int index,
  ) {
    return switch (index) {
      0 => [
        IconButton(
          tooltip: '搜索',
          icon: const Icon(Icons.search),
          onPressed: () => Routes.navigateTo(context, Routes.SEARCH),
        ),
      ],
      _ => const [],
    };
  }

  void _openCustomForumDialog(BuildContext context) {
    showDialog(context: context, builder: (_) => const CustomForumDialog());
  }

  Widget _getFloatingActionButton(
    BuildContext context,
    WidgetRef ref,
    int index,
  ) {
    final fabVisible = index == 0 && ref.watch(forumGroupFabVisibleProvider);
    final Widget? fab = fabVisible
        ? FloatingActionButton(
            key: const ValueKey('home_fab'),
            tooltip: '添加自定义版面',
            onPressed: () => _openCustomForumDialog(context),
            child: const Icon(Icons.add),
          )
        : null;
    return AnimatedSwitcher(
      duration: Motion.resolveDuration(context, Motion.durationShort4),
      switchInCurve: Motion.emphasizedDecelerate,
      switchOutCurve: Motion.emphasizedAccelerate,
      transitionBuilder: (child, animation) => ScaleTransition(
        scale: animation,
        child: FadeTransition(opacity: animation, child: child),
      ),
      child: fab,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(homeIndexProvider);
    final userInfo = ref.watch(homeDrawerHeaderProvider);
    ref.watch(unreadCountProvider);
    final unreadTotal = ref
        .read(unreadCountProvider.notifier)
        .countsFor(userInfo?.uid)
        .total;
    final destinations = _buildDestinations(unreadTotal);

    final scrollToTop = useMemoized(ScrollToTopSignal.new);
    useEffect(() => scrollToTop.dispose, [scrollToTop]);
    final doubleTap = useMemoized(DoubleTapDetector.new);
    final pageList = _buildPageList(scrollToTop);
    final sizeClass = WindowSizeClass.of(context);
    final isLargeScreen = sizeClass.isMediumOrLarger;
    final isExpanded = sizeClass.isExpandedOrLarger;

    // 双击当前导航项回到顶部，点击其他项正常切换
    void onDestinationSelected(int i) {
      if (i != index) {
        doubleTap.reset();
        ref.read(homeIndexProvider.notifier).setIndex(i);
      } else if (doubleTap.tap() && i == 0) {
        scrollToTop.fire();
      }
    }

    // 点击社区页标题回到顶部
    final onTitleTap = index == 0 ? scrollToTop.fire : null;

    return PopScope(
      canPop: index == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        if (index != 0) {
          ref.read(homeIndexProvider.notifier).setIndex(0);
        }
      },
      child: isLargeScreen
          ? _buildLargeScreenLayout(
              context,
              ref,
              index,
              destinations,
              pageList,
              onDestinationSelected,
              onTitleTap,
              isExpanded: isExpanded,
            )
          : _buildMobileLayout(
              context,
              ref,
              index,
              destinations,
              pageList,
              onDestinationSelected,
              onTitleTap,
            ),
    );
  }

  /// 切换标签页时的过渡动画：M3 Fade Through，遵循系统减弱动画设置
  Widget _buildAnimatedBody(
    BuildContext context,
    int index,
    List<Widget> pageList,
  ) {
    return AnimatedSwitcher(
      duration: Motion.resolveDuration(context, Motion.durationMedium1),
      switchInCurve: Motion.emphasizedDecelerate,
      switchOutCurve: Motion.emphasizedAccelerate,
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.015),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        ),
      ),
      child: KeyedSubtree(key: ValueKey(index), child: pageList[index]),
    );
  }

  /// AppBar 标题随标签页切换淡入淡出，[onTap] 用于点击标题回到顶部
  Widget _buildAnimatedTitle(
    BuildContext context,
    int index,
    VoidCallback? onTap,
  ) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedSwitcher(
        duration: Motion.resolveDuration(context, Motion.durationShort4),
        child: Text(_getTitleText(index), key: ValueKey(index)),
      ),
    );
  }

  /// 移动端布局：AppBar + Content + NavigationBar
  Widget _buildMobileLayout(
    BuildContext context,
    WidgetRef ref,
    int index,
    List<NavigationDestination> destinations,
    List<Widget> pageList,
    ValueChanged<int> onDestinationSelected,
    VoidCallback? onTitleTap,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: _buildAnimatedTitle(context, index, onTitleTap),
        scrolledUnderElevation: index == 0 ? 0 : 2,
        actions: _getActionsByPage(context, ref, index),
        automaticallyImplyLeading: false,
      ),
      body: _buildAnimatedBody(context, index, pageList),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: onDestinationSelected,
        destinations: destinations,
      ),
      floatingActionButton: _getFloatingActionButton(context, ref, index),
    );
  }

  /// 大屏布局：
  /// - Expanded（>= 840dp）：使用永久展开的 [NavigationDrawer]，选中胶囊同时包裹图标和文字；
  /// - Medium（600~839dp）：使用折叠态 [NavigationRail]；
  /// 右侧内容区域独立持有 AppBar 与右下角 FAB。
  Widget _buildLargeScreenLayout(
    BuildContext context,
    WidgetRef ref,
    int index,
    List<NavigationDestination> destinations,
    List<Widget> pageList,
    ValueChanged<int> onDestinationSelected,
    VoidCallback? onTitleTap, {
    required bool isExpanded,
  }) {
    final navigationPane = isExpanded
        ? _buildExpandedDrawer(
            context,
            index,
            destinations,
            onDestinationSelected,
          )
        : NavigationRail(
            extended: false,
            selectedIndex: index,
            onDestinationSelected: onDestinationSelected,
            labelType: NavigationRailLabelType.all,
            destinations: destinations
                .map(
                  (d) => NavigationRailDestination(
                    icon: d.icon,
                    selectedIcon: d.selectedIcon,
                    label: Text(d.label),
                  ),
                )
                .toList(),
          );

    return Row(
      children: [
        // 侧边导航栏独立于 Scaffold，占据全屏高度
        navigationPane,
        const VerticalDivider(thickness: 1, width: 1),
        // 内容区域包含 AppBar 与右下角 FAB
        Expanded(
          child: MediaQuery.removePadding(
            context: context,
            removeLeft: true,
            child: Scaffold(
              appBar: AppBar(
                title: _buildAnimatedTitle(context, index, onTitleTap),
                scrolledUnderElevation: index == 0 ? 0 : 2,
                actions: _getActionsByPage(context, ref, index),
                automaticallyImplyLeading: false,
              ),
              body: _buildAnimatedBody(context, index, pageList),
              floatingActionButton: _getFloatingActionButton(
                context,
                ref,
                index,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 大屏永久侧边导航栏（M3 NavigationDrawer）：选中胶囊整体包裹 icon 与文字。
  Widget _buildExpandedDrawer(
    BuildContext context,
    int index,
    List<NavigationDestination> destinations,
    ValueChanged<int> onDestinationSelected,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final drawerTheme = theme.navigationDrawerTheme;
    const tileHorizontalPadding = 12.0;

    return SizedBox(
      width: kExpandedNavDrawerWidth,
      child: DrawerTheme(
        data: theme.drawerTheme.copyWith(
          width: kExpandedNavDrawerWidth,
          elevation: 0,
          shape: const RoundedRectangleBorder(),
          backgroundColor: colorScheme.surface,
        ),
        child: NavigationDrawerTheme(
          data: drawerTheme.copyWith(
            indicatorSize: Size(
              kExpandedNavDrawerWidth - tileHorizontalPadding * 2,
              drawerTheme.tileHeight ?? 52,
            ),
          ),
          child: NavigationDrawer(
            selectedIndex: index,
            onDestinationSelected: onDestinationSelected,
            tilePadding: const EdgeInsets.symmetric(
              horizontal: tileHorizontalPadding,
              vertical: 2,
            ),
            header: Padding(
              padding: const EdgeInsets.fromLTRB(
                Dimen.spacingXL,
                Dimen.spacingL,
                Dimen.spacingL,
                Dimen.spacingM,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'FNGA',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
            children: [
              for (final d in destinations)
                NavigationDrawerDestination(
                  icon: d.icon,
                  selectedIcon: d.selectedIcon,
                  label: Text(d.label),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
