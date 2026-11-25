import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';

/// 主题构建工具类
class ThemeBuilder {
  ThemeBuilder._();

  // 经典暗金/琥珀色：与棕色 primary 完美协调，更贴近 NGA 的经典质感，同时提供足够的亮度。
  static const _secondarySeed = Color(0xFFDCA965);

  /// 仅为经典棕色主题提供暗金辅色；其他预设与系统动态配色保留 M3 原生和谐的
  /// tonal secondary 色阶，避免选中胶囊与 primaryContainer 争夺焦点。
  static Color? getSecondaryForSeed(Color seed, {bool isDynamic = false}) {
    if (isDynamic) return null;
    if (seed == Colors.brown) return _secondarySeed;
    return null;
  }

  /// 从 ColorScheme 构建 ThemeData
  static ThemeData buildTheme(
    ColorScheme baseColorScheme, [
    Color? secondarySeed,
    double contrastLevel = 0.0,
  ]) {
    final colorScheme = secondarySeed == null
        ? baseColorScheme
        : _withRefinedSecondary(
            baseColorScheme,
            secondarySeed,
            contrastLevel: contrastLevel,
          );
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: colorScheme.surfaceContainerLow,
      ),
      // FAB 主题
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      // Divider 主题
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 1,
      ),
      // ListTile 主题
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      // M3 Dialog Theme
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
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
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: colorScheme.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      bottomAppBarTheme: BottomAppBarThemeData(
        color: colorScheme.surfaceContainer,
        elevation: 0,
        height: 80,
        padding: const EdgeInsets.symmetric(horizontal: 16),
      ),
      // M3 NavigationBar Theme
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surfaceContainer,
        indicatorColor: colorScheme.secondaryContainer,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        height: 80,
      ),
      // M3 NavigationRail Theme
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.secondaryContainer,
        selectedIconTheme: IconThemeData(
          color: colorScheme.onSecondaryContainer,
        ),
        unselectedIconTheme: IconThemeData(color: colorScheme.onSurfaceVariant),
        selectedLabelTextStyle: TextStyle(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelTextStyle: TextStyle(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      // M3 NavigationDrawer Theme（大屏永久侧边导航栏：胶囊同时包裹图标和文字）
      navigationDrawerTheme: NavigationDrawerThemeData(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        elevation: 0,
        tileHeight: 52,
        indicatorColor: colorScheme.secondaryContainer,
        indicatorShape: const StadiumBorder(),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          return IconThemeData(
            size: 24,
            color: states.contains(WidgetState.selected)
                ? colorScheme.onSecondaryContainer
                : colorScheme.onSurfaceVariant,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final isSelected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected
                ? colorScheme.onSecondaryContainer
                : colorScheme.onSurfaceVariant,
          );
        }),
      ),
      // M3 2024+ Slider 样式：垂直手柄 + 轨道间隙 + 拖动数值气泡
      sliderTheme: SliderThemeData(
        trackHeight: 16,
        trackGap: 6,
        trackShape: const GappedSliderTrackShape(),
        thumbShape: const HandleThumbShape(),
        thumbSize: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.dragged)) {
            return const Size(2, 44);
          }
          return const Size(4, 44);
        }),
        valueIndicatorShape: const RoundedRectSliderValueIndicatorShape(),
        showValueIndicator: ShowValueIndicator.onDrag,
        activeTrackColor: colorScheme.primary,
        inactiveTrackColor: colorScheme.secondaryContainer,
        thumbColor: colorScheme.primary,
        valueIndicatorColor: colorScheme.inverseSurface,
        valueIndicatorTextStyle: TextStyle(
          color: colorScheme.onInverseSurface,
          fontWeight: FontWeight.w500,
        ),
      ),
      // M3 2024+ 进度条样式：圆角端点、轨道间隙与停顿点
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.primary,
        linearTrackColor: colorScheme.secondaryContainer,
        circularTrackColor: colorScheme.secondaryContainer,
        stopIndicatorColor: colorScheme.primary,
        strokeCap: StrokeCap.round,
        trackGap: 4,
        borderRadius: BorderRadius.circular(4),
      ),
      // M3 Switch：选中/未选中滑块图标，提升辨识度与色弱友好度
      switchTheme: SwitchThemeData(
        thumbIcon: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const Icon(Icons.check);
          }
          return const Icon(Icons.close);
        }),
      ),
      // M3 SnackBar：悬浮圆角 + inverseSurface 色阶
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: colorScheme.inverseSurface,
        contentTextStyle: TextStyle(color: colorScheme.onInverseSurface),
        actionTextColor: colorScheme.inversePrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  static ColorScheme _withRefinedSecondary(
    ColorScheme base,
    Color secondarySeed, {
    double contrastLevel = 0.0,
  }) {
    final accent = ColorScheme.fromSeed(
      seedColor: secondarySeed,
      brightness: base.brightness,
      contrastLevel: contrastLevel,
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
  static ThemeData buildLightTheme(
    Color seedColor, {
    bool isDynamic = false,
    double contrastLevel = 0.0,
  }) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.light,
      contrastLevel: contrastLevel,
    );
    return buildTheme(
      colorScheme,
      getSecondaryForSeed(seedColor, isDynamic: isDynamic),
      contrastLevel,
    );
  }

  /// 从种子色构建暗色主题
  static ThemeData buildDarkTheme(
    Color seedColor, {
    bool isDynamic = false,
    double contrastLevel = 0.0,
  }) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.dark,
      contrastLevel: contrastLevel,
    );
    return buildTheme(
      colorScheme,
      getSecondaryForSeed(seedColor, isDynamic: isDynamic),
      contrastLevel,
    );
  }

  /// 高对比度亮色主题（响应系统高对比度无障碍设置）
  static ThemeData buildHighContrastLightTheme(
    Color seedColor, {
    bool isDynamic = false,
  }) {
    return buildLightTheme(seedColor, isDynamic: isDynamic, contrastLevel: 1.0);
  }

  /// 高对比度暗色主题（响应系统高对比度无障碍设置）
  static ThemeData buildHighContrastDarkTheme(
    Color seedColor, {
    bool isDynamic = false,
  }) {
    return buildDarkTheme(seedColor, isDynamic: isDynamic, contrastLevel: 1.0);
  }
}
