import 'package:flutter/material.dart';
import 'package:flutter_nga/data/entity/topic_detail.dart';
import 'package:flutter_nga/data/entity/user.dart';
import 'package:flutter_nga/providers/topic/topic_reply_provider.dart';
import 'package:flutter_nga/ui/page/topic_detail/reply_detail_dialog.dart';
import 'package:flutter_nga/ui/widget/username_text.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders quoted reply content in a dialog', (tester) async {
    const content =
        '[quote][pid=123,456,1]Reply[/pid] [b]Post by [uid=789]测试用户[/uid] '
        '(2026-07-20 12:00):[/b]\n\n被引用的原文[/quote]\n回复正文';
    final reply = Reply(
      content: content,
      tid: 456,
      pid: 124,
      postDate: '2026-07-20 12:01',
      commentList: [],
      attachmentList: [],
    );
    final state = TopicReplyState(
      replyList: [reply],
      userList: [User(uid: 1, username: '回复用户')],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          topicReplyProvider(124).overrideWith(
            () => _FakeTopicReplyNotifier(124, state),
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(body: ReplyDetailDialog(pid: 124)),
        ),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.textContaining('被引用的原文'), findsOneWidget);
    expect(find.textContaining('回复正文'), findsOneWidget);
    expect(find.byType(UsernameText), findsOneWidget);
  });
}

class _FakeTopicReplyNotifier extends TopicReplyNotifier {
  _FakeTopicReplyNotifier(super.pid, this.initialState);

  final TopicReplyState initialState;

  @override
  TopicReplyState build() => initialState;

  @override
  Future<TopicReplyState> load() async => state;
}
