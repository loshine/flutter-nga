import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_nga/providers/home/home_drawer_header_provider.dart';
import 'package:flutter_nga/ui/widget/avatar_widget.dart';
import 'package:flutter_nga/utils/route.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class HomeDrawerHeader extends HookConsumerWidget {
  const HomeDrawerHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userInfo = ref.watch(homeDrawerHeaderProvider);
    final colorScheme = Theme.of(context).colorScheme;

    useEffect(() {
      Future.microtask(() {
        ref.read(homeDrawerHeaderProvider.notifier).refresh();
      });
      return null;
    }, []);

    final paddingTop = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
      ),
      padding: EdgeInsets.fromLTRB(16, 16 + paddingTop, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => _maybeGoLogin(context, userInfo != null),
            borderRadius: BorderRadius.circular(28),
            child: AvatarWidget(
              userInfo != null ? userInfo.avatar : "",
              size: 56,
              username: userInfo != null ? userInfo.username : "",
            ),
          ),
          const SizedBox(height: 16),
          Text(
            userInfo != null ? userInfo.username! : "点击登录",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: colorScheme.onPrimaryContainer,
            ),
          ),
          if (userInfo != null)
            Text(
              "UID: ${userInfo.uid}",
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onPrimaryContainer.withOpacity(0.7),
              ),
            ),
        ],
      ),
    );
  }

  void _maybeGoLogin(BuildContext context, bool isLoggedIn) async {
    if (isLoggedIn) return;
    Routes.pop(context);
    Routes.navigateTo(context, Routes.LOGIN);
  }
}

class HomeDrawerBody extends StatelessWidget {
  final int? currentSelection;
  final Function(int)? onSelectedCallback;

  const HomeDrawerBody({
    Key? key,
    this.currentSelection,
    this.onSelectedCallback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Expanded(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // 模块分组标题
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 16, 16, 8),
            child: Text(
              "模块",
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),

          // 导航项
          _NavigationItem(
            icon: Icons.dashboard_outlined,
            selectedIcon: Icons.dashboard,
            label: "论坛",
            selected: currentSelection == 0,
            onTap: () => onSelectedCallback?.call(0),
          ),
          _NavigationItem(
            icon: Icons.bookmark_outline,
            selectedIcon: Icons.bookmark,
            label: "贴子收藏",
            selected: currentSelection == 1,
            onTap: () => onSelectedCallback?.call(1),
          ),
          _NavigationItem(
            icon: Icons.history_outlined,
            selectedIcon: Icons.history,
            label: "浏览历史",
            selected: currentSelection == 2,
            onTap: () => onSelectedCallback?.call(2),
          ),
          _NavigationItem(
            icon: Icons.mail_outlined,
            selectedIcon: Icons.mail,
            label: "短消息",
            selected: currentSelection == 3,
            onTap: () => onSelectedCallback?.call(3),
          ),
          _NavigationItem(
            icon: Icons.notifications_outlined,
            selectedIcon: Icons.notifications,
            label: "提醒信息",
            selected: currentSelection == 4,
            onTap: () => onSelectedCallback?.call(4),
          ),

          const Divider(indent: 28, endIndent: 28),

          // 其它分组标题
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 16, 16, 8),
            child: Text(
              "其它",
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),

          _NavigationItem(
            icon: Icons.settings_outlined,
            selectedIcon: Icons.settings,
            label: "设置",
            selected: false,
            onTap: () => Routes.navigateTo(context, Routes.SETTINGS),
          ),
          _NavigationItem(
            icon: Icons.info_outline,
            selectedIcon: Icons.info,
            label: "关于",
            selected: false,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

/// M3 风格的导航项
class _NavigationItem extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  const _NavigationItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: selected ? colorScheme.secondaryContainer : Colors.transparent,
        borderRadius: BorderRadius.circular(28),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(28),
          child: Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(
                  selected ? selectedIcon : icon,
                  color: selected
                      ? colorScheme.onSecondaryContainer
                      : colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: selected
                          ? colorScheme.onSecondaryContainer
                          : colorScheme.onSurfaceVariant,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    ),
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