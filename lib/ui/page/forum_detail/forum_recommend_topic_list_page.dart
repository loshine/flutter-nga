import 'package:easy_refresh/easy_refresh.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_nga/providers/forum/forum_detail_provider.dart';
import 'package:flutter_nga/providers/settings/blocklist_settings_provider.dart';
import 'package:flutter_nga/ui/widget/topic_list_item_widget.dart';
import 'package:flutter_nga/utils/app_toast.dart';
import 'package:flutter_nga/utils/hooks/easy_refresh_hooks.dart';

class ForumRecommendTopicListPage extends HookConsumerWidget {
  final int fid;
  final int? type;

  const ForumRecommendTopicListPage(
    this.fid, {
    super.key,
    this.type,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final refreshController = useEasyRefreshController(controlFinishLoad: true);
    final state = ref.watch(forumRecommendProvider(fid));
    final notifier = ref.read(forumRecommendProvider(fid).notifier);
    final blockFilter = ref.watch(blockFilterProvider);
    final topics = blockFilter.visibleTopics(state.list);

    Future<void> onRefresh() async {
      try {
        await notifier.refresh(true, type);
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
      child: ListView.builder(
        itemCount: topics.length,
        itemBuilder: (context, index) => TopicListItemWidget(
          topic: topics[index],
          blockMode: blockFilter.topicMode(topics[index]),
        ),
      ),
    );
  }
}
