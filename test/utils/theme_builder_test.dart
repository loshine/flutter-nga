import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_nga/utils/palette.dart';
import 'package:flutter_nga/utils/theme_builder.dart';

void main() {
  testWidgets('brown theme uses the refined amber secondary container roles', (
    tester,
  ) async {
    final base = ColorScheme.fromSeed(seedColor: Colors.brown);
    final theme = ThemeBuilder.buildLightTheme(Colors.brown);
    late Color background;
    late Color foreground;

    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: Builder(
          builder: (context) {
            background = Palette.getColorThumbBackground(context);
            foreground = Palette.getColorThumbForeground(context);
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(background, theme.colorScheme.secondaryContainer);
    expect(foreground, theme.colorScheme.onSecondaryContainer);
    expect(background, isNot(base.secondaryContainer));
  });

  test('non-brown and dynamic themes preserve native M3 secondary palette', () {
    final blueBase = ColorScheme.fromSeed(seedColor: Colors.blue);
    final blueTheme = ThemeBuilder.buildLightTheme(Colors.blue);
    expect(
      blueTheme.colorScheme.secondaryContainer,
      blueBase.secondaryContainer,
    );

    final dynamicBrownBase = ColorScheme.fromSeed(seedColor: Colors.brown);
    final dynamicBrownTheme = ThemeBuilder.buildLightTheme(
      Colors.brown,
      isDynamic: true,
    );
    expect(
      dynamicBrownTheme.colorScheme.secondaryContainer,
      dynamicBrownBase.secondaryContainer,
    );
  });

  test('refined secondary containers keep accessible contrast', () {
    for (final brightness in Brightness.values) {
      final theme = brightness == Brightness.light
          ? ThemeBuilder.buildLightTheme(Colors.brown)
          : ThemeBuilder.buildDarkTheme(Colors.brown);
      final scheme = theme.colorScheme;
      final contrast = _contrastRatio(
        scheme.secondaryContainer,
        scheme.onSecondaryContainer,
      );

      expect(contrast, greaterThanOrEqualTo(4.5));
    }
  });

  test('high contrast themes increase foreground contrast', () {
    final normalLight = ThemeBuilder.buildLightTheme(Colors.blue).colorScheme;
    final highLight = ThemeBuilder.buildHighContrastLightTheme(Colors.blue)
        .colorScheme;
    final normalDark = ThemeBuilder.buildDarkTheme(Colors.blue).colorScheme;
    final highDark = ThemeBuilder.buildHighContrastDarkTheme(Colors.blue)
        .colorScheme;

    expect(
      _contrastRatio(highLight.primary, highLight.onPrimary),
      greaterThanOrEqualTo(
        _contrastRatio(normalLight.primary, normalLight.onPrimary),
      ),
    );
    expect(
      _contrastRatio(highDark.primary, highDark.onPrimary),
      greaterThanOrEqualTo(
        _contrastRatio(normalDark.primary, normalDark.onPrimary),
      ),
    );
  });

  test(
    'configures M3 slider, progress indicator, switch, and snackbar themes',
    () {
      final theme = ThemeBuilder.buildLightTheme(Colors.brown);

      expect(theme.sliderTheme.trackShape, isA<GappedSliderTrackShape>());
      expect(theme.sliderTheme.thumbShape, isA<HandleThumbShape>());
      expect(theme.sliderTheme.showValueIndicator, ShowValueIndicator.onDrag);

      expect(theme.progressIndicatorTheme.strokeCap, StrokeCap.round);
      expect(theme.progressIndicatorTheme.trackGap, 4);

      final selectedIcon = theme.switchTheme.thumbIcon?.resolve({
        WidgetState.selected,
      });
      final unselectedIcon = theme.switchTheme.thumbIcon?.resolve({});
      expect(selectedIcon?.icon, Icons.check);
      expect(unselectedIcon?.icon, Icons.close);

      expect(theme.snackBarTheme.behavior, SnackBarBehavior.floating);
      expect(
        theme.snackBarTheme.backgroundColor,
        theme.colorScheme.inverseSurface,
      );
    },
  );

  test('Apple high contrast theme preserves high contrast surfaces and solid borders', () {
    for (final isDark in [false, true]) {
      final baseHighContrast = isDark
          ? ThemeBuilder.buildHighContrastDarkTheme(Colors.blue)
          : ThemeBuilder.buildHighContrastLightTheme(Colors.blue);
      final appleHighContrast = ThemeBuilder.applyDesignStyle(
        baseHighContrast,
        isAppleStyle: true,
        isMacDesktop: true,
        isHighContrast: true,
      );

      expect(
        appleHighContrast.colorScheme.surface,
        baseHighContrast.colorScheme.surface,
      );
      expect(
        appleHighContrast.colorScheme.surfaceContainerLow,
        baseHighContrast.colorScheme.surfaceContainerLow,
      );
      expect(
        appleHighContrast.colorScheme.outlineVariant,
        baseHighContrast.colorScheme.outline,
      );
      expect(appleHighContrast.dividerTheme.thickness, 1.0);
      expect(
        appleHighContrast.colorScheme.outlineVariant.a,
        closeTo(1.0, 0.001),
      );
    }
  });
}

double _contrastRatio(Color first, Color second) {
  final firstLuminance = first.computeLuminance();
  final secondLuminance = second.computeLuminance();
  final lighter = math.max(firstLuminance, secondLuminance);
  final darker = math.min(firstLuminance, secondLuminance);
  return (lighter + 0.05) / (darker + 0.05);
}
