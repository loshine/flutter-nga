import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_nga/providers/forum/forum_detail_provider.dart';
import 'package:flutter_nga/ui/page/forum_detail/forum_favourite_button_widet.dart';
import 'package:flutter_nga/ui/widget/keep_alive_tab_view.dart';
import 'package:flutter_nga/ui/widget/topic_list_item_widget.dart';
import 'package:flutter_nga/utils/hooks/easy_refresh_hooks.dart';
import 'package:flutter_nga/utils/hooks/scroll_hooks.dart';
import 'package:flutter_nga/utils/route.dart';
import 'package:flutter_nga/utils/app_toast.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'child_forum_list_page.dart';
import 'forum_recommend_topic_list_page.dart';

class ForumDetailPage extends HookConsumerWidget {
  const ForumDetailPage({required this.fid, this.name, this.type, super.key});

  final int fid;
  final String? name;
  final int? type;

  static const _tabs = [
    Tab(text: '最新'),
    Tab(text: '精华'),
    Tab(text: '子版'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final refreshController = useEasyRefreshController(controlFinishLoad: true);
    final tabController = useTabController(initialLength: _tabs.length);
    final fabScroll = useScrollFabVisibility();

    useListenable(tabController);
    final mainPage = tabController.index == 0;

    final state = ref.watch(forumDetailProvider(fid));
    final notifier = ref.read(forumDetailProvider(fid).notifier);

    Future<void> onRefresh() async {
      try {
        await notifier.refresh(false, type);
        if (!context.mounted) return;
        refreshController.finishRefresh();
        refreshController.resetFooter();
      } catch (err) {
        if (!context.mounted) return;
        refreshController.finishRefresh(IndicatorResult.fail);
        AppToast.error(err);
      }
    }

    Future<void> onLoading() async {
      try {
        final next = await notifier.loadMore(false, type);
        if (!context.mounted) return;
        if (next.page + 1 < next.maxPage) {
          refreshController.finishLoad();
        } else {
          refreshController.finishLoad(IndicatorResult.noMore);
        }
      } catch (_) {
        if (!context.mounted) return;
        refreshController.finishLoad(IndicatorResult.fail);
      }
    }

    useInitialRefresh(refreshController);

    return Scaffold(
      appBar: AppBar(
        title: Text(name!),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(56),
          child: Align(
            alignment: Alignment.centerLeft,
            child: TabBar(
              controller: tabController,
              tabs: _tabs,
              isScrollable: true,
            ),
          ),
        ),
        actions: [
          ForumFavouriteButtonWidget(
            fid: fid,
            name: name,
            type: type,
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () =>
                Routes.navigateTo(context, "${Routes.SEARCH}?fid=$fid"),
          ),
        ],
      ),
      body: TabBarView(
        controller: tabController,
        children: [
          KeepAliveTabView(
            child: NotificationListener<UserScrollNotification>(
              onNotification: fabScroll.onNotification,
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
            child: ForumRecommendTopicListPage(fid, type: type),
          ),
          KeepAliveTabView(
            child: ChildForumListPage(state.info),
          ),
        ],
      ),
      floatingActionButton: fabScroll.visible && mainPage
          ? FloatingActionButton(
              onPressed: () => Routes.navigateTo(
                  context, "${Routes.TOPIC_PUBLISH}?fid=$fid"),
              child: const Icon(Icons.edit),
            )
          : null,
    );
  }
}
