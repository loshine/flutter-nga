import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:flutter_nga/data/core/app_preferences.dart';
import 'package:flutter_nga/providers/settings/theme_provider.dart';
import 'package:flutter_nga/ui/widget/app_adaptive_theme.dart';
import 'package:flutter_nga/utils/theme_builder.dart';

import '../../test_utils/preferences.dart';

/// 模拟冷启动前新存储（SharedPreferencesWithCache）里已保存的主题色。
void _mockSavedSeedColor(Color? color) {
  setUpTestPreferences(
    current: {
      if (color != null) PrefsKeys.seedColorValue: color.toARGB32(),
    },
  );
}

void main() {
  group('ThemeNotifier.seedColorFromValue', () {
    test('预设值还原为预设实例，保证名称与辅色匹配', () {
      for (final preset in ThemeColors.presets) {
        final restored = ThemeNotifier.seedColorFromValue(preset.toARGB32());
        expect(identical(restored, preset), isTrue);
      }
      final state = ThemeState(
        seedColor: ThemeNotifier.seedColorFromValue(Colors.blue.toARGB32()),
      );
      expect(state.seedColorName, '蓝色');
      expect(
        ThemeBuilder.getSecondaryForSeed(state.seedColor),
        Colors.lightBlue,
      );
    });

    test('未保存时返回默认色，非预设值原样保留', () {
      expect(ThemeNotifier.seedColorFromValue(null), ThemeColors.defaultColor);
      expect(
        ThemeNotifier.seedColorFromValue(0xFF123456),
        const Color(0xFF123456),
      );
    });
  });

  test('loadSaved 读取已保存的主题色', () async {
    _mockSavedSeedColor(Colors.teal);

    final saved = await ThemeNotifier.loadSaved();

    expect(identical(saved.seedColor, Colors.teal), isTrue);
    expect(saved.seedColorName, '青色');
  });

  test('loadSaved 无保存值时为默认色', () async {
    _mockSavedSeedColor(null);

    final saved = await ThemeNotifier.loadSaved();

    expect(saved.seedColor, ThemeColors.defaultColor);
  });

  test('老用户升级后首次启动读取迁移过来的主题色', () async {
    setUpTestPreferences(
      legacy: {PrefsKeys.seedColorValue: Colors.orange.toARGB32()},
    );

    final saved = await ThemeNotifier.loadSaved();

    expect(identical(saved.seedColor, Colors.orange), isTrue);
  });

  test('注入的初始状态在首次读取时即生效', () async {
    _mockSavedSeedColor(Colors.purple);
    final saved = await ThemeNotifier.loadSaved();
    final container = ProviderContainer(
      overrides: [themeProvider.overrideWith(() => ThemeNotifier(saved))],
    );
    addTearDown(container.dispose);

    expect(container.read(themeProvider).seedColor, Colors.purple);
  });

  testWidgets('冷启动首帧即使用已保存的主题色', (tester) async {
    _mockSavedSeedColor(Colors.blue);
    // 与 main() 相同：runApp 前预读并注入。
    final saved = await tester.runAsync(ThemeNotifier.loadSaved);

    late ThemeData appliedTheme;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [themeProvider.overrideWith(() => ThemeNotifier(saved))],
        child: AppAdaptiveTheme(
          initialMode: saved!.mode,
          builder: (light, dark) => MaterialApp(
            theme: light,
            darkTheme: dark,
            home: Builder(
              builder: (context) {
                appliedTheme = Theme.of(context);
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      ),
    );

    final expected = ThemeBuilder.buildLightTheme(Colors.blue).colorScheme;
    final fallback = ThemeBuilder.buildLightTheme(Colors.brown).colorScheme;
    expect(appliedTheme.colorScheme.primary, expected.primary);
    expect(appliedTheme.colorScheme.secondary, expected.secondary);
    expect(appliedTheme.colorScheme.primary, isNot(fallback.primary));
  });
}
