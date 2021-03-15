import 'package:flutter/material.dart';
import 'package:flutter_nga/data/entity/topic_detail.dart';
import 'package:flutter_nga/data/entity/user.dart';
import 'package:flutter_nga/ui/widget/avatar_widget.dart';
import 'package:flutter_nga/ui/widget/nga_html_comment_widget.dart';
import 'package:flutter_nga/utils/dimen.dart';
import 'package:flutter_nga/utils/palette.dart';

class TopicReplyCommentItemWidget extends StatelessWidget {
  const TopicReplyCommentItemWidget(this.reply, this.user, {Key? key})
      : super(key: key);

  final User? user;
  final Reply reply;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: Theme.of(context).dividerColor),
          right: BorderSide(color: Theme.of(context).dividerColor),
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(right: 8),
                child: AvatarWidget(
                  user!.avatar,
                  size: 36,
                  username: user!.username,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(bottom: 4),
                      child: Text(user!.getShowName()),
                    ),
                    Text(
                      reply.postDate!,
                      style: TextStyle(
                        fontSize: Dimen.caption,
                        color: Theme.of(context).textTheme.bodyText2?.color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          NgaHtmlCommentWidget(content: reply.content),
        ],
      ),
    );
  }
}
