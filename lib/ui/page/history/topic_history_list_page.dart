import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_nga/data/entity/topic_history.dart';
import 'package:flutter_nga/store/topic_history_list_store.dart';
import 'package:flutter_nga/ui/widget/topic_history_list_item_widget.dart';
import 'package:flutter_nga/utils/dimen.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class TopicHistoryListPage extends StatefulWidget {
  @override
  _TopicHistoryListState createState() => _TopicHistoryListState();
}

class _TopicHistoryListState extends State<TopicHistoryListPage> {
  final _store = TopicHistoryListStore();
  final _refreshController = RefreshController();

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        return SmartRefresher(
          onRefresh: _onRefresh,
          enablePullUp: _store.state.enablePullUp,
          controller: _refreshController,
          onLoading: _onLoading,
          child: ListView.builder(
            itemCount: _store.state.list.length,
            itemBuilder: (context, position) =>
                _buildListItem(_store.state.list[position]),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration())
        .then((_) => _refreshController.requestRefresh());
  }

  _onRefresh() {
    _store.refresh().catchError((err) {
      _refreshController.loadFailed();
      Fluttertoast.showToast(
        msg: err.message,
        gravity: ToastGravity.CENTER,
      );
    }).whenComplete(
        () => _refreshController.refreshCompleted(resetFooterState: true));
  }

  _onLoading() {
    _store.loadMore().catchError((err) {
      _refreshController.loadFailed();
      Fluttertoast.showToast(
        msg: err.message,
        gravity: ToastGravity.CENTER,
      );
    }).whenComplete(() => _refreshController.loadComplete());
  }

  Widget _buildListItem(dynamic itemData) {
    if (itemData is TopicHistory) {
      return TopicHistoryListItemWidget(topicHistory: itemData);
    } else {
      return Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          itemData ?? "",
          style: TextStyle(fontSize: Dimen.title),
        ),
      );
    }
  }
}
