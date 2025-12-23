import 'package:flutter/material.dart';
import 'package:flutter_nga/data/entity/message.dart';
import 'package:flutter_nga/ui/widget/avatar_widget.dart';
import 'package:flutter_nga/ui/widget/nga_html_content_widget.dart';
import 'package:flutter_nga/utils/code_utils.dart' as codeUtils;
import 'package:flutter_nga/utils/dimen.dart';

class MessageItemWidget extends StatelessWidget {
  final Message message;

  const MessageItemWidget({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    children.add(Padding(
      padding: EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AvatarWidget(
            message.user.avatar,
            size: 24,
            username: message.user.username,
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                message.user.getShowName(),
                style: TextStyle(color: Colors.black),
              ),
            ),
          ),
          Text(
            codeUtils.formatPostDate(message.time! * 1000),
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color,
              fontSize: Dimen.caption,
            ),
          ),
        ],
      ),
    ));
    if (!codeUtils.isStringEmpty(message.subject)) {
      children.add(Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          codeUtils.unescapeHtml(message.subject),
          style: TextStyle(
            fontSize: Dimen.title,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
      ));
    }
    children.add(Padding(
      padding: EdgeInsets.all(16),
      child: NgaHtmlContentWidget(content: message.content),
    ));
    children.add(Divider(height: 1));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }
}
