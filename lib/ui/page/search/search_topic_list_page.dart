import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_nga/data/entity/topic.dart';
import 'package:flutter_nga/providers/search/search_topic_list_provider.dart';
import 'package:flutter_nga/providers/settings/blocklist_settings_provider.dart';
import 'package:flutter_nga/ui/widget/adaptive/app_scaffold.dart';
import 'package:flutter_nga/ui/widget/adaptive_layout.dart';
import 'package:flutter_nga/ui/widget/list_status_view.dart';
import 'package:flutter_nga/ui/widget/readable_width.dart';
import 'package:flutter_nga/ui/widget/topic_list_item_widget.dart';
import 'package:flutter_nga/utils/app_toast.dart';
import 'package:flutter_nga/utils/dimen.dart';
import 'package:flutter_nga/utils/hooks/easy_refresh_hooks.dart';
import 'package:flutter_nga/utils/hooks/list_load_status.dart';

class SearchTopicListPage extends HookConsumerWidget {
  const SearchTopicListPage(
    this.keyword, {
    super.key,
    this.fid,
    this.content = false,
  });

  final int? fid;
  final String keyword;
  final bool content;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final refreshController = useEasyRefreshController(controlFinishLoad: true);
    final loadStatus = useListLoadStatus();
    final selectedTopic = useState<SelectedTopic?>(null);
    final state = ref.watch(searchTopicListProvider);
    final notifier = ref.read(searchTopicListProvider.notifier);
    final blockFilter = ref.watch(blockFilterProvider);
    final topics = blockFilter.visibleTopics(state.list);

    Future<void> onRefresh() async {
      try {
        await notifier.refresh(keyword, fid, content);
        if (!context.mounted) return;
        loadStatus.succeed();
        refreshController.finishRefresh();
        refreshController.resetFooter();
      } catch (e) {
        if (!context.mounted) return;
        final hasData = ref.read(searchTopicListProvider).list.isNotEmpty;
        if (!loadStatus.fail(e, hasData: hasData)) AppToast.error(e);
        refreshController.finishRefresh(IndicatorResult.fail);
      }
    }

    Future<void> onLoadMore() async {
      try {
        final next = await notifier.loadMore(keyword, fid, content);
        if (!context.mounted) return;
        if (next.enablePullUp) {
          refreshController.finishLoad();
        } else {
          refreshController.finishLoad(IndicatorResult.noMore);
        }
      } catch (e) {
        if (!context.mounted) return;
        AppToast.error(e);
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

    final mediaPadding = MediaQuery.paddingOf(context);

    void selectTopic(Topic topic) {
      final tid = topic.tid;
      if (tid == null) return;
      selectedTopic.value = SelectedTopic(
        tid: tid,
        fid: topic.fid ?? fid,
        subject: topic.subject,
      );
    }

    return MasterDetailLayout(
      masterBuilder: (context, isTwoPane) => AppScaffold(
        title: Text('搜索: $keyword'),
        body: EasyRefresh(
          controller: refreshController,
          onRefresh: onRefresh,
          onLoad: state.enablePullUp ? onLoadMore : null,
          child: ListStatusSwitcher(
            status: loadStatus,
            isEmpty: topics.isEmpty,
            emptyMessage: '暂无搜索结果',
            emptyIcon: Icons.search_off_outlined,
            onRetry: refreshController.callRefresh,
            child: ReadableListPadding(
              padding: EdgeInsets.fromLTRB(
                mediaPadding.left,
                Dimen.spacingS,
                isTwoPane ? 0 : mediaPadding.right,
                Dimen.spacingS + mediaPadding.bottom,
              ),
              builder: (context, padding) => ListView.separated(
                padding: padding,
                itemBuilder: (_, index) {
                  final topic = topics[index];
                  return TopicListItemWidget(
                    topic: topic,
                    blockMode: blockFilter.topicMode(topic),
                    selected:
                        isTwoPane && selectedTopic.value?.tid == topic.tid,
                    onTap: isTwoPane ? () => selectTopic(topic) : null,
                  );
                },
                separatorBuilder: (_, _) =>
                    const SizedBox(height: Dimen.spacingXS),
                itemCount: topics.length,
              ),
            ),
          ),
        ),
      ),
      detailBuilder: (context) => TopicDetailPane(
        selected: selectedTopic.value,
        emptySubtitle: '关键词：$keyword',
        onClose: () => selectedTopic.value = null,
      ),
    );
  }
}
