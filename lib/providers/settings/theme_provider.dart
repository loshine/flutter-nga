import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nga/utils/theme_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _keyUseDynamicColor = 'use_dynamic_color';
const String _keySeedColorValue = 'seed_color_value';

/// 预设主题色列表
class ThemeColors {
  static const List<Color> presets = [
    Colors.brown,   // 默认 - 棕色
    Colors.blue,    // 蓝色
    Colors.teal,    // 青色
    Colors.green,   // 绿色
    Colors.purple,  // 紫色
    Colors.pink,    // 粉色
    Colors.orange,  // 橙色
    Colors.red,     // 红色
    Colors.indigo,  // 靛蓝
    Colors.cyan,    // 青蓝
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
  final bool useDynamicColor;
  final Color seedColor;

  ThemeState({
    this.mode,
    this.useDynamicColor = true,
    Color? seedColor,
  }) : seedColor = seedColor ?? ThemeColors.defaultColor;

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

  ThemeState copyWith({
    AdaptiveThemeMode? mode,
    bool? useDynamicColor,
    Color? seedColor,
  }) {
    return ThemeState(
      mode: mode ?? this.mode,
      useDynamicColor: useDynamicColor ?? this.useDynamicColor,
      seedColor: seedColor ?? this.seedColor,
    );
  }
}

class ThemeNotifier extends Notifier<ThemeState> {
  @override
  ThemeState build() => ThemeState();

  Future<void> refresh() async {
    final mode = await AdaptiveTheme.getThemeMode();
    final prefs = await SharedPreferences.getInstance();
    final useDynamicColor = prefs.getBool(_keyUseDynamicColor) ?? true;
    final seedColorValue = prefs.getInt(_keySeedColorValue);
    final seedColor = seedColorValue != null 
        ? Color(seedColorValue) 
        : ThemeColors.defaultColor;
    state = state.copyWith(
      mode: mode, 
      useDynamicColor: useDynamicColor,
      seedColor: seedColor,
    );
  }

  void update(BuildContext context, AdaptiveThemeMode adaptiveThemeMode) {
    AdaptiveTheme.of(context).setThemeMode(adaptiveThemeMode);
    state = state.copyWith(mode: adaptiveThemeMode);
  }

  Future<void> setUseDynamicColor(BuildContext context, bool value) async {
    // Get AdaptiveTheme reference before async gap
    final adaptiveTheme = AdaptiveTheme.of(context);
    final currentSeedColor = state.seedColor;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyUseDynamicColor, value);
    state = state.copyWith(useDynamicColor: value);
    
    // If turning off dynamic color, apply the current seed color
    if (!value) {
      _applyThemeWithRef(adaptiveTheme, currentSeedColor);
    }
  }

  Future<void> setSeedColor(BuildContext context, Color color) async {
    // Get AdaptiveTheme reference before async gap
    final adaptiveTheme = AdaptiveTheme.of(context);
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keySeedColorValue, color.toARGB32());
    state = state.copyWith(seedColor: color);
    
    // Apply theme using AdaptiveTheme API
    _applyThemeWithRef(adaptiveTheme, color);
  }

  void _applyThemeWithRef(AdaptiveThemeManager adaptiveTheme, Color seedColor) {
    adaptiveTheme.setTheme(
      light: ThemeBuilder.buildLightTheme(seedColor),
      dark: ThemeBuilder.buildDarkTheme(seedColor),
    );
  }
}

final themeProvider = NotifierProvider<ThemeNotifier, ThemeState>(ThemeNotifier.new);
