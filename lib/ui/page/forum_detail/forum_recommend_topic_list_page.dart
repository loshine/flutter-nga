import 'package:easy_refresh/easy_refresh.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_nga/data/entity/topic.dart';
import 'package:flutter_nga/providers/forum/forum_detail_provider.dart';
import 'package:flutter_nga/providers/settings/blocklist_settings_provider.dart';
import 'package:flutter_nga/ui/widget/readable_width.dart';
import 'package:flutter_nga/ui/widget/topic_list_item_widget.dart';
import 'package:flutter_nga/ui/widget/list_status_view.dart';
import 'package:flutter_nga/utils/app_toast.dart';
import 'package:flutter_nga/utils/hooks/easy_refresh_hooks.dart';
import 'package:flutter_nga/utils/hooks/list_load_status.dart';
import 'package:flutter_nga/utils/hooks/scroll_to_top.dart';

class ForumRecommendTopicListPage extends HookConsumerWidget {
  final int fid;
  final int? type;
  final ScrollToTopSignal? scrollToTop;
  final int? selectedTid;
  final ValueChanged<Topic>? onTopicSelected;

  const ForumRecommendTopicListPage(
    this.fid, {
    super.key,
    this.type,
    this.scrollToTop,
    this.selectedTid,
    this.onTopicSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final refreshController = useEasyRefreshController(controlFinishLoad: true);
    final loadStatus = useListLoadStatus();
    final scrollController = useScrollToTopController(scrollToTop);
    final state = ref.watch(forumRecommendProvider(fid));
    final notifier = ref.read(forumRecommendProvider(fid).notifier);
    final blockFilter = ref.watch(blockFilterProvider);
    final topics = blockFilter.visibleTopics(state.list);

    Future<void> onRefresh() async {
      try {
        await notifier.refresh(true, type);
        if (!context.mounted) return;
        loadStatus.succeed();
        refreshController.finishRefresh();
        refreshController.resetFooter();
      } catch (err) {
        if (!context.mounted) return;
        refreshController.finishRefresh(IndicatorResult.fail);
        final hasData = ref.read(forumRecommendProvider(fid)).list.isNotEmpty;
        if (!loadStatus.fail(err, hasData: hasData)) AppToast.error(err);
      }
    }

    Future<void> onLoading() async {
      try {
        final next = await notifier.loadMore(true, type);
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

    return EasyRefresh(
      controller: refreshController,
      onRefresh: onRefresh,
      onLoad: state.enablePullUp ? onLoading : null,
      child: ListStatusSwitcher(
        status: loadStatus,
        isEmpty: topics.isEmpty,
        emptyMessage: '暂无精华帖',
        emptyIcon: Icons.star_outline,
        onRetry: refreshController.callRefresh,
        child: ReadableListPadding(
          builder: (context, padding) => ListView.builder(
            padding: padding,
            controller: scrollController,
            itemCount: topics.length,
            itemBuilder: (context, index) {
              final topic = topics[index];
              return TopicListItemWidget(
                topic: topic,
                blockMode: blockFilter.topicMode(topic),
                selected: selectedTid != null && selectedTid == topic.tid,
                onTap: onTopicSelected != null
                    ? () => onTopicSelected!(topic)
                    : null,
              );
            },
          ),
        ),
      ),
    );
  }
}
