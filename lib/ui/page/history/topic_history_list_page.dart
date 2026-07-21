import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nga/data/entity/topic_history.dart';
import 'package:flutter_nga/providers/topic/topic_history_list_provider.dart';
import 'package:flutter_nga/ui/widget/topic_history_list_item_widget.dart';
import 'package:flutter_nga/utils/dimen.dart';
import 'package:flutter_nga/utils/hooks/easy_refresh_hooks.dart';
import 'package:flutter_nga/utils/route.dart';
import 'package:flutter_nga/utils/app_toast.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class TopicHistoryListPage extends HookConsumerWidget {
  const TopicHistoryListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final refreshController = useEasyRefreshController(controlFinishLoad: true);
    final historyState = ref.watch(topicHistoryListProvider);
    final notifier = ref.read(topicHistoryListProvider.notifier);

    Future<void> onRefresh() async {
      try {
        await notifier.refresh();
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
        final next = await notifier.loadMore();
        if (!context.mounted) return;
        if (next.enablePullUp) {
          refreshController.finishLoad();
        } else {
          refreshController.finishLoad(IndicatorResult.noMore);
        }
      } catch (err) {
        if (!context.mounted) return;
        refreshController.finishLoad(IndicatorResult.fail);
        AppToast.error((err as dynamic).message ?? err.toString());
      }
    }

    usePostFrameEffect(onRefresh);

    return Scaffold(
      appBar: AppBar(
        title: const Text('浏览历史'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: '清空浏览历史',
            onPressed: () => _showCleanDialog(context, notifier, refreshController),
          ),
        ],
      ),
      body: EasyRefresh(
        controller: refreshController,
        onRefresh: onRefresh,
        onLoad: historyState.enablePullUp ? onLoading : null,
        child: _buildChild(context, historyState, notifier),
      ),
    );
  }

  Widget _buildListItem(
    BuildContext context,
    dynamic itemData,
    TopicHistoryListNotifier notifier,
  ) {
    if (itemData is TopicHistory) {
      return TopicHistoryListItemWidget(
        topicHistory: itemData,
        onLongPress: () => _showDeleteDialog(context, notifier, itemData.id!),
      );
    } else {
      return Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          itemData ?? "",
          style: TextStyle(fontSize: Dimen.titleLarge),
        ),
      );
    }
  }

  void _showCleanDialog(
    BuildContext context,
    TopicHistoryListNotifier notifier,
    EasyRefreshController refreshController,
  ) {
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: Text("提示"),
            content: Text("是否删除所有浏览历史"),
            actions: <Widget>[
              TextButton(
                onPressed: () => Routes.pop(context),
                child: Text("取消"),
              ),
              TextButton(
                onPressed: () {
                  Routes.pop(context);
                  notifier.clean().catchError((err) {
                    AppToast.error(err.message);
                    return 0;
                  }).whenComplete(() {
                    refreshController.callRefresh();
                  });
                },
                child: Text("确认"),
              ),
            ],
          );
        });
  }

  void _showDeleteDialog(
    BuildContext context,
    TopicHistoryListNotifier notifier,
    int id,
  ) {
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: Text("提示"),
            content: Text("是否删除该浏览历史"),
            actions: <Widget>[
              TextButton(
                onPressed: () => Routes.pop(context),
                child: Text("取消"),
              ),
              TextButton(
                onPressed: () {
                  Routes.pop(context);
                  notifier.delete(id);
                },
                child: Text("确认"),
              ),
            ],
          );
        });
  }

  Widget _buildChild(
    BuildContext context,
    TopicHistoryListState historyState,
    TopicHistoryListNotifier notifier,
  ) {
    if (historyState.list.isNotEmpty) {
      return ListView.builder(
        itemCount: historyState.list.length,
        itemBuilder: (_, position) =>
            _buildListItem(context, historyState.list[position], notifier),
      );
    } else {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.6,
            child: Center(
              child: Text(
                "暂无浏览历史",
                style: TextStyle(
                  fontSize: Dimen.titleMedium,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ),
          ),
        ],
      );
    }
  }
}
