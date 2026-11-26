import 'package:cupertino_ui/cupertino_ui.dart' show CupertinoIcons;
import 'package:material_ui/material_ui.dart';
import 'package:flutter_nga/data/entity/notification.dart';
import 'package:flutter_nga/providers/settings/design_style_provider.dart';
import 'package:flutter_nga/ui/page/topic_detail/reply_detail_dialog.dart';
import 'package:flutter_nga/ui/widget/adaptive/app_action_menu.dart';
import 'package:flutter_nga/ui/widget/adaptive/app_icons.dart';
import 'package:flutter_nga/ui/widget/m3_dialog.dart';
import 'package:flutter_nga/utils/code_utils.dart' as code_utils;
import 'package:flutter_nga/utils/route.dart';

/// 单条提醒：点击跳转到关联的主题 / 回复 / 对话 / 版块，长按弹出更多操作。
class NotificationItemWidget extends StatelessWidget {
  final NgaNotification notification;

  /// 长按菜单中「不再提示」的回调，为空时不显示该项。
  final ValueChanged<NoHintTarget>? onNoHint;

  /// 自定义点击回调（如大屏双栏时在右侧打开目标内容）
  final VoidCallback? onTap;

  /// 是否在大屏双栏列表中处于选中状态
  final bool selected;

  const NotificationItemWidget({
    super.key,
    required this.notification,
    this.onNoHint,
    this.onTap,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isApple = context.isAppleStyle;
    final isMac = context.isMacDesktopAppleStyle;
    final description = notification.describe();
    final target = notification.target;
    final menuActions = _menuActions(context);

    final handleTap = target == null
        ? null
        : (onTap ?? () => openNotificationTarget(context, notification));
    final handleLongPress = menuActions.isEmpty
        ? null
        : () => _showMenu(context, menuActions);

    final bodyContent = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _NotificationIcon(notification: notification),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    if (description.actor != null)
                      TextSpan(
                        text: '${description.actor} ',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.primary,
                        ),
                      ),
                    TextSpan(text: description.action),
                  ],
                ),
                style: isApple
                    ? TextStyle(
                        fontSize: isMac ? 13.5 : 14.5,
                        height: 1.35,
                        color: colorScheme.onSurface,
                      )
                    : textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface,
                      ),
              ),
              if (description.detail != null) ...[
                const SizedBox(height: 4),
                Text(
                  description.detail!,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: isApple
                      ? TextStyle(
                          fontSize: isMac ? 12 : 13,
                          height: 1.35,
                          color: colorScheme.onSurfaceVariant,
                        )
                      : textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                ),
              ],
              if (notification.time > 0) ...[
                const SizedBox(height: 4),
                Text(
                  code_utils.formatPostDate(notification.time * 1000),
                  style: isApple
                      ? TextStyle(
                          fontSize: isMac ? 11.5 : 12,
                          color: colorScheme.outline,
                        )
                      : textTheme.labelSmall?.copyWith(
                          color: colorScheme.outline,
                        ),
                ),
              ],
            ],
          ),
        ),
      ],
    );

    if (isApple) {
      final selectedBg = colorScheme.primary.withValues(
        alpha: Theme.of(context).brightness == Brightness.dark ? 0.22 : 0.14,
      );
      final padded = Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isMac ? 12 : 16,
          vertical: isMac ? 9 : 11,
        ),
        child: bodyContent,
      );

      if (isMac) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              child: GestureDetector(
                onSecondaryTapDown: menuActions.isEmpty
                    ? null
                    : (details) => _showMenu(
                        context,
                        menuActions,
                        globalPosition: details.globalPosition,
                      ),
                child: Material(
                  color: selected ? selectedBg : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: handleTap,
                    onLongPress: handleLongPress,
                    child: padded,
                  ),
                ),
              ),
            ),
            if (!selected)
              Divider(
                height: 0.5,
                thickness: 0.5,
                indent: 58,
                endIndent: 18,
                color: colorScheme.outlineVariant,
              ),
          ],
        );
      }

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onSecondaryTapDown: menuActions.isEmpty
                ? null
                : (details) => _showMenu(
                    context,
                    menuActions,
                    globalPosition: details.globalPosition,
                  ),
            child: Material(
              color: selected ? selectedBg : Colors.transparent,
              child: InkWell(
                onTap: handleTap,
                onLongPress: handleLongPress,
                child: padded,
              ),
            ),
          ),
          Divider(
            height: 0.5,
            thickness: 0.5,
            indent: 62,
            color: colorScheme.outlineVariant,
          ),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onSecondaryTapDown: menuActions.isEmpty
              ? null
              : (details) => _showMenu(
                  context,
                  menuActions,
                  globalPosition: details.globalPosition,
                ),
          child: Material(
            color: selected
                ? colorScheme.secondaryContainer.withValues(alpha: 0.45)
                : Colors.transparent,
            child: InkWell(
              onTap: handleTap,
              onLongPress: handleLongPress,
              child: DecoratedBox(
                decoration: selected
                    ? BoxDecoration(
                        border: Border(
                          left: BorderSide(
                            color: colorScheme.primary,
                            width: 3,
                          ),
                        ),
                      )
                    : const BoxDecoration(),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(selected ? 13 : 16, 12, 16, 12),
                  child: bodyContent,
                ),
              ),
            ),
          ),
        ),
        Divider(
          height: 1,
          thickness: 1,
          indent: 64,
          color: colorScheme.surfaceContainerHighest,
        ),
      ],
    );
  }

  List<_MenuAction> _menuActions(BuildContext context) {
    final actions = <_MenuAction>[];
    final topicId = notification.topicId;
    if (topicId != null && notification.target is! TopicTarget) {
      actions.add((
        icon: AppIcons.resolve(context, Icons.article_outlined),
        label: '进入主题',
        onTap: () =>
            Routes.navigateTo(context, "${Routes.TOPIC_DETAIL}?tid=$topicId"),
      ));
    }
    if (notification.hasActor) {
      final name = notification.fromUsername ?? 'UID:${notification.fromUid}';
      actions.add((
        icon: AppIcons.person(context),
        label: '查看 $name 的主页',
        onTap: () => Routes.navigateTo(
          context,
          "${Routes.USER}?uid=${notification.fromUid}",
        ),
      ));
    }
    final noHint = notification.noHintTarget;
    if (noHint != null && onNoHint != null) {
      actions.add((
        icon: AppIcons.resolve(context, Icons.notifications_off_outlined),
        label: noHint.isTopic ? '不再提示此主题的回复或评论' : '不再提示此回复的回复或评论',
        onTap: () => onNoHint!(noHint),
      ));
    }
    return actions;
  }

  Future<void> _showMenu(
    BuildContext context,
    List<_MenuAction> actions, {
    Offset? globalPosition,
  }) async {
    if (context.isAppleStyle || globalPosition != null) {
      final chosen = await showAppActionMenu<int>(
        context: context,
        globalPosition: globalPosition,
        actions: [
          for (var i = 0; i < actions.length; i++)
            AppMenuAction<int>(
              value: i,
              label: actions[i].label,
              icon: actions[i].icon,
            ),
        ],
      );
      if (chosen != null && context.mounted) {
        actions[chosen].onTap();
      }
      return;
    }

    await showM3SelectionSheet<void>(
      context: context,
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final action in actions)
              ListTile(
                leading: Icon(action.icon),
                title: Text(action.label),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  action.onTap();
                },
              ),
          ],
        ),
      ),
    );
  }
}

