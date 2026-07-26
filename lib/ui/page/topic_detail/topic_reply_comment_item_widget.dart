import 'package:flutter/material.dart';
import 'package:flutter_nga/data/entity/topic_detail.dart';
import 'package:flutter_nga/data/entity/user.dart';
import 'package:flutter_nga/ui/widget/avatar_widget.dart';
import 'package:flutter_nga/ui/widget/nga_html_comment_widget.dart';
import 'package:flutter_nga/ui/widget/username_text.dart';

/// 贴条评论项：紧凑 M3 风格，由外层容器提供背景与分割线
class TopicReplyCommentItemWidget extends StatelessWidget {
  const TopicReplyCommentItemWidget(this.reply, this.user, {super.key});

  final User? user;
  final Reply reply;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AvatarWidget(
                user?.avatar,
                size: 28,
                username: user?.username,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: UsernameText(
                  username: user?.username ?? '',
                  uid: user?.uid ?? reply.authorId,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                reply.postDate ?? '',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: NgaHtmlCommentWidget(
              content: reply.content,
              authorId: reply.authorId,
              tid: reply.tid,
              pid: reply.pid,
              postDateTimestamp: reply.postDateTimestamp,
            ),
          ),
        ],
      ),
    );
  }
}
