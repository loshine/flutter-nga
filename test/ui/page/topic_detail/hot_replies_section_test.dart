import 'package:flutter/material.dart';
import 'package:flutter_nga/data/entity/topic_detail.dart';
import 'package:flutter_nga/data/entity/user.dart';
import 'package:flutter_nga/ui/page/topic_detail/hot_replies_section.dart';
import 'package:flutter_nga/ui/widget/username_text.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows original link when pid exists without floor number',
      (tester) async {
    final reply = Reply(
      content: '热点回复内容',
      tid: 1,
      pid: 123,
      commentList: [],
      attachmentList: [],
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: HotRepliesSection(
              replies: [reply],
              userList: [User(uid: 1, username: '热点用户')],
            ),
          ),
        ),
      ),
    );

    final originalLink = find.text('[原帖]');
    expect(originalLink, findsOneWidget);
    expect(
      find.ancestor(
        of: originalLink,
        matching: find.byType(GestureDetector),
      ),
      findsOneWidget,
    );
    expect(find.byType(UsernameText), findsOneWidget);
  });
}
