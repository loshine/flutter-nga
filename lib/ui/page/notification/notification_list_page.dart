import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_nga/data/entity/notification.dart';
import 'package:flutter_nga/providers/notification/notification_list_provider.dart';
import 'package:flutter_nga/ui/page/conversation/conversation_detail_page.dart';
import 'package:flutter_nga/ui/page/topic_detail/topic_detail_page.dart';
import 'package:flutter_nga/ui/widget/adaptive/app_icons.dart';
import 'package:flutter_nga/ui/widget/adaptive/app_scaffold.dart';
import 'package:flutter_nga/ui/widget/adaptive_layout.dart';
import 'package:flutter_nga/ui/widget/list_status_view.dart';
import 'package:flutter_nga/ui/widget/m3_dialog.dart';
import 'package:flutter_nga/ui/widget/readable_width.dart';
import 'package:flutter_nga/utils/app_toast.dart';
import 'package:flutter_nga/utils/hooks/easy_refresh_hooks.dart';
import 'package:flutter_nga/utils/hooks/list_load_status.dart';

import 'notification_item_widget.dart';

class NotificationListPage extends HookConsumerWidget {
  const NotificationListPage({
    super.key,
    this.embedded = false,
    this.showAppBar = true,
    this.leading,
  });

  final bool embedded;
  final bool showAppBar;
  final Widget? leading;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final refreshController = useEasyRefreshController();
    final loadStatus = useListLoadStatus();
    final selectedNotification = useState<NgaNotification?>(null);
    final state = ref.watch(notificationListProvider);
    final notifier = ref.read(notificationListProvider.notifier);

    Future<void> onRefresh() async {
      try {
        await notifier.refresh();
        if (!context.mounted) return;
        loadStatus.succeed();
        refreshController.finishRefresh();
      } catch (err) {
        if (!context.mounted) return;
        refreshController.finishRefresh(IndicatorResult.fail);
        final hasData = ref
            .read(notificationListProvider)
            .notifications
            .isNotEmpty;
        if (!loadStatus.fail(err, hasData: hasData)) AppToast.error(err);
      }
    }

    Future<void> onNoHint(NoHintTarget target) async {
      try {
        await notifier.setNoHint(target);
        AppToast.success(target.isTopic ? '已不再提示此主题' : '已不再提示此回复');
      } catch (err) {
        AppToast.error(err);
      }
    }

    useInitialRefresh(refreshController);

    final entries = <Object>[
      for (final section in state.sections) ...[section.key, ...section.value],
    ];

    void onNotificationTap(NgaNotification notification) {
      switch (notification.target) {
        case TopicTarget() || ConversationTarget():
          selectedNotification.value = notification;
        default:
          openNotificationTarget(context, notification);
      }
    }

    return MasterDetailLayout(
      masterBuilder: (context, isTwoPane) => AppScaffold(
        embedded: embedded,
        showAppBar: showAppBar,
        leading: leading,
        title: const Text('提醒信息'),
        actions: [
          IconButton(
            tooltip: '清空提醒',
            icon: Icon(AppIcons.delete(context)),
            onPressed: state.notifications.isEmpty
                ? null
                : () => _confirmClear(
                    context,
                    notifier,
                    onCleared: () => selectedNotification.value = null,
                  ),
          ),
        ],
        body: EasyRefresh(
          controller: refreshController,
          onRefresh: onRefresh,
          child: ListStatusSwitcher(
            status: loadStatus,
            isEmpty: entries.isEmpty,
            emptyMessage: '暂无提醒',
            emptyIcon: Icons.notifications_none_outlined,
            onRetry: refreshController.callRefresh,
            child: ReadableListPadding(
              builder: (context, padding) => ListView.builder(
                padding: padding,
                itemCount: entries.length,
                itemBuilder: (context, index) {
                  final entry = entries[index];
                  if (entry is NotificationCategory) {
                    return _SectionHeader(category: entry);
                  }
                  final notification = entry as NgaNotification;
                  return NotificationItemWidget(
                    notification: notification,
                    selected:
                        isTwoPane && selectedNotification.value == notification,
                    onTap: isTwoPane
                        ? () => onNotificationTap(notification)
                        : null,
                    onNoHint: onNoHint,
                  );
                },
              ),
            ),
          ),
        ),
      ),
      detailBuilder: (context) {
        final target = selectedNotification.value?.target;
        return switch (target) {
          TopicTarget(:final tid) => TopicDetailPage(
            tid,
            null,
            key: ValueKey('embedded-notification-topic-$tid'),
            embedded: true,
            onClose: () => selectedNotification.value = null,
          ),
          ConversationTarget(:final mid) => ConversationDetailPage(
            key: ValueKey('embedded-notification-conversation-$mid'),
            mid: mid,
            embedded: true,
            onLeft: () => selectedNotification.value = null,
            onClose: () => selectedNotification.value = null,
          ),
          _ => const MasterDetailEmptyPlaceholder(
            icon: Icons.notifications_none_outlined,
            title: '选择一条提醒查看详情',
            subtitle: '主题与私信提醒将在此处直接展示',
          ),
        };
      },
    );
  }

  void _confirmClear(
    BuildContext context,
    NotificationListNotifier notifier, {
    VoidCallback? onCleared,
  }) {
    showDialog<void>(
      context: context,
      builder: (_) => M3ConfirmDialog(
        title: '清空提醒',
        content: '将删除信箱中的全部提醒，清空后无法恢复。',
        confirmText: '清空',
        destructive: true,
        onConfirm: () async {
          try {
            await notifier.clear();
            onCleared?.call();
            AppToast.success('已清空提醒');
          } catch (err) {
            AppToast.error(err);
          }
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final NotificationCategory category;

  const _SectionHeader({required this.category});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        category.label,
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
