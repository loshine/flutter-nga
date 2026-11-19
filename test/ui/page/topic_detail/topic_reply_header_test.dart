import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_nga/data/entity/topic_detail.dart';
import 'package:flutter_nga/data/entity/user.dart';
import 'package:flutter_nga/ui/page/topic_detail/topic_reply_item_widget.dart';

Reply _reply() => Reply(
  content: '回复内容',
  tid: 1,
  pid: 2,
  lou: 3,
  authorId: 123,
  postDate: '2026-07-26 12:00',
  commentList: [],
  attachmentList: [],
);

Future<void> _pumpReply(
  WidgetTester tester, {
  required User user,
  Group? group,
  List<Medal> medals = const [],
}) {
  return tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: TopicReplyItemWidget(
              reply: _reply(),
              user: user,
              group: group,
              medalList: medals,
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  group('replyHeaderStats', () {
    test('omits every field without data', () {
      expect(replyHeaderStats(User(uid: 1), null), isEmpty);
      expect(replyHeaderStats(null, null), isEmpty);
      expect(replyHeaderStats(User(uid: 1), const Group(1, '  ')), isEmpty);
    });

    test('keeps fields that have data, including zero values', () {
      expect(
        replyHeaderStats(
          User(uid: 1, rvrc: 0, postNum: 0),
          const Group(1, '学徒'),
        ),
        ['级别: 学徒', '威望: 0.0', '发帖: 0'],
      );
      expect(replyHeaderStats(User(uid: 1, postNum: 12), null), ['发帖: 12']);
    });
  });

  testWidgets('header hides empty stats and the medal row entirely', (
    tester,
  ) async {
    await _pumpReply(tester, user: User(uid: 123, username: '测试用户'));

    expect(find.textContaining('级别'), findsNothing);
    expect(find.textContaining('威望'), findsNothing);
    expect(find.textContaining('发帖'), findsNothing);
    expect(find.text('-'), findsNothing);
    expect(find.byType(CachedNetworkImage), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('header shows stats and medals when present', (tester) async {
    await _pumpReply(
      tester,
      user: User(uid: 123, username: '测试用户', rvrc: 25, postNum: 8),
      group: const Group(1, '学徒'),
      medals: const [Medal(1, '勋章', '说明', 'medal.png')],
    );

    expect(find.text('级别: 学徒'), findsOneWidget);
    expect(find.text('威望: 2.5'), findsOneWidget);
    expect(find.text('发帖: 8'), findsOneWidget);
    expect(find.byType(CachedNetworkImage), findsOneWidget);
  });

  group('AttachmentPlaceholder', () {
    for (final (failed, icon) in [
      (false, Icons.image_outlined),
      (true, Icons.broken_image_outlined),
    ]) {
      testWidgets('uses a neutral surface with $icon', (tester) async {
        final theme = ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.brown),
        );
        await tester.pumpWidget(
          MaterialApp(
            theme: theme,
            home: Scaffold(
              body: SizedBox(
                width: 120,
                height: 120,
                child: AttachmentPlaceholder(failed: failed),
              ),
            ),
          ),
        );

        expect(find.byIcon(icon), findsOneWidget);
        final box = tester.widget<ColoredBox>(
          find.descendant(
            of: find.byType(AttachmentPlaceholder),
            matching: find.byType(ColoredBox),
          ),
        );
        expect(box.color, theme.colorScheme.surfaceContainerHighest);
        expect(find.byType(Image), findsNothing);
      });
    }
  });
}
