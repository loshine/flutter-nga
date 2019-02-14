import 'package:flutter/material.dart';
import 'package:flutter_nga/data/entity/topic_detail.dart';

class TopicReplyCommentItemWidget extends StatelessWidget {
  const TopicReplyCommentItemWidget(this.reply, {Key key}) : super(key: key);

  final Reply reply;

  @override
  Widget build(BuildContext context) {
    debugPrint(reply.content);
    return Text(reply.content);
  }
}
