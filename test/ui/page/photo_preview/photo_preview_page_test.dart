import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:flutter_nga/ui/page/photo_preview/photo_preview_page.dart';

void main() {
  testWidgets('图片预览页采用沉浸式暗色背景并提供保存按钮', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: PhotoPreviewPage(url: 'https://example.com/a.png'),
        ),
      ),
    );
    await tester.pump();

    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.backgroundColor, Colors.black);
    expect(scaffold.extendBodyBehindAppBar, isTrue);
    expect(find.byTooltip('保存图片'), findsOneWidget);
    expect(find.byIcon(Icons.download_outlined), findsOneWidget);
  });

  testWidgets('空图片链接展示失败提示且不展示保存按钮', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: PhotoPreviewPage(url: '')),
      ),
    );
    await tester.pump();

    expect(find.text('图片加载失败'), findsOneWidget);
    expect(find.byTooltip('保存图片'), findsNothing);
  });

  testWidgets('按 Esc 键可关闭图片预览页', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const PhotoPreviewPage(url: ''),
                  ),
                ),
                child: const Text('打开'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('打开'));
    await tester.pumpAndSettle();
    expect(find.byType(PhotoPreviewPage), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.byType(PhotoPreviewPage), findsNothing);
  });
}
