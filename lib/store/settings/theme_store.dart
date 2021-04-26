import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';

part 'theme_store.g.dart';

class ThemeStore = _ThemeStore with _$ThemeStore;

abstract class _ThemeStore with Store {
  @observable
  AdaptiveThemeMode? mode;

  String get modeName {
    switch (mode) {
      case AdaptiveThemeMode.light:
        return "亮色模式";
      case AdaptiveThemeMode.dark:
        return "暗色模式";
      case AdaptiveThemeMode.system:
        return "跟随系统";
      default:
        return "亮色模式";
    }
  }

  @action
  Future<void> refresh() async {
    mode = await AdaptiveTheme.getThemeMode() ?? mode;
  }

  @action
  void update(BuildContext context, AdaptiveThemeMode adaptiveThemeMode) {
    AdaptiveTheme.of(context).setThemeMode(adaptiveThemeMode);
    mode = adaptiveThemeMode;
  }
}
