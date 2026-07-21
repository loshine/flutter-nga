import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nga/data/entity/topic_history.dart';
import 'package:flutter_nga/providers/topic/topic_history_list_provider.dart';
import 'package:flutter_nga/ui/widget/topic_history_list_item_widget.dart';
import 'package:flutter_nga/utils/dimen.dart';
import 'package:flutter_nga/utils/route.dart';
import 'package:flutter_nga/utils/app_toast.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class TopicHistoryListPage extends ConsumerStatefulWidget {
  const TopicHistoryListPage({super.key});

  @override
  ConsumerState<TopicHistoryListPage> createState() =>
      TopicHistoryListPageState();
}

class TopicHistoryListPageState extends ConsumerState<TopicHistoryListPage> {
  final _refreshController = EasyRefreshController(
    controlFinishRefresh: true,
    controlFinishLoad: true,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _onRefresh(ref.read(topicHistoryListProvider.notifier));
      }
    });
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final historyState = ref.watch(topicHistoryListProvider);
    final notifier = ref.read(topicHistoryListProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('浏览历史'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: '清空浏览历史',
            onPressed: showCleanDialog,
          ),
        ],
      ),
      body: EasyRefresh(
        controller: _refreshController,
        onRefresh: () => _onRefresh(notifier),
        onLoad: historyState.enablePullUp ? () => _onLoading(notifier) : null,
        child: _buildChild(historyState, notifier),
      ),
    );
  }

  Future<void> _onRefresh(TopicHistoryListNotifier notifier) async {
    try {
      await notifier.refresh();
      if (!mounted) return;
      _refreshController.finishRefresh();
      _refreshController.resetFooter();
    } catch (err) {
      if (!mounted) return;
      _refreshController.finishRefresh(IndicatorResult.fail);
      AppToast.error((err as dynamic).message ?? err.toString());
    }
  }

  Future<void> _onLoading(TopicHistoryListNotifier notifier) async {
    try {
      final state = await notifier.loadMore();
      if (!mounted) return;
      if (state.enablePullUp) {
        _refreshController.finishLoad();
      } else {
        _refreshController.finishLoad(IndicatorResult.noMore);
      }
    } catch (err) {
      if (!mounted) return;
      _refreshController.finishLoad(IndicatorResult.fail);
      AppToast.error((err as dynamic).message ?? err.toString());
    }
  }

  Widget _buildListItem(dynamic itemData, TopicHistoryListNotifier notifier) {
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
      AppToast.error(err.message);
      return 0;
    }).whenComplete(() {
      _refreshController.callRefresh();
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
