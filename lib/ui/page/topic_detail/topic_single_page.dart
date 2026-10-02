import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_nga/data/entity/topic_detail.dart';
import 'package:flutter_nga/data/entity/user.dart';
import 'package:flutter_nga/providers/settings/blocklist_settings_provider.dart';
import 'package:flutter_nga/providers/topic/topic_detail_provider.dart';
import 'package:flutter_nga/providers/topic/topic_single_page_provider.dart';
import 'package:flutter_nga/ui/page/topic_detail/hot_replies_section.dart';
import 'package:flutter_nga/ui/page/topic_detail/topic_reply_item_widget.dart';
import 'package:flutter_nga/utils/app_toast.dart';
import 'package:flutter_nga/utils/hooks/easy_refresh_hooks.dart';
import 'package:flutter_nga/utils/parser/content_parser.dart';

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
    final blockFilter = ref.watch(blockFilterProvider);

    Future<void> onRefresh() async {
      replyWidgetCache.value.clear();
      final notifier = ref.read(topicSinglePageProvider(providerKey).notifier);
      try {
        final next = await notifier.refresh();
        if (!context.mounted) return;

        ref
            .read(topicDetailProvider(detailProviderKey).notifier)
            .updateMetadata(
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

    return EasyRefresh(
      controller: refreshController,
      refreshOnStart: state.replyList.isEmpty,
      onRefresh: onRefresh,
      child: ListView.builder(
        itemCount: state.replyList.length,
        itemBuilder: (context, position) => _buildListItem(
          context,
          position,
          state,
          blockFilter,
          replyWidgetCache.value,
        ),
      ),
    );
  }

  Widget _buildListItem(
    BuildContext context,
    int position,
    TopicSinglePageState state,
    BlockFilter blockFilter,
    Map<String, Widget> replyWidgetCache,
  ) {
    final reply = state.replyList[position];
    final quoteBodyByPid = _quoteBodyCacheFor(state);
    // 热点回复是精选区块，被屏蔽的直接移除而不是按屏蔽模式展示
    final hotReplies = position == 0 && page == 1
        ? state.hotReplyList
            .where((hot) =>
                blockFilter.replyMode(
                  hot,
                  username: _findUser(state, hot.authorId)?.username,
                ) ==
                null)
            .toList()
        : const <Reply>[];
    if (hotReplies.isNotEmpty) {
      // 楼主下方展示热点回复区块
      return Column(
        children: [
          _buildReplyWidget(
            context,
            reply,
            state,
            blockFilter,
            quoteBodyByPid,
            replyWidgetCache,
          ),
          HotRepliesSection(
            replies: hotReplies,
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
        blockFilter,
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
    BlockFilter blockFilter,
    Map<int, String> quoteBodyByPid,
    Map<String, Widget> replyWidgetCache,
  ) {
    final user = _findUser(state, reply.authorId) ?? User();
    // 评论占位楼层（无正文、标题为系统文案）按 pid 找回真实评论
    Reply? commentSource;
    if (reply.content.isEmpty && (reply.subject ?? '').contains('发表了一条评论')) {
      commentSource = _findCommentByPid(state, reply.pid);
    }
    final blockMode = blockFilter.replyMode(reply, username: user.username) ??
        (commentSource == null
            ? null
            : blockFilter.replyMode(commentSource, username: user.username));

    final commentBlockModes = [
      for (final comment in reply.commentList)
        blockFilter.replyMode(
          comment,
          username: _findUser(state, comment.authorId)?.username,
        ),
    ];

    // 楼层与评论的屏蔽模式参与缓存 key，屏蔽设置变化后重新构建楼层
    final blockKey = [blockMode, ...commentBlockModes]
        .map((mode) => mode?.index ?? '-')
        .join();
    final uniqueId = "${reply.pid}_${reply.tid}_${reply.fid}_$blockKey";
    var cached = replyWidgetCache[uniqueId];
    if (cached != null) {
      return cached;
    } else {

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

      cached = TopicReplyItemWidget(
        reply: reply,
        user: user,
        group: group,
        medalList: medalList,
        userList: commentUserList,
        quoteBodyByPid: quoteBodyByPid,
        commentSource: commentSource,
        blockMode: blockMode,
        commentBlockModes: commentBlockModes,
      );
      replyWidgetCache[uniqueId] = cached;
      return cached;
    }
  }

  User? _findUser(TopicSinglePageState state, int? uid) {
    for (final user in state.userList) {
      if (user.uid == uid) return user;
    }
    return null;
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
