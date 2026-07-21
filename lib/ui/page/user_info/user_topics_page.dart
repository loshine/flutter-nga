import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nga/providers/user/user_topics_provider.dart';
import 'package:flutter_nga/ui/widget/topic_list_item_widget.dart';
import 'package:flutter_nga/utils/app_toast.dart';
import 'package:flutter_nga/utils/hooks/easy_refresh_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class UserTopicsPage extends HookConsumerWidget {
  final int uid;
  final String username;

  const UserTopicsPage({
    super.key,
    required this.uid,
    required this.username,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final refreshController = useEasyRefreshController(controlFinishLoad: true);
    final state = ref.watch(userTopicsProvider);
    final notifier = ref.read(userTopicsProvider.notifier);

    Future<void> onRefresh() async {
      try {
        await notifier.refresh(uid);
        if (!context.mounted) return;
        refreshController.finishRefresh();
        refreshController.resetFooter();
      } catch (err) {
        if (!context.mounted) return;
        refreshController.finishRefresh(IndicatorResult.fail);
        AppToast.error((err as dynamic).message ?? err.toString());
      }
    }

    Future<void> onLoading() async {
      try {
        final next = await notifier.loadMore(uid);
        if (!context.mounted) return;
        if (next.page + 1 < next.maxPage) {
          refreshController.finishLoad();
        } else {
          refreshController.finishLoad(IndicatorResult.noMore);
        }
      } catch (_) {
        if (!context.mounted) return;
        refreshController.finishLoad(IndicatorResult.fail);
      }
    }

    usePostFrameEffect(onRefresh);

    return Scaffold(
      appBar: AppBar(title: Text("$username发布的主题")),
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
