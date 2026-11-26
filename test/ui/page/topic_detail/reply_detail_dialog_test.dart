import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_nga/data/entity/topic_detail.dart';
import 'package:flutter_nga/data/entity/user.dart';
import 'package:flutter_nga/providers/topic/topic_reply_provider.dart';
import 'package:flutter_nga/ui/page/topic_detail/reply_detail_dialog.dart';
import 'package:flutter_nga/ui/widget/nga_html_content_widget.dart';
import 'package:flutter_nga/ui/widget/username_text.dart';

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
          topicReplyProvider(124)
              .overrideWith(() => _FakeTopicReplyNotifier(124, state)),
        ],
        child: const MaterialApp(
          home: Scaffold(body: ReplyDetailDialog(pid: 124)),
        ),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.textContaining('被引用的原文', findRichText: true), findsOneWidget);
    expect(find.textContaining('回复正文', findRichText: true), findsOneWidget);
    expect(find.byType(UsernameText), findsOneWidget);
  });

  testWidgets('short reply content is left aligned', (tester) async {
    final reply = Reply(
      content: '短正文',
      tid: 456,
      pid: 125,
      postDate: '2026-11-17 12:00',
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
          topicReplyProvider(125)
              .overrideWith(() => _FakeTopicReplyNotifier(125, state)),
        ],
        child: const MaterialApp(
          home: Scaffold(body: ReplyDetailDialog(pid: 125)),
        ),
      ),
    );
    await tester.pump();

    final contentFinder = find.byType(NgaHtmlContentWidget);
    final column = tester.getRect(
      find.ancestor(of: contentFinder, matching: find.byType(Column)).first,
    );
    final content = tester.getRect(contentFinder);
    expect(content.left, column.left + 16);
    expect(content.right, column.right - 16);
    final text = tester.getRect(
      find.textContaining('短正文', findRichText: true).first,
    );
    expect(text.left, content.left);
  });

  testWidgets('shows retry view when loading reply fails', (tester) async {
    const errorState = TopicReplyState(hasLoaded: true, error: 'network error');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          topicReplyProvider(126)
              .overrideWith(() => _FakeTopicReplyNotifier(126, errorState)),
        ],
        child: const MaterialApp(
          home: Scaffold(body: ReplyDetailDialog(pid: 126)),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('加载回复失败'), findsOneWidget);
    expect(find.text('重试'), findsOneWidget);
  });

  testWidgets('matches reply author by authorId instead of userList[0]', (
    tester,
  ) async {
    final reply = Reply(
      content: '楼层正文',
      tid: 456,
      pid: 127,
      authorId: 2,
      postDate: '2026-11-26 00:00',
      commentList: [],
      attachmentList: [],
    );
    final state = TopicReplyState(
      replyList: [reply],
      userList: [
        User(uid: 1, username: '路人甲'),
        User(uid: 2, username: '真实作者'),
      ],
      hasLoaded: true,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          topicReplyProvider(127)
              .overrideWith(() => _FakeTopicReplyNotifier(127, state)),
        ],
        child: const MaterialApp(
          home: Scaffold(body: ReplyDetailDialog(pid: 127)),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('真实作者'), findsOneWidget);
    expect(find.text('路人甲'), findsNothing);
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
