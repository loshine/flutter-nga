import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_nga/data/entity/user.dart';
import 'package:flutter_nga/providers/home/home_drawer_header_provider.dart';
import 'package:flutter_nga/ui/widget/avatar_widget.dart';
import 'package:flutter_nga/utils/dimen.dart';
import 'package:flutter_nga/utils/motion.dart';
import 'package:flutter_nga/utils/route.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// 【我的】页面：集中收藏、历史、消息、提醒以及设置、关于入口
class MinePage extends HookConsumerWidget {
  const MinePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userInfo = ref.watch(homeDrawerHeaderProvider);

    useEffect(() {
      Future.microtask(
          () => ref.read(homeDrawerHeaderProvider.notifier).refresh());
      return null;
    }, []);

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: Dimen.spacingS),
      children: [
        _EntranceAnimation(
          index: 0,
          child: _UserHeaderCard(userInfo: userInfo),
        ),
        _EntranceAnimation(
          index: 1,
          child: _EntryGroup(
            title: '社区',
            children: [
              _EntryTile(
                icon: Icons.bookmark_outline,
                title: '贴子收藏',
                subtitle: '收藏的贴子',
                onTap: () =>
                    Routes.navigateTo(context, Routes.FAVOURITE_TOPICS),
              ),
              _EntryTile(
                icon: Icons.history_outlined,
                title: '浏览历史',
                subtitle: '最近浏览的贴子',
                onTap: () => Routes.navigateTo(context, Routes.TOPIC_HISTORY),
              ),
              _EntryTile(
                icon: Icons.mail_outlined,
                title: '短消息',
                subtitle: '私信会话',
                onTap: () => Routes.navigateTo(context, Routes.CONVERSATIONS),
              ),
              _EntryTile(
                icon: Icons.notifications_outlined,
                title: '提醒信息',
                subtitle: '回复与系统通知',
                onTap: () => Routes.navigateTo(context, Routes.NOTIFICATIONS),
              ),
            ],
          ),
        ),
        _EntranceAnimation(
          index: 2,
          child: _EntryGroup(
            title: '应用',
            children: [
              _EntryTile(
                icon: Icons.settings_outlined,
                title: '设置',
                subtitle: '主题、网络与屏蔽',
                onTap: () => Routes.navigateTo(context, Routes.SETTINGS),
              ),
              _EntryTile(
                icon: Icons.info_outline,
                title: '关于',
                subtitle: '版本与开源信息',
                onTap: () => Routes.navigateTo(context, Routes.ABOUT),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 用户信息卡片：未登录点击去登录，已登录点击进入用户主页
class _UserHeaderCard extends ConsumerWidget {
  final UserInfo? userInfo;

  const _UserHeaderCard({required this.userInfo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isLoggedIn = userInfo != null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Material(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(Dimen.radiusL),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _onTap(context, ref, isLoggedIn),
          child: Padding(
            padding: const EdgeInsets.all(Dimen.spacingL),
            child: Row(
              children: [
                AvatarWidget(userInfo?.avatar, size: 56),
                const SizedBox(width: Dimen.spacingL),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isLoggedIn ? userInfo!.username! : '点击登录',
                        style: textTheme.titleMedium?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: Dimen.spacingXS),
                      Text(
                        isLoggedIn ? 'UID: ${userInfo!.uid}' : '登录后体验完整功能',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onTap(BuildContext context, WidgetRef ref, bool isLoggedIn) {
    if (isLoggedIn) {
      Routes.navigateTo(context, '${Routes.USER}?uid=${userInfo!.uid}');
    } else {
      Routes.navigateTo(context, Routes.LOGIN).then((_) {
        // 登录返回后刷新用户信息
        ref.read(homeDrawerHeaderProvider.notifier).refresh();
      });
    }
  }
}

/// 入口分组
class _EntryGroup extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _EntryGroup({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: textTheme.titleSmall?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ...children,
      ],
    );
  }
}

/// 入口项，样式与设置页保持一致
class _EntryTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _EntryTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(Dimen.radiusM),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(Dimen.radiusM),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(Dimen.radiusS),
                  ),
                  child: Icon(
                    icon,
                    color: colorScheme.onPrimaryContainer,
                    size: Dimen.iconSmall,
                  ),
                ),
                const SizedBox(width: Dimen.spacingL),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 分组进场动画：按序号错峰淡入 + 上移
class _EntranceAnimation extends StatelessWidget {
  /// 共享实例，避免 TweenAnimationBuilder 因 tween 引用变化而重启动画
  static final Tween<double> _tween = Tween(begin: 0, end: 1);

  final int index;
  final Widget child;

  const _EntranceAnimation({required this.index, required this.child});

  @override
  Widget build(BuildContext context) {
    final begin = (index * 0.12).clamp(0.0, 0.6);
    return TweenAnimationBuilder<double>(
      tween: _tween,
      duration: Motion.durationExtraLong1,
      curve: Interval(begin, 1, curve: Motion.emphasizedDecelerate),
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, 24 * (1 - value)),
          child: child,
        ),
      ),
      child: child,
    );
  }
}
