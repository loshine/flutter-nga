import 'package:easy_refresh/easy_refresh.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_nga/providers/search/search_topic_list_provider.dart';
import 'package:flutter_nga/providers/settings/blocklist_settings_provider.dart';
import 'package:flutter_nga/ui/widget/list_status_view.dart';
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

    return Scaffold(
      appBar: AppBar(title: Text('搜索: $keyword')),
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
          child: ListView.separated(
            padding: EdgeInsets.fromLTRB(
              mediaPadding.left,
              Dimen.spacingS,
              mediaPadding.right,
              Dimen.spacingS + mediaPadding.bottom,
            ),
            itemBuilder: (_, index) => TopicListItemWidget(
              topic: topics[index],
              blockMode: blockFilter.topicMode(topics[index]),
            ),
            separatorBuilder: (_, _) => const SizedBox(height: Dimen.spacingXS),
            itemCount: topics.length,
          ),
        ),
      ),
    );
  }
}
