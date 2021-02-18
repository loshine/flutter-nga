import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_nga/data/entity/topic_history.dart';
import 'package:flutter_nga/store/topic/topic_history_list_store.dart';
import 'package:flutter_nga/ui/widget/topic_history_list_item_widget.dart';
import 'package:flutter_nga/utils/dimen.dart';
import 'package:flutter_nga/utils/palette.dart';
import 'package:flutter_nga/utils/route.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class TopicHistoryListPage extends StatefulWidget {
  const TopicHistoryListPage({key: Key}) : super(key: key);

  @override
  TopicHistoryListState createState() => TopicHistoryListState();
}

class TopicHistoryListState extends State<TopicHistoryListPage> {
  final _store = TopicHistoryListStore();
  RefreshController _refreshController;

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        return SmartRefresher(
          onRefresh: _onRefresh,
          enablePullUp: _store.state.enablePullUp,
          controller: _refreshController,
          onLoading: _onLoading,
          child: _buildChild(),
        );
      },
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
      return TopicHistoryListItemWidget(
        topicHistory: itemData,
        onLongPress: () => _showDeleteDialog(itemData.id),
      );
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

  showCleanDialog() {
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: Text("提示"),
            content: Text("是否删除所有浏览历史"),
            actions: <Widget>[
              FlatButton(
                onPressed: () => Routes.pop(context),
                child: Text("取消"),
              ),
              FlatButton(
                onPressed: () {
                  Routes.pop(context);
                  _clean();
                },
                child: Text("确认"),
              ),
            ],
          );
        });
  }

  _clean() {
    _store.clean().catchError((err) {
      Fluttertoast.showToast(
        msg: err.message,
        gravity: ToastGravity.CENTER,
      );
    }).whenComplete(() {
      _refreshController.requestRefresh();
    });
  }

  _showDeleteDialog(int id) {
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: Text("提示"),
            content: Text("是否删除该浏览历史"),
            actions: <Widget>[
              FlatButton(
                onPressed: () => Routes.pop(context),
                child: Text("取消"),
              ),
              FlatButton(
                onPressed: () {
                  Routes.pop(context);
                  _store.delete(id);
                },
                child: Text("确认"),
              ),
            ],
          );
        });
  }

  Widget _buildChild() {
    if (_store.state.list != null && _store.state.list.isNotEmpty) {
      return ListView.builder(
        physics: BouncingScrollPhysics(),
        itemCount: _store.state.list.length,
        itemBuilder: (_, position) =>
            _buildListItem(_store.state.list[position]),
      );
    } else {
      return Center(
        child: Text(
          "暂无浏览历史",
          style: TextStyle(
            fontSize: Dimen.subheading,
            color: Palette.colorTextSecondary,
          ),
        ),
      );
    }
  }
}
