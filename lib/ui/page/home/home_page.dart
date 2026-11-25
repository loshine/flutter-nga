import 'package:flutter/foundation.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:flutter_nga/providers/home/home_drawer_header_provider.dart';
import 'package:flutter_nga/providers/home/home_provider.dart';
import 'package:flutter_nga/providers/notification/unread_count_provider.dart';
import 'package:flutter_nga/providers/settings/blocklist_settings_provider.dart';
import 'package:flutter_nga/providers/settings/design_style_provider.dart';
import 'package:flutter_nga/providers/settings/interface_settings_provider.dart';
import 'package:flutter_nga/ui/page/forum_group/forum_group_tabs.dart';
import 'package:flutter_nga/ui/page/home/apple_workspace_shell.dart';
import 'package:flutter_nga/ui/page/home/inbox_hub_page.dart';
import 'package:flutter_nga/ui/page/home/library_hub_page.dart';
import 'package:flutter_nga/ui/page/mine/mine_page.dart';
import 'package:flutter_nga/ui/widget/adaptive/app_icons.dart';
import 'package:flutter_nga/ui/widget/adaptive/app_scaffold.dart';
import 'package:flutter_nga/ui/widget/adaptive/liquid_glass_surface.dart';
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

  List<NavigationDestination> _buildDestinations(
    BuildContext context,
    int unreadTotal,
  ) {
    Widget withBadge(Widget icon) {
      return Badge.count(
        count: unreadTotal,
        isLabelVisible: unreadTotal > 0,
        child: icon,
      );
    }

    return [
      NavigationDestination(
        icon: Icon(AppIcons.forum(context)),
        selectedIcon: Icon(AppIcons.forum(context, filled: true)),
        label: '版块',
      ),
      NavigationDestination(
        icon: Icon(AppIcons.bookmark(context)),
        selectedIcon: Icon(AppIcons.bookmark(context)),
        label: '收藏',
      ),
      NavigationDestination(
        icon: withBadge(Icon(AppIcons.mail(context))),
        selectedIcon: withBadge(Icon(AppIcons.mail(context))),
        label: '消息',
      ),
      NavigationDestination(
        icon: Icon(AppIcons.person(context)),
        selectedIcon: Icon(AppIcons.person(context, filled: true)),
        label: '我的',
      ),
    ];
  }

  List<Widget> _buildPageList(ScrollToTopSignal communityScrollToTop) {
    return [
      ForumGroupTabsPage(scrollToTop: communityScrollToTop),
      const LibraryHubPage(),
      const InboxHubPage(),
      const MinePage(),
    ];
  }

  String _getTitleText(int index) {
    const titles = ['FNGA', '收藏', '消息', '我的'];
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
          icon: Icon(AppIcons.search(context)),
          onPressed: () => Routes.navigateTo(context, Routes.SEARCH),
        ),
      ],
      _ => const [],
    };
  }

  void _openCustomForumDialog(BuildContext context) {
    showDialog(context: context, builder: (_) => const CustomForumDialog());
  }

  AppPrimaryAction _buildPrimaryAction(
    BuildContext context,
    WidgetRef ref,
    int index,
  ) {
    final fabVisible = index == 0 && ref.watch(forumGroupFabVisibleProvider);
    return AppPrimaryAction(
      key: const ValueKey('home_fab'),
      tooltip: '添加自定义版面',
      visible: fabVisible,
      icon: const Icon(Icons.add),
      appleIcon: Icon(AppIcons.add(context)),
      onPressed: () => _openCustomForumDialog(context),
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
    final destinations = _buildDestinations(context, unreadTotal);

    final scrollToTop = useMemoized(ScrollToTopSignal.new);
    useEffect(() => scrollToTop.dispose, [scrollToTop]);
    final doubleTap = useMemoized(DoubleTapDetector.new);
    final pageList = _buildPageList(scrollToTop);
    final safeIndex = index.clamp(0, pageList.length - 1);
    final size = MediaQuery.sizeOf(context);
    final sizeClass = WindowSizeClass.fromWidth(size.width);
    final isLargeScreen = sizeClass.isMediumOrLarger;
    final isExpanded = sizeClass.isExpandedOrLarger;
    final isApple = context.isAppleStyle;
    final isDesktopPlatform =
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux;
    final isTabletOrDesktop =
        isDesktopPlatform || size.shortestSide >= kCompactBreakpoint;

    // Apple 风格大屏（macOS / 桌面端或 iPad 等平板设备）采用完整的三栏 Source List 工作区；
    // iPhone 横屏虽然宽度 >= 600，但 shortestSide < 600，继续保持 Apple 4-Tab 移动端布局。
    if (isApple && isLargeScreen && isTabletOrDesktop) {
      return const AppleWorkspaceShell();
    }

    // 双击当前导航项回到顶部，点击其他项正常切换
    void onDestinationSelected(int i) {
      if (i != safeIndex) {
        doubleTap.reset();
        ref.read(homeIndexProvider.notifier).setIndex(i);
      } else if (doubleTap.tap() && i == 0) {
        scrollToTop.fire();
      }
    }

    // 点击版块页标题回到顶部
    final onTitleTap = safeIndex == 0 ? scrollToTop.fire : null;

    return PopScope(
      canPop: safeIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        if (safeIndex != 0) {
          ref.read(homeIndexProvider.notifier).setIndex(0);
        }
      },
      child: isApple
          ? _buildAppleMobileLayout(
              context,
              ref,
              safeIndex,
              destinations,
              pageList,
              onDestinationSelected,
              onTitleTap,
            )
          : (isLargeScreen
                ? _buildLargeScreenLayout(
                    context,
                    ref,
                    safeIndex,
                    destinations,
                    pageList,
                    onDestinationSelected,
                    onTitleTap,
                    isExpanded: isExpanded,
                  )
                : _buildMobileLayout(
                    context,
                    ref,
                    safeIndex,
                    destinations,
                    pageList,
                    onDestinationSelected,
                    onTitleTap,
                  )),
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

  /// Material 移动端布局：AppBar + Content + NavigationBar
  Widget _buildMobileLayout(
    BuildContext context,
    WidgetRef ref,
    int index,
    List<NavigationDestination> destinations,
    List<Widget> pageList,
    ValueChanged<int> onDestinationSelected,
    VoidCallback? onTitleTap,
  ) {
    return AppScaffold(
      title: _buildAnimatedTitle(context, index, onTitleTap),
      scrolledUnderElevation: index == 0 ? 0 : 2,
      actions: _getActionsByPage(context, ref, index),
      automaticallyImplyLeading: false,
      body: _buildAnimatedBody(context, index, pageList),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: onDestinationSelected,
        destinations: destinations,
      ),
      primaryAction: _buildPrimaryAction(context, ref, index),
    );
  }

  /// Apple iPhone 移动端布局：Liquid Glass 顶部导航栏 + 底部悬浮胶囊 Liquid Glass TabBar（无 FAB）。
  Widget _buildAppleMobileLayout(
    BuildContext context,
    WidgetRef ref,
    int index,
    List<NavigationDestination> destinations,
    List<Widget> pageList,
    ValueChanged<int> onDestinationSelected,
    VoidCallback? onTitleTap,
  ) {
    final mediaQuery = MediaQuery.of(context);
    final bottomInset = mediaQuery.padding.bottom;
    return AppScaffold(
      title: _buildAnimatedTitle(context, index, onTitleTap),
      actions: _getActionsByPage(context, ref, index),
      automaticallyImplyLeading: false,
      extendBody: true,
      primaryAction: _buildPrimaryAction(context, ref, index),
      // 通过增大 MediaQuery 底部安全区而非外层 Padding，让列表内容可以滚动穿过
      // 悬浮 Liquid Glass 底栏下方产生毛玻璃透出，同时滚到底部时不被遮挡。
      body: MediaQuery(
        data: mediaQuery.copyWith(
          padding: mediaQuery.padding.copyWith(bottom: bottomInset + 72),
        ),
        child: _buildAnimatedBody(context, index, pageList),
      ),
      bottomNavigationBar: _AppleFloatingTabBar(
        selectedIndex: index,
        destinations: destinations,
        onSelected: onDestinationSelected,
      ),
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
            child: AppScaffold(
              title: _buildAnimatedTitle(context, index, onTitleTap),
              scrolledUnderElevation: index == 0 ? 0 : 2,
              actions: _getActionsByPage(context, ref, index),
              automaticallyImplyLeading: false,
              body: _buildAnimatedBody(context, index, pageList),
              primaryAction: _buildPrimaryAction(context, ref, index),
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

/// iOS 26 Liquid Glass 悬浮胶囊底部 TabBar。
class _AppleFloatingTabBar extends StatelessWidget {
  const _AppleFloatingTabBar({
    required this.selectedIndex,
    required this.destinations,
    required this.onSelected,
  });

  final int selectedIndex;
  final List<NavigationDestination> destinations;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        4,
        20,
        bottomPadding > 0 ? bottomPadding : 12,
      ),
      child: Center(
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: LiquidGlassSurface(
            borderRadius: BorderRadius.circular(30),
            interactive: true,
            padding: const EdgeInsets.all(4),
            child: Row(
              children: [
                for (var i = 0; i < destinations.length; i++)
                  Expanded(
                    child: _AppleTabBarButton(
                      destination: destinations[i],
                      selected: i == selectedIndex,
                      colorScheme: colorScheme,
                      onTap: () => onSelected(i),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AppleTabBarButton extends StatelessWidget {
  const _AppleTabBarButton({
    required this.destination,
    required this.selected,
    required this.colorScheme,
    required this.onTap,
  });

  final NavigationDestination destination;
  final bool selected;
  final ColorScheme colorScheme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? colorScheme.primary : colorScheme.onSurfaceVariant;
    return Semantics(
      selected: selected,
      button: true,
      label: destination.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: Motion.resolveDuration(context, Motion.durationShort3),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
          decoration: BoxDecoration(
            color: selected
                ? colorScheme.primary.withValues(alpha: 0.14)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(26),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconTheme(
                data: IconThemeData(color: fg, size: 22),
                child: selected
                    ? (destination.selectedIcon ?? destination.icon)
                    : destination.icon,
              ),
              const SizedBox(height: 2),
              Text(
                destination.label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  color: fg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
