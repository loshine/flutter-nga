import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:flutter_nga/data/entity/topic_detail.dart';
import 'package:flutter_nga/data/entity/user.dart';
import 'package:flutter_nga/providers/settings/blocklist_settings_provider.dart';
import 'package:flutter_nga/ui/page/topic_detail/topic_reply_item_widget.dart';
import 'package:flutter_nga/ui/widget/username_text.dart';

void main() {
  Future<void> pumpReply(WidgetTester tester, BlockMode? blockMode) {
    return tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: TopicReplyItemWidget(
                reply: Reply(
                  content: '回复内容',
                  subject: '楼层标题',
                  tid: 1,
                  pid: 2,
                  authorId: 123,
                  postDate: '2026-07-26 12:00',
                  commentList: [],
                  attachmentList: [],
                ),
                user: User(uid: 123, username: '测试用户'),
                medalList: const [],
                blockMode: blockMode,
              ),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('collapsed floor reveals on tap', (tester) async {
    await pumpReply(tester, BlockMode.COLLAPSE);
    expect(find.byType(UsernameText), findsNothing);

    await tester.tap(find.text('折叠的屏蔽内容，点击展开'));
    await tester.pump();
    expect(find.byType(UsernameText), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('gone floor renders nothing', (tester) async {
    await pumpReply(tester, BlockMode.GONE);
    expect(find.byType(UsernameText), findsNothing);
    expect(find.textContaining('屏蔽'), findsNothing);
  });

  testWidgets('painted floor is masked until tapped', (tester) async {
    await pumpReply(tester, BlockMode.PAINT);
    expect(find.text('已涂抹的屏蔽内容，点击查看'), findsOneWidget);

    await tester.tap(find.text('已涂抹的屏蔽内容，点击查看'));
    await tester.pump();
    expect(find.text('已涂抹的屏蔽内容，点击查看'), findsNothing);
  });

  testWidgets('delete-line floor strikes through the subject', (tester) async {
    await pumpReply(tester, BlockMode.DELETE_LINE);
    final subject = tester.widget<Text>(find.text('楼层标题'));
    expect(subject.style?.decoration, TextDecoration.lineThrough);
  });

  Future<void> pumpWithComments(
    WidgetTester tester,
    List<BlockMode?> commentModes,
  ) {
    Reply comment(int pid, String content) => Reply(
          content: content,
          tid: 1,
          pid: pid,
          authorId: 200 + pid,
          commentList: [],
          attachmentList: [],
        );
    return tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: TopicReplyItemWidget(
                reply: Reply(
                  content: '回复内容',
                  tid: 1,
                  pid: 2,
                  authorId: 123,
                  postDate: '2026-07-26 12:00',
                  commentList: [comment(10, '第一条评论'), comment(11, '第二条评论')],
                  attachmentList: [],
                ),
                user: User(uid: 123, username: '测试用户'),
                medalList: const [],
                userList: const [],
                commentBlockModes: commentModes,
              ),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('gone comments are removed and not counted', (tester) async {
    await pumpWithComments(tester, [BlockMode.GONE, null]);
    await tester.pumpAndSettle();
    expect(find.text('评论 1'), findsOneWidget);
    expect(find.textContaining('第一条评论', findRichText: true), findsNothing);
    expect(find.textContaining('第二条评论', findRichText: true), findsOneWidget);
  });

  testWidgets('all comments gone hides the comment section', (tester) async {
    await pumpWithComments(tester, [BlockMode.GONE, BlockMode.GONE]);
    await tester.pumpAndSettle();
    expect(find.textContaining('评论 '), findsNothing);
  });

  testWidgets('collapsed comment reveals on tap', (tester) async {
    await pumpWithComments(tester, [BlockMode.COLLAPSE, null]);
    await tester.pumpAndSettle();
    expect(find.text('评论 2'), findsOneWidget);
    expect(find.textContaining('第一条评论', findRichText: true), findsNothing);

    await tester.tap(find.text('折叠的屏蔽内容，点击展开'));
    await tester.pumpAndSettle();
    expect(find.textContaining('第一条评论', findRichText: true), findsOneWidget);
  });
}
