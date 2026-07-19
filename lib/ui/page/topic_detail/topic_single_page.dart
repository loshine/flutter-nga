import 'package:flutter/material.dart';
import 'package:flutter_nga/data/entity/topic_detail.dart';
import 'package:flutter_nga/data/entity/user.dart';
import 'package:flutter_nga/providers/topic/topic_detail_provider.dart';
import 'package:flutter_nga/providers/topic/topic_single_page_provider.dart';
import 'package:flutter_nga/ui/page/topic_detail/hot_replies_section.dart';
import 'package:flutter_nga/ui/page/topic_detail/topic_reply_item_widget.dart';
import 'package:flutter_nga/utils/parser/content_parser.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_nga/utils/app_toast.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:dio/dio.dart';

class TopicSinglePage extends ConsumerStatefulWidget {
  const TopicSinglePage({
    super.key,
    required this.tid,
    required this.page,
    this.authorid,
    this.onJumpToFloor,
  });

  final int tid;
  final int page;
  final int? authorid;

  /// 跳转原楼层回调，参数为楼层号（lou）
  final ValueChanged<int>? onJumpToFloor;

  @override
  ConsumerState<TopicSinglePage> createState() => _TopicSingleState();
}

class _TopicSingleState extends ConsumerState<TopicSinglePage> {
  final _refreshController = RefreshController(initialRefresh: true);

  TopicDetailKey get _detailProviderKey => TopicDetailKey(tid: widget.tid);

  TopicSinglePageKey get _providerKey => TopicSinglePageKey(
        tid: widget.tid,
        page: widget.page,
        authorid: widget.authorid,
      );

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(topicSinglePageProvider(_providerKey));
    return SmartRefresher(
      onRefresh: _onRefresh,
      enablePullUp: false,
      controller: _refreshController,
      physics: ClampingScrollPhysics(),
      child: ListView.builder(
        itemCount: state.replyList.length,
        itemBuilder: (context, position) =>
            _buildListItem(context, position, state),
      ),
    );
  }

  Future<void> _onRefresh() async {
    map.clear();
    final notifier = ref.read(topicSinglePageProvider(_providerKey).notifier);
    try {
      final state = await notifier.refresh();
      if (!mounted) return;

      ref.read(topicDetailProvider(_detailProviderKey).notifier).updateMetadata(
            maxPage: state.maxPage,
            maxFloor: state.maxFloor,
            topic: state.topic,
          );
      _refreshController.refreshCompleted();
    } catch (err) {
      if (!mounted) return;

      _refreshController.refreshFailed();
      final errorMsg = err is DioException
          ? (err.message ?? err.toString())
          : err.toString();
      AppToast.error(errorMsg);
    }
  }

  final map = <String, Widget>{};

  Widget _buildListItem(
      BuildContext context, int position, TopicSinglePageState state) {
    final reply = state.replyList[position];
    final quoteBodyByPid = _quoteBodyCacheFor(state);
    if (position == 0 && state.page == 1 && state.hotReplyList.isNotEmpty) {
      // 楼主下方展示热点回复区块
      return Column(
        children: [
          _buildReplyWidget(context, reply, state, quoteBodyByPid),
          HotRepliesSection(
            replies: state.hotReplyList,
            userList: state.userList,
            onJumpToFloor: widget.onJumpToFloor,
            quoteBodyByPid: quoteBodyByPid,
          ),
        ],
      );
    } else {
      return _buildReplyWidget(context, reply, state, quoteBodyByPid);
    }
  }

  /// 同页（含热评）楼层正文缓存，Reply to 补原文
  Map<int, String> _quoteBodyCacheFor(TopicSinglePageState state) {
    return NgaContentParser.buildQuoteBodyCache([
      ...state.replyList.map((r) => (pid: r.pid, content: r.content)),
      ...state.hotReplyList.map((r) => (pid: r.pid, content: r.content)),
    ]);
  }

  Widget _buildReplyWidget(
    BuildContext context,
    Reply reply,
    TopicSinglePageState state,
    Map<int, String> quoteBodyByPid,
  ) {
    final uniqueId = "${reply.pid}_${reply.tid}_${reply.fid}";
    var widget = map[uniqueId];
    if (widget != null) {
      return widget;
    } else {
      User? user;
      for (var u in state.userList) {
        if (u.uid == reply.authorId) {
          user = u;
          break;
        }
      }
      if (user == null) {
        user = User();
      }

      Group? group;
      if (user.memberId != null) {
        for (var g in state.groupSet) {
          if (g.id == user.memberId) {
            group = g;
            break;
          }
        }
      }

      List<Medal> medalList = [];
      if (user.medal != null && user.medal!.isNotEmpty) {
        user.medal!.split(",").forEach((id) {
          for (var m in state.medalSet) {
            if (id == m.id.toString()) {
              medalList.add(m);
              break;
            }
          }
        });
      }

      List<User> commentUserList = [];
      if (reply.commentList.isNotEmpty) {
        reply.commentList.forEach((comment) {
          for (var user in state.userList) {
            if (user.uid == comment.authorId) {
              commentUserList.add(user);
              break;
            }
          }
        });
      }
      widget = TopicReplyItemWidget(
        reply: reply,
        user: user,
        group: group,
        medalList: medalList,
        userList: commentUserList,
        hot: state.hotReplyPids.contains(reply.pid),
        quoteBodyByPid: quoteBodyByPid,
      );
      map[uniqueId] = widget;
      return widget;
    }
  }
}
