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
}

double _contrastRatio(Color first, Color second) {
  final firstLuminance = first.computeLuminance();
  final secondLuminance = second.computeLuminance();
  final lighter = math.max(firstLuminance, secondLuminance);
  final darker = math.min(firstLuminance, secondLuminance);
  return (lighter + 0.05) / (darker + 0.05);
}
