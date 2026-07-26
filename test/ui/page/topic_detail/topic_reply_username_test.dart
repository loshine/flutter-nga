import 'package:flutter/material.dart';
import 'package:flutter_nga/data/entity/topic_detail.dart';
import 'package:flutter_nga/data/entity/user.dart';
import 'package:flutter_nga/ui/page/topic_detail/topic_reply_comment_item_widget.dart';
import 'package:flutter_nga/ui/page/topic_detail/topic_reply_item_widget.dart';
import 'package:flutter_nga/ui/widget/username_text.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('reply and comment headers use UsernameText', (tester) async {
    final user = User(uid: 123, username: '测试用户');
    final reply = Reply(
      content: '回复内容',
      tid: 1,
      pid: 2,
      authorId: 123,
      postDate: '2026-07-26 12:00',
      commentList: [],
      attachmentList: [],
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  TopicReplyItemWidget(
                    reply: reply,
                    user: user,
                    medalList: const [],
                  ),
                  TopicReplyCommentItemWidget(reply, user),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.byType(UsernameText), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });
}
