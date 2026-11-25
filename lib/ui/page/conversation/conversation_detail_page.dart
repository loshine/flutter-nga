import 'package:easy_refresh/easy_refresh.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_nga/data/entity/message.dart';
import 'package:flutter_nga/providers/message/conversation_detail_provider.dart';
import 'package:flutter_nga/providers/message/send_message_provider.dart';
import 'package:flutter_nga/ui/page/send_message/contact_edit_dialog.dart';
import 'package:flutter_nga/ui/widget/m3_dialog.dart';
import 'package:flutter_nga/ui/widget/readable_width.dart';
import 'package:flutter_nga/utils/app_toast.dart';
import 'package:flutter_nga/utils/hooks/easy_refresh_hooks.dart';
import 'package:flutter_nga/utils/route.dart';

import 'message_item_widget.dart';

enum _MenuAction { invite, leave }

class ConversationDetailPage extends HookConsumerWidget {
  final int mid;

  /// 是否作为大屏双栏布局的右侧内嵌面板展示
  final bool embedded;

  /// 内嵌模式下退出对话成功后的回调（替代路由 pop）
  final VoidCallback? onLeft;

  /// 内嵌模式下关闭详情面板的回调
  final VoidCallback? onClose;

  const ConversationDetailPage({
    super.key,
    required this.mid,
    this.embedded = false,
    this.onLeft,
    this.onClose,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final refreshController = useEasyRefreshController(controlFinishLoad: true);
    final provider = conversationDetailProvider(mid);
    final state = ref.watch(provider);
    final notifier = ref.read(provider.notifier);

    Future<void> onRefresh() async {
      try {
        await notifier.refresh();
        if (!context.mounted) return;
        refreshController.finishRefresh();
        refreshController.resetFooter();
      } catch (err) {
        if (!context.mounted) return;
        refreshController.finishRefresh(IndicatorResult.fail);
        AppToast.error(err);
      }
    }

    Future<void> onLoading() async {
      try {
        final next = await notifier.loadMore();
        if (!context.mounted) return;
        if (next.enablePullUp) {
          refreshController.finishLoad();
        } else {
          refreshController.finishLoad(IndicatorResult.noMore);
        }
      } catch (_) {
        if (!context.mounted) return;
        refreshController.finishLoad(IndicatorResult.fail);
      }
    }

    Future<void> reply() async {
      final sent = await Routes.navigateTo(
        context,
        "${Routes.SEND_MESSAGE}?mid=$mid",
      );
      if (sent == true && context.mounted) refreshController.callRefresh();
    }

    void invite() {
      showDialog<void>(
        context: context,
        builder: (_) => ContactEditDialog(
          title: '邀请用户加入对话',
          callback: (text) async {
            final users = splitMessageUsers(text);
            if (users.isEmpty) return;
            try {
              final message = await notifier.invite(users);
              AppToast.success(message ?? '已邀请');
            } catch (err) {
              AppToast.error(err);
            }
          },
        ),
      );
    }

    Future<void> leave() async {
      final confirmed = await _confirm(
        context,
        title: '退出对话',
        content: '退出对话后将无法再看到对话内容。',
        action: '退出',
      );
      if (!confirmed) return;
      try {
        final message = await notifier.leave();
        AppToast.success(message ?? '已退出对话');
        if (!context.mounted) return;
        if (embedded) {
          onLeft?.call();
        } else {
          Routes.pop(context, true);
        }
      } catch (err) {
        AppToast.error(err);
      }
    }

    Future<void> removeParticipant(MessageParticipant participant) async {
      final confirmed = await _confirm(
        context,
        title: '移出对话',
        content: '将 ${participant.username} 移出对话后，对方将无法再看到对话内容。',
        action: '移出',
      );
      if (!confirmed) return;
      try {
        final message = await notifier.remove(participant);
        AppToast.success(message ?? '已移出');
      } catch (err) {
        AppToast.error(err);
      }
    }

    useInitialRefresh(refreshController);

    final hasHeader = state.participants.isNotEmpty || state.isIsolated;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: !embedded,
        centerTitle: embedded ? false : null,
        title: const Text('消息详情'),
        actions: [
          PopupMenuButton<_MenuAction>(
            onSelected: (action) => switch (action) {
              _MenuAction.invite => invite(),
              _MenuAction.leave => leave(),
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: _MenuAction.invite,
                child: ListTile(
                  leading: Icon(Icons.person_add_alt_outlined),
                  title: Text('邀请用户加入'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              PopupMenuItem(
                value: _MenuAction.leave,
                child: ListTile(
                  leading: Icon(Icons.logout),
                  title: Text('退出对话'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
          if (embedded && onClose != null)
            IconButton(
              tooltip: '关闭',
              icon: const Icon(Icons.close),
              onPressed: onClose,
            ),
        ],
      ),
      body: EasyRefresh(
        controller: refreshController,
        onRefresh: onRefresh,
        onLoad: state.enablePullUp ? onLoading : null,
        child: ReadableListPadding(
          builder: (context, padding) => ListView.builder(
            padding: padding,
            itemCount: state.list.length + (hasHeader ? 1 : 0),
            itemBuilder: (context, index) {
              if (hasHeader && index == 0) {
                return ConversationParticipantsHeader(
                  participants: state.participants,
                  isIsolated: state.isIsolated,
                  canRemove: state.canRemove,
                  onRemove: removeParticipant,
                );
              }
              return MessageItemWidget(
                message: state.list[index - (hasHeader ? 1 : 0)],
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: '回复',
        onPressed: reply,
        child: const Icon(Icons.reply),
      ),
    );
  }

  Future<bool> _confirm(
    BuildContext context, {
    required String title,
    required String content,
    required String action,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => M3ConfirmDialog(
        title: title,
        content: content,
        confirmText: action,
        destructive: true,
      ),
    );
    return result == true;
  }
}

/// 对话顶部的参与者列表；发起人可以把其他人移出对话。
class ConversationParticipantsHeader extends StatelessWidget {
  final List<MessageParticipant> participants;
  final bool isIsolated;
  final bool Function(MessageParticipant) canRemove;
  final ValueChanged<MessageParticipant> onRemove;

  const ConversationParticipantsHeader({
    super.key,
    required this.participants,
    required this.isIsolated,
    required this.canRemove,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '参与对话的用户',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              for (final participant in participants)
                InputChip(
                  label: Text(participant.username),
                  onPressed: () => Routes.navigateTo(
                    context,
                    "${Routes.USER}?uid=${participant.uid}",
                  ),
                  onDeleted: canRemove(participant)
                      ? () => onRemove(participant)
                      : null,
                  deleteButtonTooltipMessage: '移出对话',
                ),
            ],
          ),
          if (isIsolated) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.visibility_off_outlined,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  '对话参与者的回复互相不可见',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 8),
          const Divider(height: 1),
        ],
      ),
    );
  }
}
