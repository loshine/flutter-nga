import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_nga/utils/palette.dart';
import 'package:flutter_nga/utils/theme_builder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('thumb colors use the refined secondary container roles',
      (tester) async {
    final base = ColorScheme.fromSeed(seedColor: Colors.brown);
    final theme = ThemeBuilder.buildTheme(base);
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

  test('refined secondary containers keep accessible contrast', () {
    for (final brightness in Brightness.values) {
      final base = ColorScheme.fromSeed(
        seedColor: Colors.brown,
        brightness: brightness,
      );
      final scheme = ThemeBuilder.buildTheme(base).colorScheme;
      final contrast = _contrastRatio(
        scheme.secondaryContainer,
        scheme.onSecondaryContainer,
      );

      expect(contrast, greaterThanOrEqualTo(4.5));
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
