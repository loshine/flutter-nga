import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_nga/data/entity/topic.dart';
import 'package:flutter_nga/providers/forum/forum_detail_provider.dart';
import 'package:flutter_nga/providers/settings/blocklist_settings_provider.dart';
import 'package:flutter_nga/providers/settings/design_style_provider.dart';
import 'package:flutter_nga/ui/page/forum_detail/forum_favourite_button_widet.dart';
import 'package:flutter_nga/ui/widget/adaptive/adaptive_controls.dart';
import 'package:flutter_nga/ui/widget/adaptive/app_icons.dart';
import 'package:flutter_nga/ui/widget/adaptive/app_scaffold.dart';
import 'package:flutter_nga/ui/widget/adaptive_layout.dart';
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
  const ForumDetailPage({
    required this.fid,
    this.name,
    this.type,
    this.embedded = false,
    this.leading,
    super.key,
  });

  final int fid;
  final String? name;
  final int? type;

  /// 是否内嵌在 macOS / iPadOS 三栏工作区中（不显示路由返回箭头、不重复避让红绿灯）
  final bool embedded;

  /// 内嵌模式下可选自定义左侧操作（如展开侧边栏或返回全部版块）
  final Widget? leading;

  static const _tabs = [Tab(text: '最新'), Tab(text: '精华'), Tab(text: '子版')];
  static const _segments = [
    AppSegment(value: 0, label: '最新'),
    AppSegment(value: 1, label: '精华'),
    AppSegment(value: 2, label: '子版'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final refreshController = useEasyRefreshController(controlFinishLoad: true);
    final loadStatus = useListLoadStatus();
    final tabController = useMaterialTabController(initialLength: _tabs.length);
    final fabScroll = useScrollFabVisibility();
    final tabSignals = useScrollToTopSignals(_tabs.length);
    final latestScrollController = useScrollToTopController(tabSignals[0]);
    final selectedTopic = useState<SelectedTopic?>(null);

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

    void selectTopic(Topic topic) {
      final tid = topic.tid;
      if (tid == null) return;
      selectedTopic.value = (
        tid: tid,
        fid: topic.fid ?? fid,
        subject: topic.subject,
        authorid: null,
      );
    }

    final isApple = context.isAppleStyle;

    return MasterDetailLayout(
      masterBuilder: (context, isTwoPane) => AppScaffold(
        embedded: embedded,
        leading: leading,
        // 点击标题让当前 Tab 回到顶部
        title: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => tabSignals[tabController.index].fire(),
          child: Text(name ?? ''),
        ),
        bottom: isApple
            ? PreferredSize(
                preferredSize: const Size.fromHeight(44),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                  child: AppSegmentedControl<int>(
                    segments: _segments,
                    selected: tabController.index,
                    onChanged: (i) => tabController.animateTo(i),
                  ),
                ),
              )
            : TabBar(
                controller: tabController,
                tabs: _tabs,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
              ),
        actions: [
          ForumFavouriteButtonWidget(fid: fid, name: name, type: type),
          IconButton(
            tooltip: '搜索本版',
            icon: Icon(AppIcons.search(context)),
            onPressed: () =>
                Routes.navigateTo(context, "${Routes.SEARCH}?fid=$fid"),
          ),
        ],
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
                        itemBuilder: (context, index) {
                          final topic = topics[index];
                          return TopicListItemWidget(
                            topic: topic,
                            blockMode: blockFilter.topicMode(topic),
                            selected:
                                isTwoPane &&
                                selectedTopic.value?.tid == topic.tid,
                            onTap: isTwoPane ? () => selectTopic(topic) : null,
                          );
                        },
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
                selectedTid: isTwoPane ? selectedTopic.value?.tid : null,
                onTopicSelected: isTwoPane ? selectTopic : null,
              ),
            ),
            KeepAliveTabView(child: ChildForumListPage(state.info)),
          ],
        ),
        primaryAction: AppPrimaryAction(
          key: const ValueKey('forum_publish_fab'),
          tooltip: '发帖',
          visible: isApple || (fabScroll.visible && mainPage),
          icon: const Icon(Icons.edit),
          appleIcon: Icon(AppIcons.edit(context)),
          onPressed: () async {
            final published = await Routes.navigateTo(
              context,
              "${Routes.TOPIC_PUBLISH}?fid=$fid",
            );
            if (published == true && context.mounted) {
              refreshController.callRefresh();
            }
          },
        ),
      ),
      detailBuilder: (context) => TopicDetailPane(
        selected: selectedTopic.value,
        emptySubtitle: name?.isNotEmpty == true ? '当前版块：$name' : null,
        onClose: () => selectedTopic.value = null,
      ),
    );
  }
}
