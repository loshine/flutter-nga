import 'package:flutter/material.dart';
import 'package:flutter_nga/providers/search/search_topic_list_provider.dart';
import 'package:flutter_nga/ui/widget/topic_list_item_widget.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: Text("搜索贴子:${widget.keyword}"),
      ),
      body: SmartRefresher(
        onRefresh: () => _onRefresh(notifier),
        onLoading: () => _onLoadMore(notifier),
        enablePullUp: state.enablePullUp,
        controller: _refreshController,
        child: ListView.builder(
          itemBuilder: (_, index) => TopicListItemWidget(
            topic: state.list[index],
          ),
          itemCount: state.list.length,
        ),
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
