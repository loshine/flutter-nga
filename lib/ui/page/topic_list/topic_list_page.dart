import 'dart:async';

import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_nga/ui/page/topic_list/favourite_button/topic_list_favourite_button_widet.dart';
import 'package:flutter_nga/ui/page/topic_list/topic_list_bloc.dart';
import 'package:flutter_nga/ui/page/topic_list/topic_list_item_widget.dart';
import 'package:flutter_nga/ui/page/topic_list/topic_list_state.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class TopicListPage extends StatefulWidget {
  const TopicListPage({this.name, this.fid, Key key})
      : assert(fid != null),
        super(key: key);

  final String name;
  final int fid;

  @override
  _TopicListState createState() => _TopicListState();
}

class _TopicListState extends State<TopicListPage> {
  bool _fabVisible = true;
  RefreshController _refreshController = RefreshController();

  final _refreshKey = GlobalKey<RefreshIndicatorState>();
  final _bloc = TopicListBloc();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: _bloc,
      builder: (_, TopicListState state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(widget.name),
            actions: <Widget>[
              TopicListFavouriteButtonWidget(
                fid: widget.fid,
                name: widget.name,
              ),
            ],
          ),
          body: Builder(builder: (BuildContext context) {
            return RefreshIndicator(
              key: _refreshKey,
              child: SmartRefresher(
                onRefresh: _onLoadMore,
                controller: _refreshController,
                enableOverScroll: false,
                enablePullUp: state.enablePullUp,
                enablePullDown: false,
                child: ListView.builder(
                  itemCount: state.list.length,
                  itemBuilder: (context, index) =>
                      TopicListItemWidget(topic: state.list[index]),
                ),
              ),
              onRefresh: _onRefresh,
            );
          }),
          floatingActionButton: _fabVisible
              ? FloatingActionButton(
                  onPressed: null,
                  child: Icon(
                    CommunityMaterialIcons.pencil,
                    color: Colors.white,
                  ),
                )
              : null,
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 0)).then((val) {
      // 进入的时候自动刷新
      _refreshKey.currentState.show();
      _refreshController.scrollController.addListener(_scrollListener);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _bloc.dispose();
  }

  Future<void> _onRefresh() async {
    final completer = Completer<void>();
    _bloc.onRefresh(widget.fid, completer);
    return completer.future;
  }

  _onLoadMore(bool up) async {
    _bloc.onLoadMore(widget.fid, _refreshController);
  }

  void _scrollListener() {
    if (_refreshController.scrollController.position.userScrollDirection ==
        ScrollDirection.reverse) {
      debugPrint("reverse");
      if (_fabVisible) setState(() => _fabVisible = false);
    }
    if (_refreshController.scrollController.position.userScrollDirection ==
        ScrollDirection.forward) {
      debugPrint("forward");
      if (!_fabVisible) setState(() => _fabVisible = true);
    }
  }
}
