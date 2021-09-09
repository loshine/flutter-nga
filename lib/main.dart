import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:route_observer_mixin/route_observer_mixin.dart';

import 'my_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final savedThemeMode = await AdaptiveTheme.getThemeMode();
  await FlutterDisplayMode.setHighRefreshRate();
  runApp(RouteObserverProvider(
    child: MyApp(savedThemeMode: savedThemeMode),
  ));
}
