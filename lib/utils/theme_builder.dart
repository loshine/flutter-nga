import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// 主题构建工具类
class ThemeBuilder {
  ThemeBuilder._();

  // 经典暗金/琥珀色：与棕色 primary 完美协调，更贴近 NGA 的经典质感，同时提供足够的亮度。
  static const _secondarySeed = Color(0xFFDCA965);

  static Color getSecondaryForSeed(Color seed) {
    if (seed == Colors.brown) return const Color(0xFFDCA965);
    if (seed == Colors.blue) return Colors.lightBlue;
    if (seed == Colors.teal) return Colors.cyan;
    if (seed == Colors.green) return Colors.lightGreen;
    if (seed == Colors.purple) return Colors.deepPurpleAccent;
    if (seed == Colors.pink) return Colors.purpleAccent;
    if (seed == Colors.orange) return Colors.amber;
    if (seed == Colors.red) return Colors.deepOrange;
    if (seed == Colors.indigo) return Colors.blueAccent;
    if (seed == Colors.cyan) return Colors.lightBlueAccent;
    return _secondarySeed;
  }

  /// 从 ColorScheme 构建 ThemeData
  static ThemeData buildTheme(ColorScheme baseColorScheme, [Color? secondarySeed]) {
    final colorScheme = _withRefinedSecondary(baseColorScheme, secondarySeed);
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      // M3 Expressive 页面过渡
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.linux: ZoomPageTransitionsBuilder(),
          TargetPlatform.windows: ZoomPageTransitionsBuilder(),
          TargetPlatform.fuchsia: ZoomPageTransitionsBuilder(),
        },
      ),
      // AppBar 主题
      appBarTheme: AppBarTheme(
        centerTitle: true,
        scrolledUnderElevation: 2,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
      ),
      // Card 主题
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: colorScheme.surfaceContainerLow,
      ),
      // FAB 主题
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      // Divider 主题
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 1,
      ),
      // ListTile 主题
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      // M3 Dialog Theme
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        backgroundColor: colorScheme.surfaceContainerHigh,
      ),
      // M3 Button Themes
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
      // M3 Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(
            color: colorScheme.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(
            color: colorScheme.error,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(
            color: colorScheme.error,
            width: 2,
          ),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      bottomAppBarTheme: BottomAppBarThemeData(
        color: colorScheme.surfaceContainer,
        elevation: 0,
        height: 80,
        padding: const EdgeInsets.symmetric(horizontal: 16),
      ),
      // M3 NavigationBar Theme
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.secondaryContainer,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        height: 80,
      ),
      // M3 NavigationRail Theme
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.secondaryContainer,
        selectedIconTheme:
            IconThemeData(color: colorScheme.onSecondaryContainer),
        unselectedIconTheme:
            IconThemeData(color: colorScheme.onSurfaceVariant),
        selectedLabelTextStyle: TextStyle(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelTextStyle: TextStyle(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  static ColorScheme _withRefinedSecondary(ColorScheme base, [Color? secondarySeed]) {
    final seed = secondarySeed ?? _secondarySeed;
    final accent = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: base.brightness,
    );
    return base.copyWith(
      secondary: accent.primary,
      onSecondary: accent.onPrimary,
      secondaryContainer: accent.primaryContainer,
      onSecondaryContainer: accent.onPrimaryContainer,
      secondaryFixed: accent.primaryFixed,
      secondaryFixedDim: accent.primaryFixedDim,
      onSecondaryFixed: accent.onPrimaryFixed,
      onSecondaryFixedVariant: accent.onPrimaryFixedVariant,
    );
  }

  /// 从种子色构建亮色主题
  static ThemeData buildLightTheme(Color seedColor) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.light,
    );
    return buildTheme(colorScheme, getSecondaryForSeed(seedColor));
  }

  /// 从种子色构建暗色主题
  static ThemeData buildDarkTheme(Color seedColor) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.dark,
    );
    return buildTheme(colorScheme, getSecondaryForSeed(seedColor));
  }
}
