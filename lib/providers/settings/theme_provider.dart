import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:flutter_nga/data/core/app_preferences.dart';
import 'package:flutter_nga/utils/theme_builder.dart';

const String _keySeedColorValue = PrefsKeys.seedColorValue;

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

  ThemeState({this.mode, Color? seedColor})
    : seedColor = seedColor ?? ThemeColors.defaultColor;

  String get modeName {
    switch (mode) {
      case AdaptiveThemeMode.light:
        return "亮色主题";
      case AdaptiveThemeMode.dark:
        return "暗色主题";
      case AdaptiveThemeMode.system:
        return "跟随系统";
      default:
        return "亮色主题";
    }
  }

  String get seedColorName {
    final index = ThemeColors.presets.indexOf(seedColor);
    if (index >= 0 && index < ThemeColors.names.length) {
      return ThemeColors.names[index];
    }
    return "自定义";
  }

  ThemeState copyWith({AdaptiveThemeMode? mode, Color? seedColor}) {
    return ThemeState(
      mode: mode ?? this.mode,
      seedColor: seedColor ?? this.seedColor,
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

  /// 读取已保存的主题模式与主题色，可在 `runApp` 前调用。
  static Future<ThemeState> loadSaved() async {
    // 先取 AppPreferences：它会等待旧版设置迁移完成（含 adaptive_theme 的
    // 亮/暗模式），再读主题模式才不会读到迁移前的空值。
    final prefs = await AppPreferences.instance();
    final mode = await AdaptiveTheme.getThemeMode();
    final seedColor = seedColorFromValue(prefs.getInt(_keySeedColorValue));
    return ThemeState(mode: mode, seedColor: seedColor);
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
    state = state.copyWith(mode: saved.mode, seedColor: saved.seedColor);
  }

  void update(BuildContext context, AdaptiveThemeMode adaptiveThemeMode) {
    AdaptiveTheme.of(context).setThemeMode(adaptiveThemeMode);
    state = state.copyWith(mode: adaptiveThemeMode);
  }

  Future<void> setSeedColor(BuildContext context, Color color) async {
    // Get AdaptiveTheme reference before async gap
    final adaptiveTheme = AdaptiveTheme.of(context);

    final prefs = await AppPreferences.instance();
    await prefs.setInt(_keySeedColorValue, color.toARGB32());
    state = state.copyWith(seedColor: color);

    // Apply theme using AdaptiveTheme API
    _applyThemeWithRef(adaptiveTheme, color);
  }

  void _applyThemeWithRef(
    AdaptiveThemeManager<ThemeData> adaptiveTheme,
    Color seedColor,
  ) {
    adaptiveTheme.setTheme(
      light: ThemeBuilder.buildLightTheme(seedColor),
      dark: ThemeBuilder.buildDarkTheme(seedColor),
    );
  }
}

final themeProvider = NotifierProvider<ThemeNotifier, ThemeState>(
  ThemeNotifier.new,
);
