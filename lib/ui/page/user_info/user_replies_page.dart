import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nga/providers/user/user_replies_provider.dart';
import 'package:flutter_nga/ui/widget/topic_list_item_widget.dart';
import 'package:flutter_nga/utils/app_toast.dart';
import 'package:flutter_nga/utils/hooks/easy_refresh_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class UserRepliesPage extends HookConsumerWidget {
  final int uid;
  final String username;

  const UserRepliesPage({
    super.key,
    required this.uid,
    required this.username,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final refreshController = useEasyRefreshController(controlFinishLoad: true);
    final state = ref.watch(userRepliesProvider);
    final notifier = ref.read(userRepliesProvider.notifier);

    Future<void> onRefresh() async {
      try {
        await notifier.refresh(uid);
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
        final next = await notifier.loadMore(uid);
        if (!context.mounted) return;
        if (next.list.length == next.page * next.size) {
          refreshController.finishLoad();
        } else {
          refreshController.finishLoad(IndicatorResult.noMore);
        }
      } catch (err, stack) {
        if (!context.mounted) return;
        AppToast.error(err);
        debugPrintStack(stackTrace: stack);
        refreshController.finishLoad(IndicatorResult.fail);
      }
    }

    useInitialRefresh(refreshController);

    return Scaffold(
      appBar: AppBar(title: Text("$username发布的回复")),
      body: EasyRefresh(
        controller: refreshController,
        onRefresh: onRefresh,
        onLoad: state.enablePullUp ? onLoading : null,
        child: ListView.builder(
          itemCount: state.list.length,
          itemBuilder: (context, index) =>
              TopicListItemWidget(topic: state.list[index]),
        ),
      ),
    );
  }
}
