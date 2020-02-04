import 'dart:async';

import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_nga/store/forum_detail_store.dart';
import 'package:flutter_nga/ui/page/forum_detail/forum_favourite_button_widet.dart';
import 'package:flutter_nga/ui/widget/topic_list_item_widget.dart';
import 'package:flutter_nga/utils/route.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'child_forum_item_widget.dart';
import 'forum_recommend_topic_list_page.dart';

class ForumDetailPage extends StatefulWidget {
  const ForumDetailPage({this.fid, this.name, Key key})
      : assert(fid != null),
        super(key: key);

  final int fid;
  final String name;

  @override
  _ForumDetailState createState() => _ForumDetailState();
}

class _ForumDetailState extends State<ForumDetailPage>
    with SingleTickerProviderStateMixin {
  bool _fabVisible = true;
  bool _mainPage = true;
  RefreshController _refreshController;

  final _store = ForumDetailStore();
  List<Tab> _tabs = [];
  TabController _tabController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Observer(
        builder: (_) {
          return NestedScrollView(
            headerSliverBuilder: (_, scrolled) => [
              SliverAppBar(
                pinned: true,
                floating: false,
                title: Text(widget.name),
                bottom: PreferredSize(
                  preferredSize: Size.fromHeight(56),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: TabBar(
                      controller: _tabController,
                      tabs: _tabs,
                      isScrollable: true,
                    ),
                  ),
                ),
                actions: <Widget>[
                  IconButton(
                    icon: Icon(
                      Icons.search,
                      color: Colors.white,
                    ),
                    onPressed: () => Routes.navigateTo(
                        context, "${Routes.SEARCH}?fid=${widget.fid}"),
                  ),
                  ForumFavouriteButtonWidget(
                    fid: widget.fid,
                    name: widget.name,
                  ),
                ],
              ),
            ],
            body: TabBarView(
              controller: _tabController,
              children: [
                SmartRefresher(
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
                ForumRecommendTopicListPage(widget.fid),
                MediaQuery.removePadding(
                  context: context,
                  removeTop: true,
                  child: ListView.builder(
                    itemCount: _store.state.info == null
                        ? 0
                        : _store.state.info.subForums.length,
                    itemBuilder: (_, index) => ChildForumItemWidget(
                        _store.state.info.subForums[index]),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: _fabVisible && _mainPage
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
    _refreshController = RefreshController();
    _tabs.add(Tab(text: '主版'));
    _tabs.add(Tab(text: '精华'));
    _tabs.add(Tab(text: '子版'));
    _tabController = TabController(vsync: this, length: _tabs.length);
    _tabController.addListener(
        () => setState(() => _mainPage = _tabController.index == 0));
    Future.delayed(const Duration()).then((_) {
      // 进入的时候自动刷新
      _refreshController.position.addListener(_scrollListener);
      // 使用 requestRefresh 会导致第一项位置错误
      _onRefresh();
    });
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  _onRefresh() {
    _store.refresh(widget.fid, false).catchError((err) {
      _refreshController.refreshFailed();
      Fluttertoast.showToast(
        msg: err.message,
        gravity: ToastGravity.CENTER,
      );
    }).whenComplete(
        () => _refreshController.refreshCompleted(resetFooterState: true));
  }

  _onLoading() async {
    _store.loadMore(widget.fid, false).then((state) {
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
