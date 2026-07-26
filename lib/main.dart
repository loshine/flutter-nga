import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:route_observer_mixin/route_observer_mixin.dart';
import 'package:toastification/toastification.dart';

import 'my_app.dart';

void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  final savedThemeMode = await AdaptiveTheme.getThemeMode();

  runApp(
    ToastificationWrapper(
      child: ProviderScope(
        child: RouteObserverProvider(
          child: MyApp(savedThemeMode: savedThemeMode),
        ),
      ),
    ),
  );
}
