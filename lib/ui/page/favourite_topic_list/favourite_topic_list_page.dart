import 'package:flutter/material.dart';
import 'package:flutter_nga/data/entity/topic.dart';
import 'package:flutter_nga/providers/topic/favourite_topic_list_provider.dart';
import 'package:flutter_nga/ui/widget/topic_list_item_widget.dart';
import 'package:flutter_nga/utils/route.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class FavouriteTopicListPage extends ConsumerStatefulWidget {
  const FavouriteTopicListPage({super.key});

  @override
  ConsumerState<FavouriteTopicListPage> createState() =>
      _FavouriteTopicListState();
}

class _FavouriteTopicListState extends ConsumerState<FavouriteTopicListPage> {
  late RefreshController _refreshController;

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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(favouriteTopicListProvider);
    final notifier = ref.read(favouriteTopicListProvider.notifier);

    return SmartRefresher(
      onLoading: () => _onLoading(notifier),
      controller: _refreshController,
      enablePullUp: state.enablePullUp,
      onRefresh: () => _onRefresh(notifier),
      child: ListView.builder(
        itemCount: state.list.length,
        itemBuilder: (context, index) => TopicListItemWidget(
          topic: state.list[index],
          onLongPress: () => _showDeleteDialog(notifier, state.list[index]),
        ),
      ),
    );
  }

  void _onRefresh(FavouriteTopicListNotifier notifier) {
    notifier.refresh().catchError((err) {
      _refreshController.refreshFailed();
      Fluttertoast.showToast(msg: err.message);
      return ref.read(favouriteTopicListProvider);
    }).whenComplete(
        () => _refreshController.refreshCompleted(resetFooterState: true));
  }

  void _onLoading(FavouriteTopicListNotifier notifier) async {
    notifier.loadMore().then((state) {
      if (state.page + 1 < state.maxPage) {
        _refreshController.loadComplete();
      } else {
        _refreshController.loadNoData();
      }
    }).catchError((_) {
      _refreshController.loadFailed();
      return null;
    });
  }

  void _showDeleteDialog(FavouriteTopicListNotifier notifier, Topic topic) {
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: Text("提示"),
            content: Text("是否删除该收藏"),
            actions: <Widget>[
              TextButton(
                onPressed: () => Routes.pop(context),
                child: Text("取消"),
              ),
              TextButton(
                onPressed: () {
                  Routes.pop(context);
                  notifier.delete(topic).then((message) {
                    Fluttertoast.showToast(msg: message ?? "");
                  });
                },
                child: Text("确认"),
              ),
            ],
          );
        });
  }
}
