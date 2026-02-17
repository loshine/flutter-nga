import 'package:flutter/material.dart';
import 'package:flutter_nga/providers/search/search_topic_list_provider.dart';
import 'package:flutter_nga/ui/widget/topic_list_item_widget.dart';
import 'package:flutter_nga/utils/dimen.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

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
  late RefreshController _refreshController;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(searchTopicListProvider);
    final notifier = ref.read(searchTopicListProvider.notifier);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('搜索: ${widget.keyword}'),
      ),
      body: SmartRefresher(
        onRefresh: () => _onRefresh(notifier),
        onLoading: () => _onLoadMore(notifier),
        enablePullUp: state.enablePullUp,
        controller: _refreshController,
        child: state.list.isEmpty
            ? _buildEmptyState(colorScheme)
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

  @override
  void initState() {
    super.initState();
    _refreshController = RefreshController(
      initialRefresh: true,
    );
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  void _onRefresh(SearchTopicListNotifier notifier) {
    notifier
        .refresh(widget.keyword, widget.fid, widget.content)
        .whenComplete(() => _refreshController.refreshCompleted())
        .catchError((e) {
      Fluttertoast.showToast(msg: e.message);
      _refreshController.refreshFailed();
      return ref.read(searchTopicListProvider);
    });
  }

  void _onLoadMore(SearchTopicListNotifier notifier) {
    notifier
        .loadMore(widget.keyword, widget.fid, widget.content)
        .whenComplete(() => _refreshController.loadComplete())
        .catchError((e) {
      Fluttertoast.showToast(msg: e.message);
      _refreshController.loadFailed();
      return ref.read(searchTopicListProvider);
    });
  }
}
