import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_nga/providers/settings/theme_provider.dart';
import 'package:flutter_nga/ui/widget/simple_scroll_behavior.dart';
import 'package:flutter_nga/utils/theme_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:go_router/go_router.dart';
import 'package:route_observer_mixin/route_observer_mixin.dart';

import 'data/data.dart';
import 'utils/route.dart';

class MyApp extends StatefulWidget {
  final AdaptiveThemeMode? savedThemeMode;

  const MyApp({super.key, this.savedThemeMode});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  late final GoRouter _router;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    debugPrint('current state : $state');
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _router = GoRouter(
      routes: buildRoutes(),
      observers: [RouteObserverProvider.of(context)],
    );
    Routes.configureRoutes(_router);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    Data().close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final themeState = ref.watch(themeProvider);
        final seedColor = themeState.seedColor;
        final secondary = ThemeBuilder.getSecondaryForSeed(seedColor);
        final lightScheme = ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.light,
        );
        final darkScheme = ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.dark,
        );

        return AdaptiveTheme(
          light: ThemeBuilder.buildTheme(lightScheme, secondary),
          dark: ThemeBuilder.buildTheme(darkScheme, secondary),
          initial: widget.savedThemeMode ?? AdaptiveThemeMode.light,
          builder: (theme, darkTheme) {
            return MaterialApp.router(
              routerConfig: _router,
              builder: (context, c) {
                final colorScheme = Theme.of(context).colorScheme;
                EasyRefresh.defaultHeaderBuilder = () => MaterialHeader(
                      triggerOffset: 50,
                      color: colorScheme.primary,
                      backgroundColor: colorScheme.surfaceContainerHighest,
                    );
                EasyRefresh.defaultFooterBuilder = () => const ClassicFooter();
                return ScrollConfiguration(
                  behavior: SimpleScrollBehavior(),
                  child: c!,
                );
              },
              theme: theme,
              darkTheme: darkTheme,
              localizationsDelegates: [
                GlobalWidgetsLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: [
                const Locale('en'),
                const Locale('zh', 'CN'),
              ],
              localeResolutionCallback: (locale, supportedLocales) => locale,
            );
          },
        );
      },
    );
  }
}
