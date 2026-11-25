import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_nga/data/entity/user.dart';
import 'package:flutter_nga/providers/home/home_drawer_header_provider.dart';
import 'package:flutter_nga/providers/notification/unread_count_provider.dart';
import 'package:flutter_nga/ui/widget/avatar_widget.dart';
import 'package:flutter_nga/ui/widget/m3_settings_group.dart';
import 'package:flutter_nga/ui/widget/readable_width.dart';
import 'package:flutter_nga/utils/dimen.dart';
import 'package:flutter_nga/utils/route.dart';

/// 【我的】页面：集中收藏、历史、消息、提醒以及设置、关于入口
class MinePage extends HookConsumerWidget {
  const MinePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userInfo = ref.watch(homeDrawerHeaderProvider);
    // 未登录不显示角标，计数不属于当前账号时也不显示
    ref.watch(unreadCountProvider);
    final unread = ref
        .read(unreadCountProvider.notifier)
        .countsFor(userInfo?.uid);

    void refreshUnread() {
      if (!context.mounted) return;
      if (ref.read(homeDrawerHeaderProvider) == null) {
        ref.read(unreadCountProvider.notifier).clear();
      } else {
        ref.read(unreadCountProvider.notifier).refresh();
      }
    }

    // 登录、退出或切换账号后为新账号重新获取（旧账号的计数不会显示）
    ref.listen(homeDrawerHeaderProvider.select((user) => user?.uid), (
      previous,
      next,
    ) {
      if (previous != next) refreshUnread();
    });

    useEffect(() {
      Future.microtask(() async {
        final before = ref.read(homeDrawerHeaderProvider)?.uid;
        try {
          await ref.read(homeDrawerHeaderProvider.notifier).refresh();
        } catch (_) {
          // 用户信息刷新失败时仍按当前账号刷新角标
        }
        if (!context.mounted) return;
        // 账号变化时由上面的监听负责，避免重复请求
        if (ref.read(homeDrawerHeaderProvider)?.uid == before) refreshUnread();
      });
      return null;
    }, []);

    final mediaPadding = MediaQuery.paddingOf(context);
    final communityGroup = M3SettingsGroup(
      title: '社区',
      children: [
        M3SettingsTile(
          icon: Icons.bookmark_outline,
          title: '贴子收藏',
          subtitle: '收藏的贴子',
          onTap: () => Routes.navigateTo(context, Routes.FAVOURITE_TOPICS),
        ),
        M3SettingsTile(
          icon: Icons.history_outlined,
          title: '浏览历史',
          subtitle: '最近浏览的贴子',
          onTap: () => Routes.navigateTo(context, Routes.TOPIC_HISTORY),
        ),
        // 从短消息 / 提醒页返回后刷新角标
        M3SettingsTile(
          icon: Icons.mail_outlined,
          title: '短消息',
          subtitle: '私信会话',
          badgeCount: unread.messages,
          onTap: () => Routes.navigateTo(
            context,
            Routes.CONVERSATIONS,
          ).whenComplete(refreshUnread),
        ),
        M3SettingsTile(
          icon: Icons.notifications_outlined,
          title: '提醒信息',
          subtitle: '回复与系统通知',
          badgeCount: unread.notifications,
          onTap: () => Routes.navigateTo(
            context,
            Routes.NOTIFICATIONS,
          ).whenComplete(refreshUnread),
        ),
      ],
    );
    final appGroup = M3SettingsGroup(
      title: '应用',
      children: [
        M3SettingsTile(
          icon: Icons.settings_outlined,
          title: '设置',
          subtitle: '主题、网络与屏蔽',
          onTap: () => Routes.navigateTo(context, Routes.SETTINGS),
        ),
        M3SettingsTile(
          icon: Icons.info_outline,
          title: '关于',
          subtitle: '版本与开源信息',
          onTap: () => Routes.navigateTo(context, Routes.ABOUT),
        ),
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final isTwoColumn = constraints.maxWidth >= 720;
        final basePadding = EdgeInsets.fromLTRB(
          mediaPadding.left,
          Dimen.spacingS,
          mediaPadding.right,
          Dimen.spacingL + mediaPadding.bottom,
        );
        final listPadding = readableListPadding(
          constraints.maxWidth,
          base: basePadding,
          maxWidth: isTwoColumn ? 1000 : kReadableMaxWidth,
        );

        return ListView(
          padding: listPadding,
          children: [
            _UserHeaderCard(userInfo: userInfo),
            if (isTwoColumn)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: communityGroup),
                  const SizedBox(width: Dimen.spacingS),
                  Expanded(child: appGroup),
                ],
              )
            else ...[
              communityGroup,
              appGroup,
            ],
          ],
        );
      },
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
                Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
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
