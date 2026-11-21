import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:flutter_nga/providers/settings/theme_provider.dart';
import 'package:flutter_nga/ui/widget/app_adaptive_theme.dart';
import 'package:flutter_nga/ui/widget/theme_selection_dialog.dart';

import '../../test_utils/preferences.dart';

void main() {
  testWidgets('支持系统动态配色时展示动态配色开关，并保持 48dp 调色盘触控区', (tester) async {
    setUpTestPreferences();
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final initial = ThemeState(
      mode: AdaptiveThemeMode.system,
      seedColor: Colors.brown,
      useDynamicColor: false,
      dynamicSeedColor: const Color(0xFF336699),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [themeProvider.overrideWith(() => ThemeNotifier(initial))],
        child: AppAdaptiveTheme(
          initialMode: AdaptiveThemeMode.light,
          builder: (light, dark) => MaterialApp(
            theme: light,
            darkTheme: dark,
            home: Builder(
              builder: (context) => Scaffold(
                body: Center(
                  child: FilledButton(
                    onPressed: () => ThemeSelectionDialog.show(context),
                    child: const Text('打开'),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('打开'));
    await tester.pumpAndSettle();

    expect(find.byType(BottomSheet), findsOneWidget);
    expect(find.text('动态配色'), findsOneWidget);
    expect(find.byTooltip('棕色'), findsOneWidget);
    expect(tester.getSize(find.byTooltip('棕色')), const Size(48, 48));

    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(tester.widget<Switch>(find.byType(Switch)).value, isTrue);
  });

  testWidgets('宽屏下以居中 Dialog 展示主题选择面板', (tester) async {
    setUpTestPreferences();
    tester.view.physicalSize = const Size(900, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        child: AppAdaptiveTheme(
          initialMode: AdaptiveThemeMode.light,
          builder: (light, dark) => MaterialApp(
            theme: light,
            darkTheme: dark,
            home: Builder(
              builder: (context) => Scaffold(
                body: Center(
                  child: FilledButton(
                    onPressed: () => ThemeSelectionDialog.show(context),
                    child: const Text('打开'),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('打开'));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsOneWidget);
    expect(find.byType(BottomSheet), findsNothing);
  });
}
