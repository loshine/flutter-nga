import 'dart:async';

import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_nga/providers/forum/forum_detail_provider.dart';
import 'package:flutter_nga/ui/page/forum_detail/forum_favourite_button_widet.dart';
import 'package:flutter_nga/ui/widget/keep_alive_tab_view.dart';
import 'package:flutter_nga/ui/widget/topic_list_item_widget.dart';
import 'package:flutter_nga/utils/route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'child_forum_list_page.dart';
import 'forum_recommend_topic_list_page.dart';

class ForumDetailPage extends ConsumerStatefulWidget {
  const ForumDetailPage({required this.fid, this.name, this.type, Key? key})
      : super(key: key);

  final int fid;
  final String? name;
  final int? type;

  @override
  ConsumerState<ForumDetailPage> createState() => _ForumDetailState();
}

class _ForumDetailState extends ConsumerState<ForumDetailPage>
    with SingleTickerProviderStateMixin {
  bool _fabVisible = true;
  bool _mainPage = true;
  late RefreshController _refreshController;

  List<Tab> _tabs = [];
  TabController? _tabController;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(forumDetailProvider(widget.fid));
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name!),
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
        actions: [
          ForumFavouriteButtonWidget(
            fid: widget.fid,
            name: widget.name,
            type: widget.type,
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => Routes.navigateTo(
                context, "${Routes.SEARCH}?fid=${widget.fid}"),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          KeepAliveTabView(
            child: SmartRefresher(
              onLoading: _onLoading,
              controller: _refreshController,
              enablePullUp: state.enablePullUp,
              onRefresh: _onRefresh,
              child: ListView.builder(
                itemCount: state.list.length,
                itemBuilder: (context, index) => TopicListItemWidget(
                  topic: state.list[index],
                ),
              ),
            ),
          ),
          KeepAliveTabView(
            child:
                ForumRecommendTopicListPage(widget.fid, type: widget.type),
          ),
          KeepAliveTabView(
            child: ChildForumListPage(state.info),
          ),
        ],
      ),
      floatingActionButton: _fabVisible && _mainPage
          ? FloatingActionButton(
              onPressed: () => Routes.navigateTo(
                  context, "${Routes.TOPIC_PUBLISH}?fid=${widget.fid}"),
              child: const Icon(Icons.edit),
            )
          : null,
    );
  }

  @override
  void initState() {
    super.initState();
    _refreshController = RefreshController(initialRefresh: true);
    _tabs.add(Tab(text: '最新'));
    _tabs.add(Tab(text: '精华'));
    _tabs.add(Tab(text: '子版'));
    _tabController = TabController(vsync: this, length: _tabs.length);
    _tabController!.addListener(
        () => setState(() => _mainPage = _tabController!.index == 0));
    Future.delayed(const Duration()).then((_) {
      _refreshController.position?.addListener(_scrollListener);
    });
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _tabController!.dispose();
    super.dispose();
  }

  _onRefresh() {
    final notifier = ref.read(forumDetailProvider(widget.fid).notifier);
    notifier
        .refresh(false, widget.type)
        .then((value) =>
            _refreshController.refreshCompleted(resetFooterState: true))
        .catchError((err) {
      _refreshController.refreshFailed();
      Fluttertoast.showToast(msg: err.message);
      return null;
    });
  }

  _onLoading() async {
    final notifier = ref.read(forumDetailProvider(widget.fid).notifier);
    notifier.loadMore(false, widget.type).then((state) {
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

  void _scrollListener() {
    if (_refreshController.position?.userScrollDirection ==
        ScrollDirection.reverse) {
      if (_fabVisible) setState(() => _fabVisible = false);
    }
    if (_refreshController.position?.userScrollDirection ==
        ScrollDirection.forward) {
      if (!_fabVisible) setState(() => _fabVisible = true);
    }
  }
}
