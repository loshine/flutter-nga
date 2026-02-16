import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_nga/providers/settings/theme_provider.dart';
import 'package:flutter_nga/ui/widget/simple_scroll_behavior.dart';
import 'package:flutter_nga/utils/theme_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
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

        return DynamicColorBuilder(
          builder: (lightDynamic, darkDynamic) {
            // Determine if dynamic color should be used
            final useDynamic = themeState.useDynamicColor && lightDynamic != null;

            // Use user selected seed color or default
            final seedColor = themeState.seedColor;

            // Build color schemes
            final lightScheme = useDynamic
                ? lightDynamic.harmonized()
                : ColorScheme.fromSeed(
                    seedColor: seedColor,
                    brightness: Brightness.light,
                  );

            final darkScheme = useDynamic && darkDynamic != null
                ? darkDynamic.harmonized()
                : ColorScheme.fromSeed(
                    seedColor: seedColor,
                    brightness: Brightness.dark,
                  );

            return AdaptiveTheme(
              light: ThemeBuilder.buildTheme(lightScheme),
              dark: ThemeBuilder.buildTheme(darkScheme),
              initial: widget.savedThemeMode ?? AdaptiveThemeMode.light,
              builder: (theme, darkTheme) {
                return MaterialApp.router(
                  routerConfig: _router,
                  builder: (context, c) {
                    final colorScheme = Theme.of(context).colorScheme;
                    return RefreshConfiguration(
                      headerBuilder: () => MaterialClassicHeader(
                        distance: 50,
                        height: 70,
                        color: colorScheme.primary,
                        backgroundColor: colorScheme.surfaceContainerHighest,
                      ),
                      headerTriggerDistance: 50,
                      child: ScrollConfiguration(
                        behavior: SimpleScrollBehavior(),
                        child: c!,
                      ),
                    );
                  },
                  theme: theme,
                  darkTheme: darkTheme,
                  localizationsDelegates: [
                    RefreshLocalizations.delegate,
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
      },
    );
  }
}
