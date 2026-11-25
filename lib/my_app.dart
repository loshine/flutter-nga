import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:cupertino_ui/cupertino_ui.dart'
    show CupertinoTheme, GlobalCupertinoLocalizations;
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart'
    show GlobalWidgetsLocalizations;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/providers/forum/favourite_forum_list_provider.dart';
import 'package:flutter_nga/providers/settings/design_style_provider.dart';
import 'package:flutter_nga/providers/settings/theme_provider.dart';
import 'package:flutter_nga/ui/widget/app_adaptive_theme.dart';
import 'package:flutter_nga/ui/widget/legacy_theme_bridge.dart';
import 'package:flutter_nga/ui/widget/simple_scroll_behavior.dart';
import 'package:flutter_nga/utils/route.dart';
import 'package:flutter_nga/utils/route_observer.dart';
import 'package:flutter_nga/utils/theme_builder.dart';

class MyApp extends ConsumerStatefulWidget {
  final AdaptiveThemeMode? savedThemeMode;

  const MyApp({super.key, this.savedThemeMode});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> with WidgetsBindingObserver {
  late final GoRouter _router;
  (int, int, bool)? _lastRefreshConfig;

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
    _router = GoRouter(routes: buildRoutes(), observers: [appRouteObserver]);
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
    final seedColor = ref.watch(
      themeProvider.select((s) => s.effectiveSeedColor),
    );
    final isDynamic = ref.watch(
      themeProvider.select((s) => s.isDynamicColorActive),
    );
    final designState = ref.watch(designStyleProvider);
    final effectiveStyle = designState.effectiveStyle;
    final isAppleStyle = effectiveStyle == AppDesignStyle.apple;

    return AppDesignStyleScope(
      style: effectiveStyle,
      nativeLiquidGlassSupported: designState.nativeLiquidGlassSupported,
      macTitlebarInset: designState.macTitlebarInset,
      child: AppAdaptiveTheme(
        initialMode: widget.savedThemeMode,
        builder: (theme, darkTheme) {
          final styledLight = ThemeBuilder.applyDesignStyle(
            theme,
            isAppleStyle: isAppleStyle,
          );
          final styledDark = ThemeBuilder.applyDesignStyle(
            darkTheme,
            isAppleStyle: isAppleStyle,
          );
          final highContrastLight = ThemeBuilder.applyDesignStyle(
            ThemeBuilder.buildHighContrastLightTheme(
              seedColor,
              isDynamic: isDynamic,
            ),
            isAppleStyle: isAppleStyle,
          );
          final highContrastDark = ThemeBuilder.applyDesignStyle(
            ThemeBuilder.buildHighContrastDarkTheme(
              seedColor,
              isDynamic: isDynamic,
            ),
            isAppleStyle: isAppleStyle,
          );

          return MaterialApp.router(
            routerConfig: _router,
            builder: (context, child) {
              final appTheme = Theme.of(context);
              final colorScheme = appTheme.colorScheme;
              final isDark = appTheme.brightness == Brightness.dark;
              final overlayStyle =
                  (isDark
                          ? SystemUiOverlayStyle.light
                          : SystemUiOverlayStyle.dark)
                      .copyWith(
                        statusBarColor: Colors.transparent,
                        systemNavigationBarColor: Colors.transparent,
                        systemNavigationBarContrastEnforced: false,
                      );
              final refreshConfig = (
                colorScheme.primary.toARGB32(),
                colorScheme.surfaceContainerHighest.toARGB32(),
                isAppleStyle,
              );
              if (_lastRefreshConfig != refreshConfig) {
                _lastRefreshConfig = refreshConfig;
                EasyRefresh.defaultHeaderBuilder = isAppleStyle
                    ? () => const CupertinoHeader()
                    : () => MaterialHeader(
                        triggerOffset: 50,
                        color: colorScheme.primary,
                        backgroundColor: colorScheme.surfaceContainerHighest,
                      );
                EasyRefresh.defaultFooterBuilder = isAppleStyle
                    ? () => const CupertinoFooter()
                    : () => const ClassicFooter();
              }
              return AnnotatedRegion<SystemUiOverlayStyle>(
                value: overlayStyle,
                child: CupertinoTheme(
                  data: ThemeBuilder.buildCupertinoTheme(colorScheme),
                  child: LegacyThemeBridge(
                    child: ScrollConfiguration(
                      behavior: SimpleScrollBehavior(
                        isAppleStyle: isAppleStyle,
                      ),
                      child: child!,
                    ),
                  ),
                ),
              );
            },
            theme: styledLight,
            darkTheme: styledDark,
            highContrastTheme: highContrastLight,
            highContrastDarkTheme: highContrastDark,
            localizationsDelegates: [
              GlobalWidgetsLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: [const Locale('en'), const Locale('zh', 'CN')],
            localeResolutionCallback: (locale, supportedLocales) => locale,
          );
        },
      ),
    );
  }
}
