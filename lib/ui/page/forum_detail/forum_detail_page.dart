import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_nga/providers/forum/forum_detail_provider.dart';
import 'package:flutter_nga/ui/page/forum_detail/forum_favourite_button_widet.dart';
import 'package:flutter_nga/ui/widget/keep_alive_tab_view.dart';
import 'package:flutter_nga/ui/widget/topic_list_item_widget.dart';
import 'package:flutter_nga/utils/hooks/easy_refresh_hooks.dart';
import 'package:flutter_nga/utils/route.dart';
import 'package:flutter_nga/utils/app_toast.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'child_forum_list_page.dart';
import 'forum_recommend_topic_list_page.dart';

class ForumDetailPage extends StatefulHookConsumerWidget {
  const ForumDetailPage({required this.fid, this.name, this.type, super.key});

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

  final List<Tab> _tabs = [];
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabs.add(Tab(text: '最新'));
    _tabs.add(Tab(text: '精华'));
    _tabs.add(Tab(text: '子版'));
    _tabController = TabController(vsync: this, length: _tabs.length);
    _tabController!.addListener(
        () => setState(() => _mainPage = _tabController!.index == 0));
  }

  @override
  void dispose() {
    _tabController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final refreshController = useEasyRefreshController(controlFinishLoad: true);
    final state = ref.watch(forumDetailProvider(widget.fid));
    final notifier = ref.read(forumDetailProvider(widget.fid).notifier);

    Future<void> onRefresh() async {
      try {
        await notifier.refresh(false, widget.type);
        if (!mounted) return;
        refreshController.finishRefresh();
        refreshController.resetFooter();
      } catch (err) {
        if (!mounted) return;
        refreshController.finishRefresh(IndicatorResult.fail);
        AppToast.error((err as dynamic).message ?? err.toString());
      }
    }

    Future<void> onLoading() async {
      try {
        final next = await notifier.loadMore(false, widget.type);
        if (!mounted) return;
        if (next.page + 1 < next.maxPage) {
          refreshController.finishLoad();
        } else {
          refreshController.finishLoad(IndicatorResult.noMore);
        }
      } catch (_) {
        if (!mounted) return;
        refreshController.finishLoad(IndicatorResult.fail);
      }
    }

    usePostFrameEffect(onRefresh);

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
            child: NotificationListener<UserScrollNotification>(
              onNotification: (notification) {
                final direction = notification.direction;
                if (direction == ScrollDirection.reverse) {
                  if (_fabVisible) setState(() => _fabVisible = false);
                } else if (direction == ScrollDirection.forward) {
                  if (!_fabVisible) setState(() => _fabVisible = true);
                }
                return false;
              },
              child: EasyRefresh(
                controller: refreshController,
                onRefresh: onRefresh,
                onLoad: state.enablePullUp ? onLoading : null,
                child: ListView.builder(
                  itemCount: state.list.length,
                  itemBuilder: (context, index) => TopicListItemWidget(
                    topic: state.list[index],
                  ),
                ),
              ),
            ),
          ),
          KeepAliveTabView(
            child: ForumRecommendTopicListPage(widget.fid, type: widget.type),
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
}
