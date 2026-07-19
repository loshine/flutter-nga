import 'package:flutter/material.dart';
import 'package:flutter_nga/providers/home/home_provider.dart';
import 'package:flutter_nga/providers/settings/blocklist_settings_provider.dart';
import 'package:flutter_nga/providers/settings/interface_settings_provider.dart';
import 'package:flutter_nga/ui/page/forum_group/forum_group_tabs.dart';
import 'package:flutter_nga/ui/page/mine/mine_page.dart';
import 'package:flutter_nga/ui/widget/custom_forum_dialog.dart';
import 'package:flutter_nga/utils/motion.dart';
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

  /// M3 NavigationBar/Rail 导航目的地
  static const _destinations = [
    NavigationDestination(
      icon: Icon(Icons.forum_outlined),
      selectedIcon: Icon(Icons.forum),
      label: '社区',
    ),
    NavigationDestination(
      icon: Icon(Icons.person_outline),
      selectedIcon: Icon(Icons.person),
      label: '我的',
    ),
  ];

  /// 响应式断点：大于此宽度使用 NavigationRail
  static const double _railBreakpoint = 600.0;

  List<Widget> _buildPageList() {
    return [
      const ForumGroupTabsPage(),
      const MinePage(),
    ];
  }

  String _getTitleText(int index) {
    const titles = ['FNGA', '我的'];
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
        ],
      _ => const [],
    };
  }

  Widget _getFloatingActionButton(
      BuildContext context, WidgetRef ref, int index) {
    final fabVisible =
        index == 0 && ref.watch(forumGroupFabVisibleProvider);
    return AnimatedSwitcher(
      duration: Motion.durationShort4,
      switchInCurve: Motion.emphasizedDecelerate,
      switchOutCurve: Motion.emphasizedAccelerate,
      transitionBuilder: (child, animation) => ScaleTransition(
        scale: animation,
        child: FadeTransition(opacity: animation, child: child),
      ),
      child: fabVisible
          ? FloatingActionButton(
              tooltip: '添加自定义版面',
              onPressed: () => showDialog(
                context: context,
                builder: (_) => const CustomForumDialog(),
              ),
              child: const Icon(Icons.add),
            )
          : null,
    );
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

  /// 切换标签页时的过渡动画：淡入淡出 + 轻微上移
  Widget _buildAnimatedBody(int index, List<Widget> pageList) {
    return AnimatedSwitcher(
      duration: Motion.durationMedium2,
      switchInCurve: Motion.emphasizedDecelerate,
      switchOutCurve: Motion.emphasizedAccelerate,
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.02),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        ),
      ),
      child: KeyedSubtree(
        key: ValueKey(index),
        child: pageList[index],
      ),
    );
  }

  /// AppBar 标题随标签页切换淡入淡出
  Widget _buildAnimatedTitle(int index) {
    return AnimatedSwitcher(
      duration: Motion.durationShort4,
      child: Text(
        _getTitleText(index),
        key: ValueKey(index),
      ),
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
        title: _buildAnimatedTitle(index),
        scrolledUnderElevation: index == 0 ? 0 : 2,
        actions: _getActionsByPage(context, ref, index),
        automaticallyImplyLeading: false,
      ),
      body: _buildAnimatedBody(index, pageList),
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
              title: _buildAnimatedTitle(index),
              scrolledUnderElevation: index == 0 ? 0 : 2,
              actions: _getActionsByPage(context, ref, index),
              automaticallyImplyLeading: false,
            ),
            body: _buildAnimatedBody(index, pageList),
            floatingActionButton: _getFloatingActionButton(context, ref, index),
          ),
        ),
      ],
    );
  }
}
