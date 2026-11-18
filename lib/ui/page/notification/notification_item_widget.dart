import 'package:material_ui/material_ui.dart';
import 'package:flutter_nga/data/entity/notification.dart';
import 'package:flutter_nga/ui/page/topic_detail/reply_detail_dialog.dart';
import 'package:flutter_nga/utils/code_utils.dart' as code_utils;
import 'package:flutter_nga/utils/route.dart';

/// 单条提醒：点击跳转到关联的主题 / 回复 / 对话 / 版面，长按弹出更多操作。
class NotificationItemWidget extends StatelessWidget {
  final NgaNotification notification;

  /// 长按菜单中「不再提示」的回调，为空时不显示该项。
  final ValueChanged<NoHintTarget>? onNoHint;

  const NotificationItemWidget({
    super.key,
    required this.notification,
    this.onNoHint,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final description = notification.describe();
    final target = notification.target;
    final menuActions = _menuActions(context);

    return InkWell(
      onTap: target == null
          ? null
          : () => openNotificationTarget(context, notification),
      onLongPress: menuActions.isEmpty
          ? null
          : () => _showMenu(context, menuActions),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Row(
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
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                          ),
                        TextSpan(text: description.action),
                      ],
                    ),
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                  if (description.detail != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      description.detail!,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  if (notification.time > 0) ...[
                    const SizedBox(height: 4),
                    Text(
                      code_utils.formatPostDate(notification.time * 1000),
                      style: textTheme.labelSmall?.copyWith(
                        color: colorScheme.outline,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<_MenuAction> _menuActions(BuildContext context) {
    final actions = <_MenuAction>[];
    final topicId = notification.topicId;
    if (topicId != null && notification.target is! TopicTarget) {
      actions.add(
        _MenuAction(
          icon: Icons.article_outlined,
          label: '进入主题',
          onTap: () =>
              Routes.navigateTo(context, "${Routes.TOPIC_DETAIL}?tid=$topicId"),
        ),
      );
    }
    if (notification.hasActor) {
      final name = notification.fromUsername ?? 'UID:${notification.fromUid}';
      actions.add(
        _MenuAction(
          icon: Icons.person_outline,
          label: '查看 $name 的主页',
          onTap: () => Routes.navigateTo(
            context,
            "${Routes.USER}?uid=${notification.fromUid}",
          ),
        ),
      );
    }
    final noHint = notification.noHintTarget;
    if (noHint != null && onNoHint != null) {
      actions.add(
        _MenuAction(
          icon: Icons.notifications_off_outlined,
          label: noHint.isTopic ? '不再提示此主题的回复或评论' : '不再提示此回复的回复或评论',
          onTap: () => onNoHint!(noHint),
        ),
      );
    }
    return actions;
  }

  void _showMenu(BuildContext context, List<_MenuAction> actions) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
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
      final name = Uri.encodeQueryComponent('版面 $fid');
      Routes.navigateTo(
        context,
        "${Routes.FORUM_DETAIL}?fid=$fid&name=$name&type=0",
      );
    case null:
      break;
  }
}

class _MenuAction {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}

class _NotificationIcon extends StatelessWidget {
  final NgaNotification notification;

  const _NotificationIcon({required this.notification});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final (icon, background, foreground) = switch (notification.type) {
      NgaNotification.TYPE_MENTION_TOPIC ||
      NgaNotification.TYPE_MENTION_REPLY => (
        Icons.alternate_email,
        colorScheme.tertiaryContainer,
        colorScheme.onTertiaryContainer,
      ),
      NgaNotification.TYPE_COMMENT_TOPIC ||
      NgaNotification.TYPE_COMMENT_REPLY => (
        Icons.comment_outlined,
        colorScheme.primaryContainer,
        colorScheme.onPrimaryContainer,
      ),
      NgaNotification.TYPE_RECOMMEND_POST || NgaNotification.TYPE_UPVOTE => (
        Icons.thumbs_up_down_outlined,
        colorScheme.secondaryContainer,
        colorScheme.onSecondaryContainer,
      ),
      _ => switch (notification.category) {
        NotificationCategory.reply => (
          Icons.reply,
          colorScheme.primaryContainer,
          colorScheme.onPrimaryContainer,
        ),
        NotificationCategory.message => (
          Icons.mail_outline,
          colorScheme.secondaryContainer,
          colorScheme.onSecondaryContainer,
        ),
        NotificationCategory.moderation => (
          Icons.shield_outlined,
          colorScheme.surfaceContainerHighest,
          colorScheme.onSurfaceVariant,
        ),
        NotificationCategory.system => (
          Icons.info_outline,
          colorScheme.errorContainer,
          colorScheme.onErrorContainer,
        ),
      },
    };
    return CircleAvatar(
      radius: 18,
      backgroundColor: background,
      child: Icon(icon, size: 18, color: foreground),
    );
  }
}