/// 按提醒的跳转目标打开对应页面。
void openNotificationTarget(
  BuildContext context,
  NgaNotification notification,
) {
  switch (notification.target) {
    case TopicTarget(:final tid):
      Routes.navigateTo(context, "${Routes.TOPIC_DETAIL}?tid=$tid");
    case ReplyTarget(:final tid, :final pid):
      showDialog<void>(
        context: context,
        builder: (_) => ReplyDetailDialog(pid: pid, tid: tid),
      );
    case ConversationTarget(:final mid):
      Routes.navigateTo(context, "${Routes.CONVERSATION_DETAIL}?mid=$mid");
    case ForumTarget(:final fid):
      Routes.navigateToWithParams(context, Routes.FORUM_DETAIL, {
        'fid': '$fid',
        'name': '版块 $fid',
        'type': '0',
      });
    case null:
      break;
  }
}

typedef _MenuAction = ({IconData icon, String label, VoidCallback onTap});

class _NotificationIcon extends StatelessWidget {
  final NgaNotification notification;

  const _NotificationIcon({required this.notification});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isApple = context.isAppleStyle;
    final (icon, background, foreground) = switch (notification.type) {
      NgaNotification.TYPE_MENTION_TOPIC ||
      NgaNotification.TYPE_MENTION_REPLY => (
        isApple ? CupertinoIcons.at : Icons.alternate_email,
        colorScheme.tertiaryContainer,
        colorScheme.onTertiaryContainer,
      ),
      NgaNotification.TYPE_COMMENT_TOPIC ||
      NgaNotification.TYPE_COMMENT_REPLY => (
        isApple ? CupertinoIcons.chat_bubble_text : Icons.comment_outlined,
        colorScheme.primaryContainer,
        colorScheme.onPrimaryContainer,
      ),
      NgaNotification.TYPE_RECOMMEND_POST || NgaNotification.TYPE_UPVOTE => (
        isApple ? CupertinoIcons.hand_thumbsup : Icons.thumbs_up_down_outlined,
        colorScheme.secondaryContainer,
        colorScheme.onSecondaryContainer,
      ),
      _ => switch (notification.category) {
        NotificationCategory.reply => (
          isApple ? CupertinoIcons.arrowshape_turn_up_left : Icons.reply,
          colorScheme.primaryContainer,
          colorScheme.onPrimaryContainer,
        ),
        NotificationCategory.message => (
          isApple ? CupertinoIcons.chat_bubble_2 : Icons.mail_outline,
          colorScheme.secondaryContainer,
          colorScheme.onSecondaryContainer,
        ),
        NotificationCategory.moderation => (
          isApple ? CupertinoIcons.shield : Icons.shield_outlined,
          colorScheme.surfaceContainerHighest,
          colorScheme.onSurfaceVariant,
        ),
        NotificationCategory.system => (
          isApple ? CupertinoIcons.info_circle : Icons.info_outline,
          colorScheme.errorContainer,
          colorScheme.onErrorContainer,
        ),
      },
    };
    if (isApple) {
      return Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: background.withValues(alpha: 0.75),
          borderRadius: BorderRadius.circular(9),
        ),
        child: Icon(icon, size: 17, color: foreground),
      );
    }
    return CircleAvatar(
      radius: 18,
      backgroundColor: background,
      child: Icon(icon, size: 18, color: foreground),
    );
  }
}
