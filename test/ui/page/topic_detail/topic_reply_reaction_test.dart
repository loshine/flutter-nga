import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_nga/data/entity/topic_detail.dart';
import 'package:flutter_nga/data/entity/user.dart';
import 'package:flutter_nga/ui/page/topic_detail/topic_reply_item_widget.dart';

void main() {
  testWidgets('like and dislike buttons have a 48dp touch target', (
    tester,
  ) async {
    await tester.pumpWidget(
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
                  commentList: [],
                  attachmentList: [],
                ),
                user: User(uid: 123, username: '测试用户'),
                medalList: const [],
              ),
            ),
          ),
        ),
      ),
    );

    for (final tooltip in ['点赞', '点踩']) {
      final size = tester.getSize(
        find.ancestor(
          of: find.byTooltip(tooltip),
          matching: find.byType(IconButton),
        ),
      );
      expect(size.width, greaterThanOrEqualTo(48), reason: tooltip);
      expect(size.height, greaterThanOrEqualTo(48), reason: tooltip);
    }
    expect(tester.takeException(), isNull);
  }, variant: TargetPlatformVariant.only(TargetPlatform.android));
}
