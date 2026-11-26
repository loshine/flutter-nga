import 'package:community_material_icon/community_material_icon.dart';
import 'package:cupertino_ui/cupertino_ui.dart' show CupertinoIcons;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/data/entity/topic_detail.dart';
import 'package:flutter_nga/data/entity/user.dart';
import 'package:flutter_nga/providers/settings/design_style_provider.dart';
import 'package:flutter_nga/providers/topic/topic_reply_provider.dart';
import 'package:flutter_nga/ui/widget/adaptive/adaptive_controls.dart';
import 'package:flutter_nga/ui/widget/adaptive/app_icons.dart';
import 'package:flutter_nga/ui/widget/adaptive/liquid_glass_surface.dart';
import 'package:flutter_nga/ui/widget/avatar_widget.dart';
import 'package:flutter_nga/ui/widget/nga_html_content_widget.dart';
import 'package:flutter_nga/utils/app_toast.dart';
import 'package:flutter_nga/utils/code_utils.dart' as code_utils;
import 'package:flutter_nga/utils/dimen.dart';
import 'package:flutter_nga/utils/haptics.dart';
import 'package:flutter_nga/utils/hooks/easy_refresh_hooks.dart';
import 'package:flutter_nga/utils/name_utils.dart' as name_utils;
import 'package:flutter_nga/utils/route.dart';

class ReplyDetailDialog extends HookConsumerWidget {
  final int? pid;

  /// 回复所在主题，传入时显示「进入主题」按钮。
  final int? tid;

  const ReplyDetailDialog({super.key, this.pid, this.tid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void loadReply() {
      ref
          .read(topicReplyProvider(pid).notifier)
          .load()
          .catchError((_) => const TopicReplyState());
    }

    usePostFrameEffect(loadReply, [pid]);

    final state = ref.watch(topicReplyProvider(pid));
    // 避免 AlertDialog 对 HTML 内嵌引用卡执行固有宽度测量。
    final dialogWidth = (MediaQuery.sizeOf(context).width - 80).clamp(
      0.0,
      560.0,
    );
    final actions = [
      if (tid != null && tid != 0)
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            Routes.navigateTo(context, "${Routes.TOPIC_DETAIL}?tid=$tid");
          },
          child: const Text('进入主题'),
        ),
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('关闭'),
      ),
    ];

    if (context.isAppleStyle) {
      return Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: SizedBox(
          width: dialogWidth,
          child: LiquidGlassSurface(
            borderRadius: BorderRadius.circular(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Flexible(
                  child: SingleChildScrollView(
                    child: _buildContent(context, state, loadReply),
                  ),
                ),
                Divider(
                  height: 0.5,
                  thickness: 0.5,
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: actions,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // 背景走 DialogTheme（surfaceContainerHigh），与全应用 M3 弹窗一致。
    return AlertDialog(
      scrollable: true,
      constraints: BoxConstraints.tightFor(width: dialogWidth),
      contentPadding: EdgeInsets.zero,
      content: _buildContent(context, state, loadReply),
      actions: actions,
    );
  }

  Widget _buildContent(
    BuildContext context,
    TopicReplyState state,
    VoidCallback onRetry,
  ) {
    if (state.replyList.isNotEmpty) {
      final reply = state.replyList[0];
      final user = state.userList.firstWhere(
        (u) => u.uid == reply.authorId,
        orElse: () => state.userList.isNotEmpty ? state.userList[0] : User(),
      );
      return _ReplyWidget(reply: reply, user: user);
    }
    if (state.error != null) {
      final colorScheme = Theme.of(context).colorScheme;
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              AppIcons.resolve(context, Icons.cloud_off_outlined),
              size: 32,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 10),
            Text(
              '加载回复失败',
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 12),
            TextButton(onPressed: onRetry, child: const Text('重试')),
          ],
        ),
      );
    }
    if (state.isLoading || !state.hasLoaded) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 28),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [AppActivityIndicator()],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '未找到该楼层内容',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          TextButton(onPressed: onRetry, child: const Text('重试')),
        ],
      ),
    );
  }
}

class _ReplyWidget extends StatefulWidget {
  final Reply reply;
  final User user;

  const _ReplyWidget({required this.reply, required this.user});

  @override
  _ReplyWidgetState createState() => _ReplyWidgetState();
}

