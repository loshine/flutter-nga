import 'package:flutter/material.dart' as legacy;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';

import 'package:flutter_nga/ui/widget/legacy_theme_bridge.dart';
import 'package:flutter_nga/utils/hooks/material_tab_controller_hook.dart';
import 'package:flutter_nga/utils/theme_builder.dart';

void main() {
  testWidgets('tab controller survives rebuild and recreates for page count', (
    tester,
  ) async {
    late TabController controller;
    Widget app(int length) => MaterialApp(
      home: HookBuilder(
        builder: (context) {
          controller = useMaterialTabController(
            initialLength: length,
            initialIndex: length - 1,
            keys: [length],
          );
          return Scaffold(
            body: TabBarView(
              controller: controller,
              children: List.generate(length, (i) => Text('page $i')),
            ),
          );
        },
      ),
    );

    await tester.pumpWidget(app(2));
    final original = controller;
    controller.animateTo(0);
    await tester.pumpAndSettle();
    await tester.pumpWidget(app(2));
    expect(controller, same(original));
    expect(controller.index, 0);
    // Change page count while an animation is running, then unmount.
    controller.animateTo(1);
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pumpWidget(app(3));
    expect(controller, isNot(same(original)));
    expect(controller.index, 2);
    controller.animateTo(0);
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pumpWidget(const SizedBox.shrink());
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'adaptive theme propagates mode and seed color to legacy widgets',
    (tester) async {
      final previous = SharedPreferencesAsyncPlatform.instance;
      SharedPreferencesAsyncPlatform.instance =
          InMemorySharedPreferencesAsync.empty();
      addTearDown(() => SharedPreferencesAsyncPlatform.instance = previous);
      late BuildContext contentContext;
      late ThemeData modernTheme;
      late legacy.ThemeData legacyTheme;
      await tester.pumpWidget(
        AdaptiveTheme(
          light: ThemeBuilder.buildLightTheme(Colors.brown),
          dark: ThemeBuilder.buildDarkTheme(Colors.brown),
          initial: AdaptiveThemeMode.light,
          builder: (light, dark) => MaterialApp(
            theme: light,
            darkTheme: dark,
            builder: (context, child) => LegacyThemeBridge(child: child!),
            home: Builder(
              builder: (context) {
                contentContext = context;
                modernTheme = Theme.of(context);
                legacyTheme = legacy.Theme.of(context);
                expect(legacy.MaterialLocalizations.of(context), isNotNull);
                return const Scaffold(body: Text('theme'));
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(modernTheme.brightness, Brightness.light);
      expect(legacyTheme.colorScheme.primary, modernTheme.colorScheme.primary);
      final manager = AdaptiveTheme.of(contentContext);
      manager.setDark();
      await tester.pumpAndSettle();
      expect(modernTheme.brightness, Brightness.dark);
      expect(legacyTheme.brightness, Brightness.dark);
      manager.setTheme(
        light: ThemeBuilder.buildLightTheme(Colors.blue),
        dark: ThemeBuilder.buildDarkTheme(Colors.blue),
      );
      await tester.pumpAndSettle();
      expect(
        modernTheme.colorScheme.primary,
        ThemeBuilder.buildDarkTheme(Colors.blue).colorScheme.primary,
      );
      expect(legacyTheme.colorScheme.primary, modernTheme.colorScheme.primary);
      tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
      manager.setSystem();
      await tester.pumpAndSettle();
      expect(modernTheme.brightness, Brightness.light);
      tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
      await tester.pumpAndSettle();
      expect(modernTheme.brightness, Brightness.dark);
      expect(legacyTheme.brightness, Brightness.dark);
    },
  );
}
