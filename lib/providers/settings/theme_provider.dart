import 'dart:async';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:flutter_nga/data/core/app_preferences.dart';
import 'package:flutter_nga/utils/dynamic_color_service.dart';
import 'package:flutter_nga/utils/native_theme_service.dart';
import 'package:flutter_nga/utils/theme_builder.dart';

const String _keySeedColorValue = PrefsKeys.seedColorValue;
const String _keyUseDynamicColor = PrefsKeys.useDynamicColor;

/// 预设主题色列表
class ThemeColors {
  static const List<Color> presets = [
    Colors.brown, // 默认 - 棕色
    Colors.blue, // 蓝色
    Colors.teal, // 青色
    Colors.green, // 绿色
    Colors.purple, // 紫色
    Colors.pink, // 粉色
    Colors.orange, // 橙色
    Colors.red, // 红色
    Colors.indigo, // 靛蓝
    Colors.cyan, // 青蓝
  ];

  static const List<String> names = [
    "棕色",
    "蓝色",
    "青色",
    "绿色",
    "紫色",
    "粉色",
    "橙色",
    "红色",
    "靛蓝",
    "青蓝",
  ];

  static Color get defaultColor => presets.first;
}

class ThemeState {
  final AdaptiveThemeMode? mode;
  final Color seedColor;
  final bool useDynamicColor;
  final Color? dynamicSeedColor;

  ThemeState({
    this.mode,
    Color? seedColor,
    this.useDynamicColor = false,
    this.dynamicSeedColor,
  }) : seedColor = seedColor ?? ThemeColors.defaultColor;

  /// 当前平台是否提供系统动态强调色
  bool get isDynamicColorAvailable => dynamicSeedColor != null;

  /// 动态配色已开启且平台返回了有效强调色
  bool get isDynamicColorActive => useDynamicColor && dynamicSeedColor != null;

  /// 实际生效的主题种子色
  Color get effectiveSeedColor =>
      isDynamicColorActive ? dynamicSeedColor! : seedColor;

  String get modeName {
    switch (mode) {
      case AdaptiveThemeMode.light:
        return "亮色主题";
      case AdaptiveThemeMode.dark:
        return "暗色主题";
      case AdaptiveThemeMode.system:
      case null:
        return "跟随系统";
    }
  }

  String get seedColorName {
    final index = ThemeColors.presets.indexOf(seedColor);
    if (index >= 0 && index < ThemeColors.names.length) {
      return ThemeColors.names[index];
    }
    return "自定义";
  }

  /// 当前颜色方案展示名（动态配色优先）
  String get colorDisplayName => isDynamicColorActive ? "动态配色" : seedColorName;

  ThemeState copyWith({
    AdaptiveThemeMode? mode,
    Color? seedColor,
    bool? useDynamicColor,
    Color? dynamicSeedColor,
  }) {
    return ThemeState(
      mode: mode ?? this.mode,
      seedColor: seedColor ?? this.seedColor,
      useDynamicColor: useDynamicColor ?? this.useDynamicColor,
      dynamicSeedColor: dynamicSeedColor ?? this.dynamicSeedColor,
    );
  }
}

class ThemeNotifier extends Notifier<ThemeState> {
  /// [initialState] 通常由 `main()` 在 `runApp` 前通过 [loadSaved] 预读后注入，
  /// 保证首帧就使用已保存的主题色，而不是先用默认色。
  ThemeNotifier([this._initialState]);

  final ThemeState? _initialState;

  @override
  ThemeState build() => _initialState ?? ThemeState();

  /// 读取已保存的主题模式、主题色与系统动态配色，可在 `runApp` 前调用。
  static Future<ThemeState> loadSaved() async {
    // 先取 AppPreferences：它会等待旧版设置迁移完成（含 adaptive_theme 的
    // 亮/暗模式），再读主题模式才不会读到迁移前的空值。
    final prefs = await AppPreferences.instance();
    final mode = await AdaptiveTheme.getThemeMode();
    final seedColor = seedColorFromValue(prefs.getInt(_keySeedColorValue));
    final useDynamicColor = prefs.getBool(_keyUseDynamicColor) ?? false;
    final dynamicSeedColor = await DynamicColorService.getSystemAccentColor();
    return ThemeState(
      mode: mode,
      seedColor: seedColor,
      useDynamicColor: useDynamicColor,
      dynamicSeedColor: dynamicSeedColor,
    );
  }

  /// 把保存的 ARGB 值还原为颜色。
  ///
  /// 命中预设时返回预设里的 [MaterialColor] 实例：[Color] 的 `==` 会比较
  /// runtimeType，直接用 `Color(value)` 会导致预设匹配失败（主题色名称显示
  /// 为「自定义」、辅色回退为默认值）。
  @visibleForTesting
  static Color seedColorFromValue(int? value) {
    if (value == null) return ThemeColors.defaultColor;
    for (final preset in ThemeColors.presets) {
      if (preset.toARGB32() == value) return preset;
    }
    return Color(value);
  }

  Future<void> refresh() async {
    final saved = await loadSaved();
    state = saved;
  }

  void update(BuildContext context, AdaptiveThemeMode adaptiveThemeMode) {
    AdaptiveTheme.of(context).setThemeMode(adaptiveThemeMode);
    state = state.copyWith(mode: adaptiveThemeMode);
    unawaited(NativeThemeService.setNightMode(adaptiveThemeMode));
  }

  Future<void> setUseDynamicColor(BuildContext context, bool enabled) async {
    final adaptiveTheme = AdaptiveTheme.of(context);
    final prefs = await AppPreferences.instance();
    await prefs.setBool(_keyUseDynamicColor, enabled);
    state = state.copyWith(useDynamicColor: enabled);
    _applyThemeWithRef(adaptiveTheme, state);
  }

  Future<void> setSeedColor(BuildContext context, Color color) async {
    // Get AdaptiveTheme reference before async gap
    final adaptiveTheme = AdaptiveTheme.of(context);

    final prefs = await AppPreferences.instance();
    await prefs.setInt(_keySeedColorValue, color.toARGB32());
    await prefs.setBool(_keyUseDynamicColor, false);
    state = state.copyWith(seedColor: color, useDynamicColor: false);

    // Apply theme using AdaptiveTheme API
    _applyThemeWithRef(adaptiveTheme, state);
  }

  void _applyThemeWithRef(
    AdaptiveThemeManager<ThemeData> adaptiveTheme,
    ThemeState next,
  ) {
    final seed = next.effectiveSeedColor;
    final isDynamic = next.isDynamicColorActive;
    adaptiveTheme.setTheme(
      light: ThemeBuilder.buildLightTheme(seed, isDynamic: isDynamic),
      dark: ThemeBuilder.buildDarkTheme(seed, isDynamic: isDynamic),
    );
  }
}

final themeProvider = NotifierProvider<ThemeNotifier, ThemeState>(
  ThemeNotifier.new,
);
