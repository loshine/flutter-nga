import 'package:easy_refresh/easy_refresh.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_nga/providers/user/user_replies_provider.dart';
import 'package:flutter_nga/ui/widget/topic_list_item_widget.dart';
import 'package:flutter_nga/ui/widget/list_status_view.dart';
import 'package:flutter_nga/utils/app_toast.dart';
import 'package:flutter_nga/utils/hooks/easy_refresh_hooks.dart';
import 'package:flutter_nga/utils/hooks/list_load_status.dart';

class UserRepliesPage extends HookConsumerWidget {
  final int uid;
  final String username;

  const UserRepliesPage({super.key, required this.uid, required this.username});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final refreshController = useEasyRefreshController(controlFinishLoad: true);
    final loadStatus = useListLoadStatus();
    final state = ref.watch(userRepliesProvider(uid));
    final notifier = ref.read(userRepliesProvider(uid).notifier);

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
        final hasData = ref.read(userRepliesProvider(uid)).list.isNotEmpty;
        if (!loadStatus.fail(err, hasData: hasData)) AppToast.error(err);
      }
    }

    Future<void> onLoading() async {
      try {
        final next = await notifier.loadMore();
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
        child: ListStatusSwitcher(
          status: loadStatus,
          isEmpty: state.list.isEmpty,
          emptyMessage: '暂无回复',
          emptyIcon: Icons.chat_bubble_outline,
          onRetry: refreshController.callRefresh,
          child: ListView.builder(
            itemCount: state.list.length,
            itemBuilder: (context, index) =>
                TopicListItemWidget(topic: state.list[index]),
          ),
        ),
      ),
    );
  }
}
