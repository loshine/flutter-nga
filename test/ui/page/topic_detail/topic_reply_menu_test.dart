import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:toastification/toastification.dart';

import 'package:flutter_nga/data/entity/topic_detail.dart';
import 'package:flutter_nga/data/entity/user.dart';
import 'package:flutter_nga/providers/settings/blocklist_settings_provider.dart';
import 'package:flutter_nga/ui/page/topic_detail/topic_reply_item_widget.dart';
import 'package:flutter_nga/utils/parser/content_parser.dart';
import 'package:flutter_nga/utils/route.dart';

class _FakeBlocklistNotifier extends BlocklistSettingsNotifier {
  final added = <String>[];
  int loadCalls = 0;

  @override
  BlocklistSettingsState build() =>
      const BlocklistSettingsState(blockUserList: ['已屏蔽']);

  @override
  Future<void> load() async => loadCalls++;

  @override
  Future<String> addUser(String user) async {
    added.add(user);
    state = state.copyWith(blockUserList: [...state.blockUserList, user]);
    return '操作成功';
  }
}

class _Harness {
  _Harness(this.tester);

  final WidgetTester tester;
  final notifier = _FakeBlocklistNotifier();
  String? clipboard;
  Uri? lastRoute;

  Future<void> pump({String content = '正文', User? user, int pid = 2}) async {
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          clipboard = (call.arguments as Map)['text'] as String?;
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );

    Widget capture(BuildContext context, GoRouterState state) {
      lastRoute = state.uri;
      return const Scaffold(body: Text('目标页'));
    }

    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => Scaffold(
            body: SingleChildScrollView(
              child: TopicReplyItemWidget(
                reply: Reply(
                  content: content,
                  tid: 1,
                  fid: 7,
                  pid: pid,
                  lou: 3,
                  authorId: user?.uid ?? 123,
                  postDate: '2026-07-26 12:00',
                  commentList: [],
                  attachmentList: [],
                ),
                user: user ?? User(uid: 123, username: '测试用户'),
                medalList: const [],
              ),
            ),
          ),
        ),
        for (final path in [
          Routes.TOPIC_DETAIL,
          Routes.PHOTO_PREVIEW,
          Routes.USER,
          Routes.TOPIC_PUBLISH,
        ])
          GoRoute(path: path, builder: capture),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [blocklistSettingsProvider.overrideWith(() => notifier)],
        child: ToastificationWrapper(
          child: MaterialApp.router(routerConfig: router),
        ),
      ),
    );
    await tester.pump();
  }

  Future<void> selectMenu(String label) async {
    await tester.tap(find.byTooltip('楼层操作'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(label));
    await tester.pumpAndSettle();
  }

  Future<void> cleanUp() async {
    toastification.dismissAll(delayForAnimation: false);
    await tester.pump(const Duration(milliseconds: 700));
    toastification.managers.clear();
    await tester.pumpWidget(const SizedBox.shrink());
  }
}

