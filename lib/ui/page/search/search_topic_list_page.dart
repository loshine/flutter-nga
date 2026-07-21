import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nga/providers/search/search_topic_list_provider.dart';
import 'package:flutter_nga/ui/widget/topic_list_item_widget.dart';
import 'package:flutter_nga/utils/dimen.dart';
import 'package:flutter_nga/utils/app_toast.dart';
import 'package:flutter_nga/utils/hooks/easy_refresh_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

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
    final state = ref.watch(searchTopicListProvider);
    final notifier = ref.read(searchTopicListProvider.notifier);
    final colorScheme = Theme.of(context).colorScheme;

    Future<void> onRefresh() async {
      try {
        await notifier.refresh(keyword, fid, content);
        if (!context.mounted) return;
        refreshController.finishRefresh();
        refreshController.resetFooter();
      } catch (e) {
        if (!context.mounted) return;
        AppToast.error(e);
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

    usePostFrameEffect(onRefresh);

    return Scaffold(
      appBar: AppBar(
        title: Text('搜索: $keyword'),
      ),
      body: EasyRefresh(
        controller: refreshController,
        onRefresh: onRefresh,
        onLoad: state.enablePullUp ? onLoadMore : null,
        child: state.list.isEmpty
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.sizeOf(context).height * 0.6,
                    child: _buildEmptyState(context, colorScheme),
                  ),
                ],
              )
            : ListView.separated(
                padding: const EdgeInsets.symmetric(
                  vertical: Dimen.spacingS,
                ),
                itemBuilder: (_, index) => TopicListItemWidget(
                  topic: state.list[index],
                ),
                separatorBuilder: (_, __) =>
                    const SizedBox(height: Dimen.spacingXS),
                itemCount: state.list.length,
              ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_outlined,
            size: 64,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: Dimen.spacingL),
          Text(
            '暂无搜索结果',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}
