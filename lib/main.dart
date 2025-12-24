import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:route_observer_mixin/route_observer_mixin.dart';

import 'my_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final savedThemeMode = await AdaptiveTheme.getThemeMode();

  // TODO: flutter_displaymode 已移除，鸿蒙系统不支持
  // await FlutterDisplayMode.setHighRefreshRate();

  // TODO: MMKV 已替换为 shared_preferences，无需初始化

  // await setUpHttpClient();
  runApp(RouteObserverProvider(
    child: MyApp(savedThemeMode: savedThemeMode),
  ));
}
