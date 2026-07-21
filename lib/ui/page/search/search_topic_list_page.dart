import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nga/providers/search/search_topic_list_provider.dart';
import 'package:flutter_nga/ui/widget/topic_list_item_widget.dart';
import 'package:flutter_nga/utils/dimen.dart';
import 'package:flutter_nga/utils/app_toast.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SearchTopicListPage extends ConsumerStatefulWidget {
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
  ConsumerState<SearchTopicListPage> createState() => _SearchTopicListSate();
}

class _SearchTopicListSate extends ConsumerState<SearchTopicListPage> {
  final _refreshController = EasyRefreshController(
    controlFinishRefresh: true,
    controlFinishLoad: true,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _onRefresh(ref.read(searchTopicListProvider.notifier));
      }
    });
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(searchTopicListProvider);
    final notifier = ref.read(searchTopicListProvider.notifier);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('搜索: ${widget.keyword}'),
      ),
      body: EasyRefresh(
        controller: _refreshController,
        onRefresh: () => _onRefresh(notifier),
        onLoad: state.enablePullUp ? () => _onLoadMore(notifier) : null,
        child: state.list.isEmpty
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.sizeOf(context).height * 0.6,
                    child: _buildEmptyState(colorScheme),
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

  Widget _buildEmptyState(ColorScheme colorScheme) {
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

  Future<void> _onRefresh(SearchTopicListNotifier notifier) async {
    try {
      await notifier.refresh(widget.keyword, widget.fid, widget.content);
      if (!mounted) return;
      _refreshController.finishRefresh();
      _refreshController.resetFooter();
    } catch (e) {
      if (!mounted) return;
      AppToast.error((e as dynamic).message ?? e.toString());
      _refreshController.finishRefresh(IndicatorResult.fail);
    }
  }

  Future<void> _onLoadMore(SearchTopicListNotifier notifier) async {
    try {
      final state =
          await notifier.loadMore(widget.keyword, widget.fid, widget.content);
      if (!mounted) return;
      if (state.enablePullUp) {
        _refreshController.finishLoad();
      } else {
        _refreshController.finishLoad(IndicatorResult.noMore);
      }
    } catch (e) {
      if (!mounted) return;
      AppToast.error((e as dynamic).message ?? e.toString());
      _refreshController.finishLoad(IndicatorResult.fail);
    }
  }
}
