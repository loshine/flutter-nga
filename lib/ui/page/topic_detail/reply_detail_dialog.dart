import 'package:community_material_icon/community_material_icon.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/data/entity/topic_detail.dart';
import 'package:flutter_nga/data/entity/user.dart';
import 'package:flutter_nga/providers/settings/design_style_provider.dart';
import 'package:flutter_nga/providers/topic/topic_reply_provider.dart';
import 'package:flutter_nga/ui/widget/adaptive/adaptive_controls.dart';
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
    usePostFrameEffect(() {
      ref.read(topicReplyProvider(pid).notifier).load();
    }, [pid]);

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
            Routes.pop(context);
            Routes.navigateTo(context, "${Routes.TOPIC_DETAIL}?tid=$tid");
          },
          child: const Text('进入主题'),
        ),
      TextButton(onPressed: () => Routes.pop(context), child: const Text('关闭')),
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
                  child: SingleChildScrollView(child: _buildContent(state)),
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
      constraints: BoxConstraints.tightFor(width: dialogWidth),
      contentPadding: EdgeInsets.zero,
      content: _buildContent(state),
      actions: actions,
    );
  }

  Widget _buildContent(TopicReplyState state) {
    if (state.replyList.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [AppActivityIndicator()],
        ),
      );
    } else {
      return _ReplyWidget(reply: state.replyList[0], user: state.userList[0]);
    }
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
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final thumbBg = colorScheme.surfaceContainerHigh;
    final thumbFgActive = colorScheme.primary;
    final thumbFgInactive = colorScheme.onSurfaceVariant;
    final isLiked = widget.reply.recommend == 1;
    final isDisliked = widget.reply.recommend == -1;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.all(16),
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
            padding: EdgeInsets.only(left: 16, right: 16, bottom: 8),
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
            padding: EdgeInsets.only(left: 16, right: 16),
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
          padding: EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: thumbBg,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(8, 2, 8, 2),
                  child: Row(
                    children: <Widget>[
                      GestureDetector(
                        onTap: _toggleLike,
                        child: Icon(
                          isLiked
                              ? CommunityMaterialIcons.thumb_up
                              : CommunityMaterialIcons.thumb_up_outline,
                          color: isLiked ? thumbFgActive : thumbFgInactive,
                          size: 14,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 8),
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
                      Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: GestureDetector(
                          onTap: _toggleDislike,
                          child: Icon(
                            isDisliked
                                ? CommunityMaterialIcons.thumb_down
                                : CommunityMaterialIcons.thumb_down_outline,
                            color: isDisliked ? thumbFgActive : thumbFgInactive,
                            size: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Spacer(),
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
    try {
      final reaction = await Data().topicRepository.likeReply(
        widget.reply.tid,
        widget.reply.pid,
      );
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
    }
  }

  Future<void> _toggleDislike() async {
    try {
      final reaction = await Data().topicRepository.dislikeReply(
        widget.reply.tid,
        widget.reply.pid,
      );
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
    }
  }
}
