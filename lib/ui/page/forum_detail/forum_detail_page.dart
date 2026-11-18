import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_nga/providers/forum/forum_detail_provider.dart';
import 'package:flutter_nga/providers/settings/blocklist_settings_provider.dart';
import 'package:flutter_nga/ui/page/forum_detail/forum_favourite_button_widet.dart';
import 'package:flutter_nga/ui/widget/keep_alive_tab_view.dart';
import 'package:flutter_nga/ui/widget/readable_width.dart';
import 'package:flutter_nga/ui/widget/topic_list_item_widget.dart';
import 'package:flutter_nga/ui/widget/list_status_view.dart';
import 'package:flutter_nga/utils/app_toast.dart';
import 'package:flutter_nga/utils/hooks/easy_refresh_hooks.dart';
import 'package:flutter_nga/utils/hooks/list_load_status.dart';
import 'package:flutter_nga/utils/hooks/material_tab_controller_hook.dart';
import 'package:flutter_nga/utils/hooks/scroll_hooks.dart';
import 'package:flutter_nga/utils/hooks/scroll_to_top.dart';
import 'package:flutter_nga/utils/route.dart';

import 'child_forum_list_page.dart';
import 'forum_recommend_topic_list_page.dart';

class ForumDetailPage extends HookConsumerWidget {
  const ForumDetailPage({required this.fid, this.name, this.type, super.key});

  final int fid;
  final String? name;
  final int? type;

  static const _tabs = [Tab(text: '最新'), Tab(text: '精华'), Tab(text: '子版')];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final refreshController = useEasyRefreshController(controlFinishLoad: true);
    final loadStatus = useListLoadStatus();
    final tabController = useMaterialTabController(initialLength: _tabs.length);
    final fabScroll = useScrollFabVisibility();
    final tabSignals = useScrollToTopSignals(_tabs.length);
    final latestScrollController = useScrollToTopController(tabSignals[0]);

    useListenable(tabController);
    final mainPage = tabController.index == 0;

    final state = ref.watch(forumDetailProvider(fid));
    final notifier = ref.read(forumDetailProvider(fid).notifier);
    final blockFilter = ref.watch(blockFilterProvider);
    final topics = blockFilter.visibleTopics(state.list);

    Future<void> onRefresh() async {
      try {
        await notifier.refresh(false, type);
        if (!context.mounted) return;
        loadStatus.succeed();
        refreshController.finishRefresh();
        refreshController.resetFooter();
      } catch (err) {
        if (!context.mounted) return;
        refreshController.finishRefresh(IndicatorResult.fail);
        final hasData = ref.read(forumDetailProvider(fid)).list.isNotEmpty;
        if (!loadStatus.fail(err, hasData: hasData)) AppToast.error(err);
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
    useAutoLoadWhenAllFiltered(
      refreshController,
      rawItems: state.list,
      visibleCount: topics.length,
      canLoadMore: state.enablePullUp,
    );

    return Scaffold(
      appBar: AppBar(
        // 点击标题让当前 Tab 回到顶部
        title: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => tabSignals[tabController.index].fire(),
          child: Text(name!),
        ),
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
          ForumFavouriteButtonWidget(fid: fid, name: name, type: type),
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
                child: ListStatusSwitcher(
                  status: loadStatus,
                  isEmpty: topics.isEmpty,
                  emptyMessage: '暂无帖子',
                  emptyIcon: Icons.article_outlined,
                  onRetry: refreshController.callRefresh,
                  child: ReadableListPadding(
                    builder: (context, padding) => ListView.builder(
                      padding: padding,
                      controller: latestScrollController,
                      itemCount: topics.length,
                      itemBuilder: (context, index) => TopicListItemWidget(
                        topic: topics[index],
                        blockMode: blockFilter.topicMode(topics[index]),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          KeepAliveTabView(
            child: ForumRecommendTopicListPage(
              fid,
              type: type,
              scrollToTop: tabSignals[1],
            ),
          ),
          KeepAliveTabView(child: ChildForumListPage(state.info)),
        ],
      ),
      floatingActionButton: fabScroll.visible && mainPage
          ? FloatingActionButton(
              onPressed: () => Routes.navigateTo(
                context,
                "${Routes.TOPIC_PUBLISH}?fid=$fid",
              ),
              child: const Icon(Icons.edit),
            )
          : null,
    );
  }
}
