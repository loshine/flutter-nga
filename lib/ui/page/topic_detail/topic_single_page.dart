import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_nga/data/entity/topic_detail.dart';
import 'package:flutter_nga/data/entity/user.dart';
import 'package:flutter_nga/providers/topic/topic_detail_provider.dart';
import 'package:flutter_nga/providers/topic/topic_single_page_provider.dart';
import 'package:flutter_nga/ui/page/topic_detail/hot_replies_section.dart';
import 'package:flutter_nga/ui/page/topic_detail/topic_reply_item_widget.dart';
import 'package:flutter_nga/utils/app_toast.dart';
import 'package:flutter_nga/utils/hooks/easy_refresh_hooks.dart';
import 'package:flutter_nga/utils/parser/content_parser.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class TopicSinglePage extends HookConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final refreshController = useEasyRefreshController();
    final replyWidgetCache = useRef(<String, Widget>{});
    final detailProviderKey = TopicDetailKey(tid: tid);
    final providerKey = TopicSinglePageKey(
      tid: tid,
      page: page,
      authorid: authorid,
    );
    final state = ref.watch(topicSinglePageProvider(providerKey));

    Future<void> onRefresh() async {
      replyWidgetCache.value.clear();
      final notifier = ref.read(topicSinglePageProvider(providerKey).notifier);
      try {
        final next = await notifier.refresh();
        if (!context.mounted) return;

        ref.read(topicDetailProvider(detailProviderKey).notifier).updateMetadata(
              maxPage: next.maxPage,
              maxFloor: next.maxFloor,
              topic: next.topic,
            );
        refreshController.finishRefresh();
      } catch (err) {
        if (!context.mounted) return;

        refreshController.finishRefresh(IndicatorResult.fail);
        AppToast.error(err);
      }
    }

    // Auto-load only when this page has no data yet (lazy tab mount / remount).
    usePostFrameEffect(() {
      final existing = ref.read(topicSinglePageProvider(providerKey));
      if (existing.replyList.isNotEmpty) return;
      refreshController.callRefresh();
    }, [providerKey.tid, providerKey.page, providerKey.authorid]);

    return EasyRefresh(
      controller: refreshController,
      onRefresh: onRefresh,
      child: ListView.builder(
        itemCount: state.replyList.length,
        itemBuilder: (context, position) => _buildListItem(
          context,
          position,
          state,
          replyWidgetCache.value,
        ),
      ),
    );
  }

  Widget _buildListItem(
    BuildContext context,
    int position,
    TopicSinglePageState state,
    Map<String, Widget> replyWidgetCache,
  ) {
    final reply = state.replyList[position];
    final quoteBodyByPid = _quoteBodyCacheFor(state);
    if (position == 0 && page == 1 && state.hotReplyList.isNotEmpty) {
      // 楼主下方展示热点回复区块
      return Column(
        children: [
          _buildReplyWidget(
            context,
            reply,
            state,
            quoteBodyByPid,
            replyWidgetCache,
          ),
          HotRepliesSection(
            replies: state.hotReplyList,
            userList: state.userList,
            onJumpToFloor: onJumpToFloor,
            quoteBodyByPid: quoteBodyByPid,
          ),
        ],
      );
    } else {
      return _buildReplyWidget(
        context,
        reply,
        state,
        quoteBodyByPid,
        replyWidgetCache,
      );
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
    Map<String, Widget> replyWidgetCache,
  ) {
    final uniqueId = "${reply.pid}_${reply.tid}_${reply.fid}";
    var cached = replyWidgetCache[uniqueId];
    if (cached != null) {
      return cached;
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

      // 评论占位楼层（无正文、标题为系统文案）按 pid 找回真实评论
      Reply? commentSource;
      if (reply.content.isEmpty &&
          (reply.subject ?? '').contains('发表了一条评论')) {
        commentSource = _findCommentByPid(state, reply.pid);
      }

      cached = TopicReplyItemWidget(
        reply: reply,
        user: user,
        group: group,
        medalList: medalList,
        userList: commentUserList,
        quoteBodyByPid: quoteBodyByPid,
        commentSource: commentSource,
      );
      replyWidgetCache[uniqueId] = cached;
      return cached;
    }
  }

  /// 在本页所有楼层的评论列表中按 pid 查找真实评论
  Reply? _findCommentByPid(TopicSinglePageState state, int? pid) {
    if (pid == null) return null;
    for (final reply in state.replyList) {
      for (final comment in reply.commentList) {
        if (comment.pid == pid) return comment;
      }
    }
    return null;
  }
}
