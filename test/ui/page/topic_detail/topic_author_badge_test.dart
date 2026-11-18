import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_nga/data/entity/topic_detail.dart';
import 'package:flutter_nga/data/entity/user.dart';
import 'package:flutter_nga/ui/page/topic_detail/topic_reply_item_widget.dart';

Future<void> _pump(WidgetTester tester, {required bool isTopicAuthor}) {
  return tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        theme: ThemeData(colorSchemeSeed: Colors.teal),
        home: Scaffold(
          body: SingleChildScrollView(
            child: TopicReplyItemWidget(
              reply: Reply(
                content: '回复内容',
                tid: 1,
                pid: 2,
                authorId: 123,
                postDate: '2026-07-26 12:00',
                commentList: [],
                attachmentList: [],
              ),
              user: User(uid: 123, username: '测试用户'),
              medalList: const [],
              isTopicAuthor: isTopicAuthor,
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('topic author floors show a themed badge', (tester) async {
    await _pump(tester, isTopicAuthor: true);
    final badge = tester.widget<Text>(find.text('楼主'));
    final primary = Theme.of(tester.element(find.text('楼主'))).colorScheme;
    expect(badge.style?.color, primary.primary);
  });

  testWidgets('other floors have no badge', (tester) async {
    await _pump(tester, isTopicAuthor: false);
    expect(find.text('楼主'), findsNothing);
  });
}
