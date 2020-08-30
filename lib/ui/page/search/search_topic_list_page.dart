import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_nga/store/search_topic_list_store.dart';
import 'package:flutter_nga/ui/widget/topic_list_item_widget.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class SearchTopicListPage extends StatefulWidget {
  const SearchTopicListPage(this.keyword,
      {this.fid, this.content = false, Key key})
      : super(key: key);

  final int fid;
  final String keyword;
  final bool content;

  @override
  State<StatefulWidget> createState() => _SearchTopicListSate();
}

class _SearchTopicListSate extends State<SearchTopicListPage> {
  final _store = SearchTopicListStore();
  RefreshController _refreshController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("搜索贴子:${widget.keyword}"),
      ),
      body: Observer(
        builder: (_) => SmartRefresher(
          onRefresh: _onRefresh,
          onLoading: _onLoadMore,
          enablePullUp: _store.state.enablePullUp,
          controller: _refreshController,
          child: ListView.builder(
            itemBuilder: (_, index) =>
                TopicListItemWidget(topic: _store.state.list[index]),
            itemCount: _store.state.list.length,
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _refreshController = RefreshController(initialRefresh: true,);
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  _onRefresh() {
    _store
        .refresh(widget.keyword, widget.fid, widget.content)
        .whenComplete(() => _refreshController.refreshCompleted())
        .catchError((e) {
      if (e is DioError) {
        Fluttertoast.showToast(msg: e.message, gravity: ToastGravity.CENTER);
      } else {
        Fluttertoast.showToast(msg: e.toString(), gravity: ToastGravity.CENTER);
      }
      _refreshController.refreshFailed();
    });
  }

  _onLoadMore() {
    _store
        .loadMore(widget.keyword, widget.fid, widget.content)
        .whenComplete(() => _refreshController.loadComplete())
        .catchError((e) {
      if (e is DioError) {
        Fluttertoast.showToast(msg: e.message, gravity: ToastGravity.CENTER);
      } else {
        Fluttertoast.showToast(msg: e.toString(), gravity: ToastGravity.CENTER);
      }
      _refreshController.loadFailed();
    });
  }
}
