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

  /// 根据当前生效的设计风格调整 [ThemeData]：
  /// Apple 风格下关闭水波纹、精校 macOS / iOS 系统色阶、紧凑桌面密度与细分割线，
  /// 并同步 [CupertinoThemeData]。
  static ThemeData applyDesignStyle(
    ThemeData base, {
    required bool isAppleStyle,
    bool isMacDesktop = false,
  }) {
    final cupertinoTheme = buildCupertinoTheme(
      base.colorScheme,
      isMacDesktop: isMacDesktop,
    );
    if (!isAppleStyle) {
      return base.copyWith(cupertinoOverrideTheme: cupertinoTheme);
    }

    final isDark = base.brightness == Brightness.dark;
    // macOS：内容区纯白/深炭灰 + 柔和浅灰侧边栏；iOS：标准系统分组灰底 + 卡片白底
    final canvasBg = isMacDesktop
        ? (isDark ? const Color(0xFF1A1A1C) : const Color(0xFFFFFFFF))
        : (isDark ? const Color(0xFF000000) : const Color(0xFFF2F2F7));
    final sidebarOrCardBg = isMacDesktop
        ? (isDark ? const Color(0xFF232326) : const Color(0xFFF4F4F6))
        : (isDark ? const Color(0xFF1C1C1E) : const Color(0xFFFFFFFF));
    final elevatedBg = isMacDesktop
        ? (isDark ? const Color(0xFF2B2B2E) : const Color(0xFFF7F7F9))
        : (isDark ? const Color(0xFF2C2C2E) : const Color(0xFFFFFFFF));
    final separatorColor = isDark
        ? Colors.white.withValues(alpha: 0.11)
        : Colors.black.withValues(alpha: 0.09);

    final colorScheme = base.colorScheme.copyWith(
      surface: canvasBg,
      surfaceContainerLow: sidebarOrCardBg,
      surfaceContainer: isDark
          ? const Color(0xFF222225)
          : const Color(0xFFF6F6F8),
      surfaceContainerHigh: elevatedBg,
      surfaceContainerHighest: isDark
          ? const Color(0xFF343438)
          : const Color(0xFFE8E8ED),
      outlineVariant: separatorColor,
    );

    final density = isMacDesktop
        ? const VisualDensity(horizontal: -2, vertical: -2)
        : VisualDensity.standard;

    return base.copyWith(
      colorScheme: colorScheme,
      visualDensity: density,
      cupertinoOverrideTheme: buildCupertinoTheme(
        colorScheme,
        isMacDesktop: isMacDesktop,
      ),
      scaffoldBackgroundColor: canvasBg,
      splashFactory: NoSplash.splashFactory,
      highlightColor: colorScheme.onSurface.withValues(alpha: 0.05),
      hoverColor: colorScheme.onSurface.withValues(alpha: 0.045),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.linux: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
          TargetPlatform.fuchsia: CupertinoPageTransitionsBuilder(),
        },
      ),
      dividerTheme: DividerThemeData(color: separatorColor, thickness: 0.5),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isMacDesktop ? 10 : 12),
          side: BorderSide(color: separatorColor, width: 0.5),
        ),
        color: sidebarOrCardBg,
      ),
      iconButtonTheme: isMacDesktop
          ? IconButtonThemeData(
              style: IconButton.styleFrom(
                minimumSize: const Size(30, 30),
                padding: const EdgeInsets.all(6),
                iconSize: 17,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            )
          : null,
      popupMenuTheme: PopupMenuThemeData(
        elevation: 6,
        color: isDark ? const Color(0xFF2A2A2D) : const Color(0xFFFBFBFD),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: separatorColor, width: 0.5),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        elevation: 4,
        backgroundColor: isDark
            ? const Color(0xFF2C2C2E)
            : const Color(0xFFFDFDFF),
        contentTextStyle: TextStyle(
          fontSize: isMacDesktop ? 13 : 14,
          color: colorScheme.onSurface,
        ),
        actionTextColor: colorScheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: separatorColor, width: 0.5),
        ),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: !isMacDesktop,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: canvasBg,
        foregroundColor: colorScheme.onSurface,
      ),
    );
  }

  /// 构建与当前配色方案同步的 [CupertinoThemeData]。
  static CupertinoThemeData buildCupertinoTheme(
    ColorScheme colorScheme, {
    bool isMacDesktop = false,
  }) {
    final isDark = colorScheme.brightness == Brightness.dark;
    return CupertinoThemeData(
      brightness: colorScheme.brightness,
      primaryColor: colorScheme.primary,
      primaryContrastingColor: colorScheme.onPrimary,
      scaffoldBackgroundColor: isMacDesktop
          ? (isDark ? const Color(0xFF1A1A1C) : const Color(0xFFFFFFFF))
          : (isDark ? const Color(0xFF000000) : const Color(0xFFF2F2F7)),
      barBackgroundColor: isDark
          ? const Color(0xCC1E1E20)
          : const Color(0xDDF9F9FB),
    );
  }

  /// 高对比度暗色主题（响应系统高对比度无障碍设置）
  static ThemeData buildHighContrastDarkTheme(
    Color seedColor, {
    bool isDynamic = false,
  }) {
    return buildDarkTheme(seedColor, isDynamic: isDynamic, contrastLevel: 1.0);
  }
}
