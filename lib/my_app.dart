import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:route_observer_mixin/route_observer_mixin.dart';

import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/providers/forum/favourite_forum_list_provider.dart';
import 'package:flutter_nga/providers/settings/theme_provider.dart';
import 'package:flutter_nga/ui/widget/simple_scroll_behavior.dart';
import 'package:flutter_nga/utils/route.dart';
import 'package:flutter_nga/utils/theme_builder.dart';

class MyApp extends ConsumerStatefulWidget {
  final AdaptiveThemeMode? savedThemeMode;

  const MyApp({super.key, this.savedThemeMode});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> with WidgetsBindingObserver {
  late final GoRouter _router;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    debugPrint('current state : $state');
    if (state == AppLifecycleState.resumed) {
      ref.read(favouriteForumListProvider.notifier).retryOnAppResume();
    }
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
    final seedColor = ref.watch(themeProvider).seedColor;
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
          builder: (context, child) {
            final colorScheme = Theme.of(context).colorScheme;
            EasyRefresh.defaultHeaderBuilder = () => MaterialHeader(
                  triggerOffset: 50,
                  color: colorScheme.primary,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                );
            EasyRefresh.defaultFooterBuilder = () => const ClassicFooter();
            return ScrollConfiguration(
              behavior: SimpleScrollBehavior(),
              child: child!,
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
  }
}
