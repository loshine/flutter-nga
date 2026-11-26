import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:toastification/toastification.dart';

import 'package:flutter_nga/data/core/app_preferences.dart';
import 'package:flutter_nga/providers/settings/design_style_provider.dart';
import 'package:flutter_nga/providers/settings/theme_provider.dart';
import 'package:flutter_nga/utils/native_theme_service.dart';

import 'my_app.dart';

void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  // 必须在读取任何设置（含 adaptive_theme 的亮/暗模式）之前完成旧数据迁移。
  await AppPreferences.ensureMigrated();
  // AdaptiveTheme 只在首次构建时读取 light/dark，必须在 runApp 前读出已保存的
  // 主题色与界面风格并注入 Provider，否则冷启动会先闪烁默认样式。
  final (savedTheme, savedDesignStyle) = await (
    ThemeNotifier.loadSaved(),
    DesignStyleNotifier.loadSaved(),
  ).wait;
  unawaited(NativeThemeService.setNightMode(savedTheme.mode));

  runApp(
    ToastificationWrapper(
      child: ProviderScope(
        overrides: [
          themeProvider.overrideWith(() => ThemeNotifier(savedTheme)),
          designStyleProvider.overrideWith(
            () => DesignStyleNotifier(savedDesignStyle),
          ),
        ],
        child: MyApp(savedThemeMode: savedTheme.mode),
      ),
    ),
  );
}
