import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_nga/data/entity/topic.dart';
import 'package:flutter_nga/store/topic/favourite_topic_list_store.dart';
import 'package:flutter_nga/ui/widget/topic_list_item_widget.dart';
import 'package:flutter_nga/utils/route.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class FavouriteTopicListPage extends StatefulWidget {
  @override
  _FavouriteTopicListState createState() => _FavouriteTopicListState();
}

class _FavouriteTopicListState extends State<FavouriteTopicListPage> {
  final _store = FavouriteTopicListStore();
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
    return Observer(
      builder: (_) {
        return SmartRefresher(
          onLoading: _onLoading,
          controller: _refreshController,
          enablePullUp: _store.state.enablePullUp,
          onRefresh: _onRefresh,
          child: ListView.builder(
            itemCount: _store.state.list.length,
            itemBuilder: (context, index) => TopicListItemWidget(
              topic: _store.state.list[index],
              onLongPress: () => _showDeleteDialog(_store.state.list[index]),
            ),
          ),
        );
      },
    );
  }

  _onRefresh() {
    _store.refresh().catchError((err) {
      _refreshController.refreshFailed();
      Fluttertoast.showToast(msg: err.message);
    }).whenComplete(
        () => _refreshController.refreshCompleted(resetFooterState: true));
  }

  _onLoading() async {
    _store.loadMore().then((state) {
      if (state.page + 1 < state.maxPage) {
        _refreshController.loadComplete();
      } else {
        _refreshController.loadNoData();
      }
    }).catchError((_) => _refreshController.loadFailed());
  }

  _showDeleteDialog(Topic topic) {
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
                  _store.delete(topic).then((message) {
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
