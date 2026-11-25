import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_nga/ui/page/settings/open_source_license_page.dart';

void main() {
  testWidgets('宽屏双栏展示开源包列表、许可正文并支持筛选', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1000, 700));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final stream = Stream<LicenseEntry>.fromIterable([
      const LicenseEntryWithLineBreaks(['zeta_pkg'], 'MIT License for zeta'),
      const LicenseEntryWithLineBreaks(['alpha_pkg'], 'Apache License 2.0'),
    ]);

    await tester.pumpWidget(
      MaterialApp(
        home: OpenSourceLicensePage(
          applicationName: 'FNGA',
          applicationVersion: '1.1.0',
          licenseStream: stream,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 按字母序排在第一的 alpha_pkg 默认选中并展示正文
    expect(find.text('alpha_pkg'), findsWidgets);
    expect(find.text('Apache License 2.0'), findsOneWidget);

    // 切换到 zeta_pkg
    await tester.tap(find.text('zeta_pkg'));
    await tester.pumpAndSettle();
    expect(find.text('MIT License for zeta'), findsOneWidget);

    // 输入筛选关键词
    await tester.enterText(find.byType(TextField), 'alpha');
    await tester.pumpAndSettle();
    expect(find.text('zeta_pkg'), findsNothing);
    expect(find.text('Apache License 2.0'), findsOneWidget);
  });
}
