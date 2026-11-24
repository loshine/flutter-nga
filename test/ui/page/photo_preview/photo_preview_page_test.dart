import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:flutter_nga/providers/common/photo_min_scale_provider.dart';
import 'package:flutter_nga/ui/page/photo_preview/photo_preview_page.dart';

class _FakePhotoMinScaleNotifier extends PhotoMinScaleNotifier {
  @override
  double build() => 0;

  @override
  Future<void> load(String url, double? screenWidth) async {}
}

void main() {
  testWidgets('图片预览页采用沉浸式暗色背景并提供保存按钮', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          photoMinScaleProvider.overrideWith(_FakePhotoMinScaleNotifier.new),
        ],
        child: const MaterialApp(
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
}
