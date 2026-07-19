import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:route_observer_mixin/route_observer_mixin.dart';
import 'package:toastification/toastification.dart';

import 'my_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
