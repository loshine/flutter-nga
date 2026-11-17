import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:flutter_nga/data/entity/topic_detail.dart';
import 'package:flutter_nga/data/entity/user.dart';
import 'package:flutter_nga/ui/page/topic_detail/topic_reply_item_widget.dart';
import 'package:flutter_nga/ui/widget/nga_html_content_widget.dart';

void main() {
  testWidgets('short floor content is left aligned', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: ListView(
              children: [
                TopicReplyItemWidget(
                  reply: Reply(
                    content: '短正文',
                    tid: 1,
                    pid: 2,
                    authorId: 123,
                    postDate: '2026-11-17 12:00',
                    commentList: [],
                    attachmentList: [],
                  ),
                  user: User(uid: 123, username: '测试用户'),
                  medalList: const [],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    final screenWidth =
        tester.view.physicalSize.width / tester.view.devicePixelRatio;
    final content = tester.getRect(find.byType(NgaHtmlContentWidget));
    expect(content.left, 16);
    expect(content.width, screenWidth - 32);
    final text = tester.getRect(
      find.textContaining('短正文', findRichText: true).first,
    );
    expect(text.left, 16);
  });
}