void main() {
  setUp(NgaContentParser.clearCache);

  testWidgets('menu button has a 48dp touch target', (tester) async {
    final h = _Harness(tester);
    await h.pump();
    final size = tester.getSize(
      find.ancestor(
        of: find.byIcon(Icons.more_vert),
        matching: find.byType(IconButton),
      ),
    );
    expect(size.width, greaterThanOrEqualTo(48));
    expect(size.height, greaterThanOrEqualTo(48));
    await h.cleanUp();
  }, variant: TargetPlatformVariant.only(TargetPlatform.android));

  testWidgets('copy content puts plain text on the clipboard', (tester) async {
    final h = _Harness(tester);
    await h.pump(content: '[b]第一行[/b]<br/>[color=red]第二行[/color]');
    await h.selectMenu('复制内容');
    expect(h.clipboard, '第一行\n第二行');
    await h.cleanUp();
  });

  testWidgets('copy link uses the floor pid url', (tester) async {
    final h = _Harness(tester);
    await h.pump(pid: 456);
    await h.selectMenu('复制楼层链接');
    expect(h.clipboard, endsWith('/read.php?pid=456'));
    expect(h.clipboard, startsWith('https://'));
    await h.cleanUp();
  });

  testWidgets('view user opens the user page by uid', (tester) async {
    final h = _Harness(tester);
    await h.pump();
    await h.selectMenu('查看用户');
    expect(h.lastRoute?.path, Routes.USER);
    expect(h.lastRoute?.queryParameters['uid'], '123');
    await h.cleanUp();
  });

  testWidgets('blocking a user asks for confirmation first', (tester) async {
    final h = _Harness(tester);
    await h.pump();

    await h.selectMenu('屏蔽该用户');
    expect(find.textContaining('确定屏蔽「测试用户」'), findsOneWidget);
    await tester.tap(find.text('取消'));
    await tester.pumpAndSettle();
    expect(h.notifier.added, isEmpty);

    await h.selectMenu('屏蔽该用户');
    await tester.tap(find.widgetWithText(FilledButton, '屏蔽'));
    await tester.pumpAndSettle();
    expect(h.notifier.loadCalls, 1);
    expect(h.notifier.added, ['测试用户']);
    await h.cleanUp();
  });

  testWidgets('anonymous users have no view / block actions', (tester) async {
    final h = _Harness(tester);
    await h.pump(user: User(uid: -1, username: '#anony_0123456789abcdef'));
    await tester.tap(find.byTooltip('楼层操作'));
    await tester.pumpAndSettle();
    expect(find.text('复制内容'), findsOneWidget);
    expect(find.text('查看用户'), findsNothing);
    expect(find.text('屏蔽该用户'), findsNothing);
    await tester.tapAt(Offset.zero);
    await tester.pumpAndSettle();
    await h.cleanUp();
  });

  group('selectable content keeps tap gestures', () {
    testWidgets('long press shows the selection toolbar', (tester) async {
      final h = _Harness(tester);
      await h.pump(content: '一段可以选择复制的正文内容');
      expect(find.byType(SelectionArea), findsOneWidget);

      await tester.longPress(find.textContaining('一段可以选择', findRichText: true));
      await tester.pumpAndSettle();
      expect(find.text('Copy'), findsOneWidget);
      await h.cleanUp();
    }, variant: TargetPlatformVariant.only(TargetPlatform.android));

    testWidgets('links still navigate', (tester) async {
      final h = _Harness(tester);
      await h.pump(
        content: '[url=https://bbs.nga.cn/read.php?tid=999]站内帖子[/url]',
      );
      // RichText 撑满整行，点中心会落在文字右侧的空白处，改点文字起始位置。
      final link = find.textContaining('站内帖子', findRichText: true);
      await tester.tapAt(tester.getTopLeft(link) + const Offset(8, 8));
      await tester.pumpAndSettle();
      expect(h.lastRoute?.path, Routes.TOPIC_DETAIL);
      expect(h.lastRoute?.queryParameters['tid'], '999');
      await h.cleanUp();
    });

    testWidgets('images still open the preview', (tester) async {
      final h = _Harness(tester);
      await h.pump(content: '[img]https://img.nga.cn/attachments/a.jpg[/img]');
      await tester.tap(
        find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.hint == '查看大图',
        ),
      );
      await tester.pumpAndSettle();
      expect(h.lastRoute?.path, Routes.PHOTO_PREVIEW);
      await h.cleanUp();
    });

    testWidgets('collapse blocks still toggle', (tester) async {
      final h = _Harness(tester);
      await h.pump(content: '[collapse=剧透]隐藏内容[/collapse]');
      await tester.tap(find.textContaining('点击展开'));
      await tester.pumpAndSettle();
      expect(find.textContaining('点击收起'), findsOneWidget);
      await h.cleanUp();
    });
  });
}
