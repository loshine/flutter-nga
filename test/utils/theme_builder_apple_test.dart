import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_nga/utils/theme_builder.dart';

void main() {
  test('Apple 风格覆写按钮圆角为 8/10pt，Material 端保持胶囊圆角', () {
    final base = ThemeBuilder.buildTheme(
      ColorScheme.fromSeed(seedColor: Colors.amber),
    );

    final macApple = ThemeBuilder.applyDesignStyle(
      base,
      isAppleStyle: true,
      isMacDesktop: true,
    );
    final iosApple = ThemeBuilder.applyDesignStyle(
      base,
      isAppleStyle: true,
      isMacDesktop: false,
    );
    final material = ThemeBuilder.applyDesignStyle(base, isAppleStyle: false);

    BorderRadius? radiusOf(ButtonStyle? style) {
      final shape = style?.shape?.resolve(const {});
      return shape is RoundedRectangleBorder
          ? shape.borderRadius as BorderRadius?
          : null;
    }

    expect(
      radiusOf(macApple.filledButtonTheme.style),
      BorderRadius.circular(8),
    );
    expect(
      radiusOf(macApple.outlinedButtonTheme.style),
      BorderRadius.circular(8),
    );
    expect(radiusOf(macApple.textButtonTheme.style), BorderRadius.circular(8));

    expect(
      radiusOf(iosApple.filledButtonTheme.style),
      BorderRadius.circular(10),
    );
    expect(
      radiusOf(material.filledButtonTheme.style),
      BorderRadius.circular(100),
    );
  });
}
