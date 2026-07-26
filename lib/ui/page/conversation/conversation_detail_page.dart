import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nga/providers/message/conversation_detail_provider.dart';
import 'package:flutter_nga/utils/hooks/easy_refresh_hooks.dart';
import 'package:flutter_nga/utils/route.dart';
import 'package:flutter_nga/utils/app_toast.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'message_item_widget.dart';

class ConversationDetailPage extends HookConsumerWidget {
  final int? mid;

  const ConversationDetailPage({super.key, this.mid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final refreshController = useEasyRefreshController(controlFinishLoad: true);
    final state = ref.watch(conversationDetailProvider);
    final notifier = ref.read(conversationDetailProvider.notifier);

    Future<void> onRefresh() async {
      try {
        await notifier.refresh(mid);
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
        final next = await notifier.loadMore(mid);
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
        title: Text('消息详情'),
      ),
      body: EasyRefresh(
        controller: refreshController,
        onRefresh: onRefresh,
        onLoad: state.enablePullUp ? onLoading : null,
        child: ListView.builder(
          itemCount: state.list.length,
          itemBuilder: (context, index) =>
              MessageItemWidget(message: state.list[index]),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: '回复',
        onPressed: () => Routes.navigateTo(
          context,
          "${Routes.SEND_MESSAGE}?mid=$mid",
        ),
        child: Icon(Icons.reply),
      ),
    );
  }
}
