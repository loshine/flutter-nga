import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:flutter_nga/providers/settings/design_style_provider.dart';
import 'package:flutter_nga/ui/page/publish/publish_page.dart';
import 'package:flutter_nga/utils/route.dart';

Future<void> _openPublishPage(WidgetTester tester, {String? content}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => PublishPage(tid: 1, fid: 2, content: content),
              ),
            ),
            child: const Text('打开'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('打开'));
  await tester.pumpAndSettle();
  expect(find.byType(PublishPage), findsOneWidget);
}

Future<void> _tapBack(WidgetTester tester) async {
  await tester.tap(find.byType(BackButton));
  await tester.pumpAndSettle();
}

Finder get _contentField => find.widgetWithText(TextField, '回复内容');

void main() {
  testWidgets('未编辑时直接返回', (tester) async {
    await _openPublishPage(tester);

    await _tapBack(tester);

    expect(find.text('放弃编辑？'), findsNothing);
    expect(find.byType(PublishPage), findsNothing);
  });

  testWidgets('带入的引用内容未改动时直接返回', (tester) async {
    await _openPublishPage(tester, content: '[quote]引用[/quote]\n');

    await _tapBack(tester);

    expect(find.text('放弃编辑？'), findsNothing);
    expect(find.byType(PublishPage), findsNothing);
  });

  testWidgets('有输入时返回需确认，可继续编辑或放弃', (tester) async {
    await _openPublishPage(tester, content: '[quote]引用[/quote]\n');
    await tester.enterText(_contentField, '[quote]引用[/quote]\n新的回复');
    await tester.pump();

    await _tapBack(tester);
    expect(find.text('放弃编辑？'), findsOneWidget);

    await tester.tap(find.text('继续编辑'));
    await tester.pumpAndSettle();
    expect(find.text('放弃编辑？'), findsNothing);
    expect(find.byType(PublishPage), findsOneWidget);

    await _tapBack(tester);
    await tester.tap(find.text('放弃'));
    await tester.pumpAndSettle();
    expect(find.byType(PublishPage), findsNothing);
  });

  testWidgets('只填写标题也需要确认', (tester) async {
    await _openPublishPage(tester);
    await tester.enterText(find.widgetWithText(TextField, '标题(可选)'), '标题');
    await tester.pump();

    await _tapBack(tester);

    expect(find.text('放弃编辑？'), findsOneWidget);
  });

  testWidgets('桌面端宽屏以居中弹窗打开，关闭按钮仍走放弃编辑确认', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      debugDefaultTargetPlatformOverride = null;
      tester.view.reset();
    });

    final publishRoute = buildRoutes().firstWhere(
      (r) => r.path == Routes.TOPIC_PUBLISH,
    );
    final router = GoRouter(
      initialLocation: '/host',
      routes: [
        GoRoute(
          path: '/host',
          builder: (context, _) => Scaffold(
            body: TextButton(
              onPressed: () =>
                  context.push('${Routes.TOPIC_PUBLISH}?tid=1&fid=2'),
              child: const Text('发帖入口'),
            ),
          ),
        ),
        publishRoute,
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      AppDesignStyleScope(
        style: AppDesignStyle.apple,
        nativeLiquidGlassSupported: false,
        macTitlebarInset: 52,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('发帖入口'));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsOneWidget);
    expect(find.byType(PublishPage), findsOneWidget);
    expect(find.byTooltip('关闭'), findsOneWidget);

    await tester.enterText(_contentField, '桌面弹窗回复内容');
    await tester.pump();

    // 拖动窗口宽度跨过 600pt 断点，编辑器不重建、草稿不丢失
    tester.view.physicalSize = const Size(500, 800);
    await tester.pumpAndSettle();
    expect(find.byType(PublishPage), findsOneWidget);
    expect(find.text('桌面弹窗回复内容'), findsOneWidget);

    await tester.tap(find.byTooltip('关闭'));
    await tester.pumpAndSettle();
    expect(find.text('放弃编辑？'), findsOneWidget);

    await tester.tap(find.text('放弃'));
    await tester.pumpAndSettle();
    expect(find.byType(PublishPage), findsNothing);
    expect(find.byType(Dialog), findsNothing);
  });
}
