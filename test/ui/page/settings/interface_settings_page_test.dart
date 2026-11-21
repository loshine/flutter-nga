import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:flutter_nga/ui/page/settings/interface_settings_page.dart';
import 'package:flutter_nga/utils/dimen.dart';
import 'package:flutter_nga/utils/theme_builder.dart';

import '../../../test_utils/preferences.dart';

void main() {
  testWidgets('界面设置页提供实时排版预览并随滑块变化', (tester) async {
    setUpTestPreferences();

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: ThemeBuilder.buildLightTheme(Colors.brown),
          home: const InterfaceSettingsPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('实时预览'), findsOneWidget);
    final titleFinder = find.text('[讨论] 艾泽拉斯国家地理排版效果预览标题');
    expect(titleFinder, findsOneWidget);
    expect(
      tester.widget<Text>(titleFinder).style?.fontSize,
      closeTo(Dimen.titleMedium, 0.01),
    );

    final firstSlider = find.byType(Slider).first;
    await tester.drag(firstSlider, const Offset(300, 0));
    await tester.pumpAndSettle();

    expect(
      tester.widget<Text>(titleFinder).style?.fontSize,
      greaterThan(Dimen.titleMedium),
    );
  });
}
