import 'dart:async';

import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_nga/store/topic_list_store.dart';
import 'package:flutter_nga/ui/page/topic_list/topic_list_favourite_button_widet.dart';
import 'package:flutter_nga/ui/page/topic_list/topic_list_item_widget.dart';
import 'package:flutter_nga/utils/code_utils.dart';
import 'package:flutter_nga/utils/route.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class TopicListPage extends StatefulWidget {
  const TopicListPage({this.fid, this.name, Key key})
      : assert(fid != null),
        super(key: key);

  final int fid;
  final String name;

  @override
  _TopicListState createState() => _TopicListState();
}

class _TopicListState extends State<TopicListPage> {
  bool _fabVisible = true;
  RefreshController _refreshController = RefreshController();

  final _store = TopicListStore();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(fluroCnParamsDecode(widget.name)),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.search,
              color: Colors.white,
            ),
            onPressed: () => Routes.navigateTo(
                context, "${Routes.SEARCH}?fid=${widget.fid}"),
          ),
          TopicListFavouriteButtonWidget(
            fid: widget.fid,
            name: widget.name,
          ),
        ],
      ),
      body: Observer(
        builder: (_) => SmartRefresher(
          onLoading: _onLoading,
          controller: _refreshController,
          enablePullUp: _store.state.enablePullUp,
          onRefresh: _onRefresh,
          child: ListView.builder(
            itemCount: _store.state.list.length,
            itemBuilder: (context, index) =>
                TopicListItemWidget(topic: _store.state.list[index]),
          ),
        ),
      ),
      floatingActionButton: _fabVisible
          ? FloatingActionButton(
              onPressed: () => Routes.navigateTo(
                  context, "${Routes.TOPIC_PUBLISH}?fid=${widget.fid}"),
              child: Icon(
                CommunityMaterialIcons.pencil,
                color: Colors.white,
              ),
            )
          : null,
    );
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration()).then((_) {
      // 进入的时候自动刷新
      _refreshController.requestRefresh();
      _refreshController.position.addListener(_scrollListener);
    });
  }

  _onRefresh() {
    _store.refresh(widget.fid).catchError((err) {
      _refreshController.refreshFailed();
      Fluttertoast.showToast(
        msg: err.message,
        gravity: ToastGravity.CENTER,
      );
    }).whenComplete(
        () => _refreshController.refreshCompleted(resetFooterState: true));
  }

  _onLoading() async {
    _store.loadMore(widget.fid).then((state) {
      if (state.page + 1 < state.maxPage) {
        _refreshController.loadComplete();
      } else {
        _refreshController.loadNoData();
      }
    }).catchError((_) => _refreshController.loadFailed());
  }

  void _scrollListener() {
    if (_refreshController.position.userScrollDirection ==
        ScrollDirection.reverse) {
      if (_fabVisible) setState(() => _fabVisible = false);
    }
    if (_refreshController.position.userScrollDirection ==
        ScrollDirection.forward) {
      if (!_fabVisible) setState(() => _fabVisible = true);
    }
  }
}
