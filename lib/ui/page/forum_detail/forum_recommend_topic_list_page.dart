import 'package:flutter/material.dart';
import 'package:flutter_nga/providers/forum/forum_detail_provider.dart';
import 'package:flutter_nga/ui/widget/topic_list_item_widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ForumRecommendTopicListPage extends ConsumerStatefulWidget {
  final int fid;
  final int? type;

  const ForumRecommendTopicListPage(this.fid, {this.type, Key? key})
      : super(key: key);

  @override
  ConsumerState<ForumRecommendTopicListPage> createState() =>
      _ForumRecommendTopicListState();
}

class _ForumRecommendTopicListState extends ConsumerState<ForumRecommendTopicListPage> {
  late RefreshController _refreshController;

  @override
  void initState() {
    super.initState();
    _refreshController = RefreshController(initialRefresh: true);
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(forumRecommendProvider(widget.fid));
    return SmartRefresher(
      onLoading: _onLoading,
      controller: _refreshController,
      enablePullUp: state.enablePullUp,
      onRefresh: _onRefresh,
      child: ListView.builder(
        itemCount: state.list.length,
        itemBuilder: (context, index) => TopicListItemWidget(
          topic: state.list[index],),
      ),
    );
  }

  _onRefresh() {
    final notifier = ref.read(forumRecommendProvider(widget.fid).notifier);
    notifier.refresh(true, widget.type).catchError((err) {
      _refreshController.refreshFailed();
      Fluttertoast.showToast(msg: err.message);
      return notifier.state;
    }).whenComplete(
        () => _refreshController.refreshCompleted(resetFooterState: true));
  }

  _onLoading() async {
    final notifier = ref.read(forumRecommendProvider(widget.fid).notifier);
    notifier.loadMore(true, widget.type).then((state) {
      if (state.page + 1 < state.maxPage) {
        _refreshController.loadComplete();
      } else {
        _refreshController.loadNoData();
      }
    }).catchError((_) {
      _refreshController.loadFailed();
      return null;
    });
  }
}
