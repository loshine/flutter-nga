import 'package:easy_refresh/easy_refresh.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_nga/data/entity/notification.dart';
import 'package:flutter_nga/providers/notification/notification_list_provider.dart';
import 'package:flutter_nga/ui/widget/list_status_view.dart';
import 'package:flutter_nga/utils/app_toast.dart';
import 'package:flutter_nga/utils/hooks/easy_refresh_hooks.dart';
import 'package:flutter_nga/utils/hooks/list_load_status.dart';
import 'package:flutter_nga/utils/route.dart';

import 'notification_item_widget.dart';

class NotificationListPage extends HookConsumerWidget {
  const NotificationListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final refreshController = useEasyRefreshController();
    final loadStatus = useListLoadStatus();
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('提醒信息'),
        actions: [
          IconButton(
            tooltip: '清空提醒',
            icon: const Icon(Icons.delete_sweep_outlined),
            onPressed: state.notifications.isEmpty
                ? null
                : () => _confirmClear(context, notifier),
          ),
        ],
      ),
      body: EasyRefresh(
        controller: refreshController,
        onRefresh: onRefresh,
        child: ListStatusSwitcher(
          status: loadStatus,
          isEmpty: entries.isEmpty,
          emptyMessage: '暂无提醒',
          emptyIcon: Icons.notifications_none_outlined,
          onRetry: refreshController.callRefresh,
          child: ListView.builder(
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];
              if (entry is NotificationCategory) {
                return _SectionHeader(category: entry);
              }
              return NotificationItemWidget(
                notification: entry as NgaNotification,
                onNoHint: onNoHint,
              );
            },
          ),
        ),
      ),
    );
  }

  void _confirmClear(BuildContext context, NotificationListNotifier notifier) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('清空提醒'),
        content: const Text('将删除信箱中的全部提醒，清空后无法恢复。'),
        actions: [
          TextButton(
            onPressed: () => Routes.pop(dialogContext),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Routes.pop(dialogContext);
              try {
                await notifier.clear();
                AppToast.success('已清空提醒');
              } catch (err) {
                AppToast.error(err);
              }
            },
            child: const Text('清空'),
          ),
        ],
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
