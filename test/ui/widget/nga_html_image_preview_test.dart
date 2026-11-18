import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:flutter_nga/ui/widget/nga_html_extensions.dart';
import 'package:flutter_nga/utils/route.dart';

final _previewTarget = find.byWidgetPredicate(
  (w) => w is Semantics && w.properties.hint == '查看大图',
);

/// 渲染 [html]，返回进入图片预览页时的查询参数（未进入则为 null）。
Future<Map<String, String>? Function()> _pumpWithRouter(
  WidgetTester tester,
  String html,
) async {
  Map<String, String>? previewParams;
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) =>
            Scaffold(body: SingleChildScrollView(child: NgaHtml(html))),
      ),
      GoRoute(
        path: Routes.PHOTO_PREVIEW,
        builder: (context, state) {
          previewParams = state.uri.queryParameters;
          return const SizedBox.shrink();
        },
      ),
    ],
  );
  await tester.pumpWidget(MaterialApp.router(routerConfig: router));
  await tester.pump();
  return () => previewParams;
}

void main() {
  testWidgets('tapping a content image opens the photo preview', (
    tester,
  ) async {
    const url = 'https://img.nga.178.com/attachments/中文 a.jpg?x=1&y=2';
    final params = await _pumpWithRouter(tester, "<img src='$url' />");

    expect(_previewTarget, findsOneWidget);
    await tester.tap(_previewTarget);
    await tester.pumpAndSettle();

    expect(params()?['url'], url);
    expect(double.tryParse(params()?['screenWidth'] ?? ''), greaterThan(0));
  });

  testWidgets('emoticons are not previewable', (tester) async {
    await _pumpWithRouter(
      tester,
      "前<nga_emoticon src='https://img4.nga.cn/ngabbs/post/smile/ac0.png' "
      "height='32' descent='4'></nga_emoticon>后",
    );

    expect(_previewTarget, findsNothing);
  });

  testWidgets('images inside links keep the link behavior', (tester) async {
    await _pumpWithRouter(
      tester,
      "<a href='https://example.com'>"
      "<img src='https://img.nga.178.com/attachments/a.jpg' /></a>",
    );

    expect(_previewTarget, findsNothing);
  });
}
