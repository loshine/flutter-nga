import 'package:flutter/material.dart';
import 'package:flutter_nga/data/entity/topic_history.dart';
import 'package:flutter_nga/providers/topic/topic_history_list_provider.dart';
import 'package:flutter_nga/ui/widget/topic_history_list_item_widget.dart';
import 'package:flutter_nga/utils/dimen.dart';
import 'package:flutter_nga/utils/route.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class TopicHistoryListPage extends ConsumerStatefulWidget {
  const TopicHistoryListPage({super.key});

  @override
  ConsumerState<TopicHistoryListPage> createState() =>
      TopicHistoryListPageState();
}

class TopicHistoryListPageState extends ConsumerState<TopicHistoryListPage> {
  late RefreshController _refreshController;

  @override
  Widget build(BuildContext context) {
    final historyState = ref.watch(topicHistoryListProvider);
    final notifier = ref.read(topicHistoryListProvider.notifier);

    return SmartRefresher(
      onRefresh: () => _onRefresh(notifier),
      enablePullUp: historyState.enablePullUp,
      controller: _refreshController,
      onLoading: () => _onLoading(notifier),
      child: _buildChild(historyState, notifier),
    );
  }

  @override
  void initState() {
    super.initState();
    _refreshController = RefreshController(initialRefresh: true);
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  void _onRefresh(TopicHistoryListNotifier notifier) {
    notifier.refresh().catchError((err) {
      _refreshController.loadFailed();
      Fluttertoast.showToast(msg: err.message);
      return ref.read(topicHistoryListProvider);
    }).whenComplete(
        () => _refreshController.refreshCompleted(resetFooterState: true));
  }

  void _onLoading(TopicHistoryListNotifier notifier) {
    notifier.loadMore().catchError((err) {
      _refreshController.loadFailed();
      Fluttertoast.showToast(msg: err.message);
      return ref.read(topicHistoryListProvider);
    }).whenComplete(() => _refreshController.loadComplete());
  }

  Widget _buildListItem(
      dynamic itemData, TopicHistoryListNotifier notifier) {
    if (itemData is TopicHistory) {
      return TopicHistoryListItemWidget(
        topicHistory: itemData,
        onLongPress: () => _showDeleteDialog(notifier, itemData.id!),
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

  void showCleanDialog() {
    final notifier = ref.read(topicHistoryListProvider.notifier);
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
                  _clean(notifier);
                },
                child: Text("确认"),
              ),
            ],
          );
        });
  }

  void _clean(TopicHistoryListNotifier notifier) {
    notifier.clean().catchError((err) {
      Fluttertoast.showToast(msg: err.message);
      return 0;
    }).whenComplete(() {
      _refreshController.requestRefresh();
    });
  }

  void _showDeleteDialog(TopicHistoryListNotifier notifier, int id) {
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
      TopicHistoryListState historyState, TopicHistoryListNotifier notifier) {
    if (historyState.list.isNotEmpty) {
      return ListView.builder(
        itemCount: historyState.list.length,
        itemBuilder: (_, position) =>
            _buildListItem(historyState.list[position], notifier),
      );
    } else {
      return Center(
        child: Text(
          "暂无浏览历史",
          style: TextStyle(
            fontSize: Dimen.titleMedium,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
      );
    }
  }
}
