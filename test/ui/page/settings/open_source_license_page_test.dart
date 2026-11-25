import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_nga/ui/page/settings/open_source_license_page.dart';

void main() {
  testWidgets('宽屏双栏展示开源包列表、许可正文并按包名保持筛选选中态', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1000, 700));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final stream = Stream<LicenseEntry>.fromIterable([
      const LicenseEntryWithLineBreaks(['zeta_pkg'], 'MIT License for zeta'),
      const LicenseEntryWithLineBreaks(['beta_pkg'], 'BSD License for beta'),
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

    // 切换到第 3 项 zeta_pkg
    await tester.tap(find.text('zeta_pkg'));
    await tester.pumpAndSettle();
    expect(find.text('MIT License for zeta'), findsOneWidget);

    // 输入筛选词仍保留 zeta_pkg，不按旧下标错选
    await tester.enterText(find.byType(TextField), 'zeta');
    await tester.pumpAndSettle();
    expect(find.text('alpha_pkg'), findsNothing);
    expect(find.text('MIT License for zeta'), findsOneWidget);

    // Esc 先清空搜索框而不是关闭页面
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.byType(OpenSourceLicensePage), findsOneWidget);
    expect(find.text('alpha_pkg'), findsWidgets);
    // 清空后仍保持选中 zeta_pkg
    expect(find.text('MIT License for zeta'), findsOneWidget);
  });

  testWidgets('页面销毁时立即取消未完成的许可流订阅', (tester) async {
    var canceled = false;
    final controller = StreamController<LicenseEntry>(
      onCancel: () => canceled = true,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: OpenSourceLicensePage(
          applicationName: 'FNGA',
          applicationVersion: '1.1.0',
          licenseStream: controller.stream,
        ),
      ),
    );
    await tester.pump();
    expect(canceled, isFalse);

    await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
    await tester.pump();
    expect(canceled, isTrue);
  });
}