class _ReplyWidgetState extends State<_ReplyWidget> {
  bool _reacting = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isApple = context.isAppleStyle;
    final isMac = context.isMacDesktopAppleStyle;
    final thumbBg = colorScheme.surfaceContainerHigh;
    final thumbFgActive = colorScheme.primary;
    final thumbFgInactive = colorScheme.onSurfaceVariant;
    final isLiked = widget.reply.recommend == 1;
    final isDisliked = widget.reply.recommend == -1;
    final reactionTapSize = isMac ? 32.0 : 44.0;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: AvatarWidget(
                widget.user.avatar,
                size: 24,
                username: widget.user.username,
              ),
            ),
            Expanded(
              child: Text(
                name_utils.getShowName(widget.user.username ?? ''),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          height: code_utils.isStringEmpty(widget.reply.subject) ? 0 : null,
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
            child: Text(
              code_utils.unescapeHtml(widget.reply.subject),
              style: TextStyle(
                fontSize: Dimen.titleLarge,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ),
        ),
        SizedBox(
          height: code_utils.isStringEmpty(widget.reply.content) ? 0 : null,
          // HtmlWidget 宽度随内容收缩，不撑满会被外层 Column 居中。
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.only(left: 16, right: 16),
            child: NgaHtmlContentWidget(
              content: widget.reply.content,
              authorId: widget.reply.authorId,
              tid: widget.reply.tid,
              pid: widget.reply.pid,
              postDateTimestamp: widget.reply.postDateTimestamp,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Material(
                color: thumbBg,
                borderRadius: BorderRadius.circular(isApple ? 8 : 6),
                clipBehavior: Clip.antiAlias,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    SizedBox(
                      width: reactionTapSize,
                      height: reactionTapSize,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints.tightFor(
                          width: reactionTapSize,
                          height: reactionTapSize,
                        ),
                        tooltip: '赞',
                        onPressed: _reacting ? null : _toggleLike,
                        icon: Icon(
                          isApple
                              ? (isLiked
                                    ? CupertinoIcons.hand_thumbsup_fill
                                    : CupertinoIcons.hand_thumbsup)
                              : (isLiked
                                    ? CommunityMaterialIcons.thumb_up
                                    : CommunityMaterialIcons.thumb_up_outline),
                          color: isLiked ? thumbFgActive : thumbFgInactive,
                          size: 16,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Text(
                        "${widget.reply.score}",
                        style: TextStyle(
                          fontSize: Dimen.bodySmall,
                          color: isLiked || isDisliked
                              ? thumbFgActive
                              : thumbFgInactive,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: reactionTapSize,
                      height: reactionTapSize,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints.tightFor(
                          width: reactionTapSize,
                          height: reactionTapSize,
                        ),
                        tooltip: '踩',
                        onPressed: _reacting ? null : _toggleDislike,
                        icon: Icon(
                          isApple
                              ? (isDisliked
                                    ? CupertinoIcons.hand_thumbsdown_fill
                                    : CupertinoIcons.hand_thumbsdown)
                              : (isDisliked
                                    ? CommunityMaterialIcons.thumb_down
                                    : CommunityMaterialIcons
                                          .thumb_down_outline),
                          color: isDisliked ? thumbFgActive : thumbFgInactive,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                widget.reply.postDate ?? "",
                style: TextStyle(
                  fontSize: Dimen.bodySmall,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _toggleLike() async {
    if (_reacting) return;
    setState(() => _reacting = true);
    try {
      final reaction = await Data().topicRepository.likeReply(
        widget.reply.tid,
        widget.reply.pid,
      );
      if (!mounted) return;
      setState(() {
        widget.reply.score += reaction.countChange;
        if (reaction.countChange > 0) {
          widget.reply.recommend = 1;
        } else if (reaction.countChange < 0) {
          widget.reply.recommend = 0;
        }
      });
      AppHaptics.reactionSucceeded();
      AppToast.success(reaction.message);
    } catch (err) {
      debugPrint(err.toString());
      AppToast.error(err);
    } finally {
      if (mounted) {
        setState(() => _reacting = false);
      }
    }
  }

  Future<void> _toggleDislike() async {
    if (_reacting) return;
    setState(() => _reacting = true);
    try {
      final reaction = await Data().topicRepository.dislikeReply(
        widget.reply.tid,
        widget.reply.pid,
      );
      if (!mounted) return;
      setState(() {
        widget.reply.score += reaction.countChange;
        if (reaction.countChange < 0) {
          widget.reply.recommend = -1;
        } else if (reaction.countChange > 0) {
          widget.reply.recommend = 0;
        }
      });
      AppHaptics.reactionSucceeded();
      AppToast.success(reaction.message);
    } catch (err) {
      debugPrint(err.toString());
      AppToast.error(err);
    } finally {
      if (mounted) {
        setState(() => _reacting = false);
      }
    }
  }
}
