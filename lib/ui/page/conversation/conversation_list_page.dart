import 'package:easy_refresh/easy_refresh.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_nga/providers/message/conversation_list_provider.dart';
import 'package:flutter_nga/ui/widget/list_status_view.dart';
import 'package:flutter_nga/utils/app_toast.dart';
import 'package:flutter_nga/utils/hooks/easy_refresh_hooks.dart';
import 'package:flutter_nga/utils/hooks/list_load_status.dart';
import 'package:flutter_nga/utils/route.dart';

import 'conversation_item_widget.dart';

class ConversationListPage extends HookConsumerWidget {
  const ConversationListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final refreshController = useEasyRefreshController(controlFinishLoad: true);
    final loadStatus = useListLoadStatus();
    final state = ref.watch(conversationListProvider);
    final notifier = ref.read(conversationListProvider.notifier);

    Future<void> onRefresh() async {
      try {
        await notifier.refresh();
        if (!context.mounted) return;
        loadStatus.succeed();
        refreshController.finishRefresh();
        refreshController.resetFooter();
      } catch (err) {
        if (!context.mounted) return;
        refreshController.finishRefresh(IndicatorResult.fail);
        final hasData = ref.read(conversationListProvider).list.isNotEmpty;
        if (!loadStatus.fail(err, hasData: hasData)) AppToast.error(err);
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

    useInitialRefresh(refreshController);

    return Scaffold(
      appBar: AppBar(
        title: const Text('短消息'),
        actions: [
          IconButton(
            tooltip: '屏蔽用户',
            icon: const Icon(Icons.block),
            onPressed: () =>
                Routes.navigateTo(context, Routes.MESSAGE_BLOCKLIST),
          ),
        ],
      ),
      body: EasyRefresh(
        controller: refreshController,
        onRefresh: onRefresh,
        onLoad: state.enablePullUp ? onLoading : null,
        child: ListStatusSwitcher(
          status: loadStatus,
          isEmpty: state.list.isEmpty,
          emptyMessage: '暂无短消息',
          emptyIcon: Icons.mail_outline,
          onRetry: refreshController.callRefresh,
          child: ListView.builder(
            itemCount: state.list.length,
            itemBuilder: (context, index) => ConversationItemWidget(
              conversation: state.list[index],
              onLeft: refreshController.callRefresh,
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: '新建短消息',
        onPressed: () async {
          final sent = await Routes.navigateTo(
            context,
            "${Routes.SEND_MESSAGE}?mid=0",
          );
          if (sent == true && context.mounted) refreshController.callRefresh();
        },
        child: const Icon(Icons.edit_outlined),
      ),
    );
  }
}
