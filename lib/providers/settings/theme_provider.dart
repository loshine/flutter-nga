import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ThemeState {
  final AdaptiveThemeMode? mode;

  ThemeState({this.mode});

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

  ThemeState copyWith({AdaptiveThemeMode? mode}) {
    return ThemeState(mode: mode ?? this.mode);
  }
}

class ThemeNotifier extends Notifier<ThemeState> {
  @override
  ThemeState build() => ThemeState();

  Future<void> refresh() async {
    final mode = await AdaptiveTheme.getThemeMode();
    state = state.copyWith(mode: mode);
  }

  void update(BuildContext context, AdaptiveThemeMode adaptiveThemeMode) {
    AdaptiveTheme.of(context).setThemeMode(adaptiveThemeMode);
    state = state.copyWith(mode: adaptiveThemeMode);
  }
}

final themeProvider = NotifierProvider<ThemeNotifier, ThemeState>(ThemeNotifier.new);
