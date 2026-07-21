import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nga/providers/forum/forum_detail_provider.dart';
import 'package:flutter_nga/ui/widget/topic_list_item_widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_nga/utils/app_toast.dart';

class ForumRecommendTopicListPage extends ConsumerStatefulWidget {
  final int fid;
  final int? type;

  const ForumRecommendTopicListPage(
    this.fid, {
    super.key,
    this.type,
  });

  @override
  ConsumerState<ForumRecommendTopicListPage> createState() =>
      _ForumRecommendTopicListState();
}

class _ForumRecommendTopicListState
    extends ConsumerState<ForumRecommendTopicListPage> {
  final _refreshController = EasyRefreshController(
    controlFinishRefresh: true,
    controlFinishLoad: true,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _onRefresh();
    });
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(forumRecommendProvider(widget.fid));
    return EasyRefresh(
      controller: _refreshController,
      onRefresh: _onRefresh,
      onLoad: state.enablePullUp ? _onLoading : null,
      child: ListView.builder(
        itemCount: state.list.length,
        itemBuilder: (context, index) => TopicListItemWidget(
          topic: state.list[index],
        ),
      ),
    );
  }

  Future<void> _onRefresh() async {
    final notifier = ref.read(forumRecommendProvider(widget.fid).notifier);
    try {
      await notifier.refresh(true, widget.type);
      if (!mounted) return;
      _refreshController.finishRefresh();
      _refreshController.resetFooter();
    } catch (err) {
      if (!mounted) return;
      _refreshController.finishRefresh(IndicatorResult.fail);
      AppToast.error((err as dynamic).message ?? err.toString());
    }
  }

  Future<void> _onLoading() async {
    final notifier = ref.read(forumRecommendProvider(widget.fid).notifier);
    try {
      final state = await notifier.loadMore(true, widget.type);
      if (!mounted) return;
      if (state.page + 1 < state.maxPage) {
        _refreshController.finishLoad();
      } else {
        _refreshController.finishLoad(IndicatorResult.noMore);
      }
    } catch (_) {
      if (!mounted) return;
      _refreshController.finishLoad(IndicatorResult.fail);
    }
  }
}
