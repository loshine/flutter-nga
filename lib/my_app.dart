import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:cupertino_ui/cupertino_ui.dart'
    show CupertinoTheme, GlobalCupertinoLocalizations;
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart'
    show GlobalWidgetsLocalizations;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/providers/forum/favourite_forum_list_provider.dart';
import 'package:flutter_nga/providers/home/home_provider.dart';
import 'package:flutter_nga/providers/settings/design_style_provider.dart';
import 'package:flutter_nga/providers/settings/theme_provider.dart';
import 'package:flutter_nga/ui/widget/app_adaptive_theme.dart';
import 'package:flutter_nga/ui/widget/legacy_theme_bridge.dart';
import 'package:flutter_nga/ui/widget/simple_scroll_behavior.dart';
import 'package:flutter_nga/utils/apple_native_service.dart';
import 'package:flutter_nga/utils/route.dart';
import 'package:flutter_nga/utils/route_observer.dart';
import 'package:flutter_nga/utils/theme_builder.dart';

const _workspaceMenuPaths = {
  Routes.FAVOURITE_TOPICS,
  Routes.TOPIC_HISTORY,
  Routes.CONVERSATIONS,
  Routes.NOTIFICATIONS,
  Routes.SETTINGS,
};

/// 跟踪当前顶层路由，用于识别是否有模态弹窗 / Sheet 正在展示。
class TopRouteObserver extends NavigatorObserver {
  Route<dynamic>? _topRoute;

  bool get hasPopupOnTop => _topRoute is PopupRoute<dynamic>;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _topRoute = route;
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _topRoute = previousRoute;
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (identical(_topRoute, oldRoute) || _topRoute == null) {
      _topRoute = newRoute;
    }
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (identical(_topRoute, route)) {
      _topRoute = previousRoute;
    }
  }
}

/// 分发 macOS 原生系统菜单（⌘F、⌘,、⌘1~⌘4、关于）触发的导航事件：
/// - 顶层存在模态弹窗/Sheet 或处于启动页/发帖页时忽略；
/// - 基于 `router.state.uri.path`（含 imperative push 栈顶）去重，避免连按快捷键重复压栈；
/// - 三栏工作区活跃时，将工作区内置入口交由工作区切换侧边栏或打开居中设置 Sheet。
@visibleForTesting
void dispatchNativeMenuNavigate({
  required GoRouter router,
  required TopRouteObserver routeObserver,
  required WorkspaceMenuController workspaceMenu,
  required String path,
}) {
  if (routeObserver.hasPopupOnTop) return;

  final config = router.routerDelegate.currentConfiguration;
  final topPath = config.isEmpty ? null : router.state.uri.path;
  if (topPath == Routes.SPLASH || topPath == Routes.TOPIC_PUBLISH) return;
  if (topPath == path) return;

  if (workspaceMenu.hasHandler && _workspaceMenuPaths.contains(path)) {
    while (router.canPop() &&
        !routeObserver.hasPopupOnTop &&
        router.state.uri.path != Routes.HOME) {
      router.pop();
    }
    if (routeObserver.hasPopupOnTop) return;
    if (workspaceMenu.dispatch(path)) {
      return;
    }
  }

  router.push(path);
}

class MyApp extends ConsumerStatefulWidget {
  final AdaptiveThemeMode? savedThemeMode;

  const MyApp({super.key, this.savedThemeMode});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> with WidgetsBindingObserver {
  late final GoRouter _router;
  final TopRouteObserver _topRouteObserver = TopRouteObserver();
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
    _router = GoRouter(
      routes: buildRoutes(),
      observers: [appRouteObserver, _topRouteObserver],
    );
    Routes.configureRoutes(_router);
    if (AppleNativeService.isRealMacOS) {
      AppleNativeService.setMenuNavigateListener(_handleNativeMenuNavigate);
    }
  }

  @override
  void dispose() {
    if (AppleNativeService.isRealMacOS) {
      AppleNativeService.setMenuNavigateListener(null);
    }
    WidgetsBinding.instance.removeObserver(this);
    Data().close();
    super.dispose();
  }

  void _handleNativeMenuNavigate(String path) {
    dispatchNativeMenuNavigate(
      router: _router,
      routeObserver: _topRouteObserver,
      workspaceMenu: ref.read(workspaceMenuControllerProvider),
      path: path,
    );
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
    final isMacDesktop =
        isAppleStyle &&
        (defaultTargetPlatform == TargetPlatform.macOS ||
            defaultTargetPlatform == TargetPlatform.windows ||
            defaultTargetPlatform == TargetPlatform.linux);

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
            isMacDesktop: isMacDesktop,
          );
          final styledDark = ThemeBuilder.applyDesignStyle(
            darkTheme,
            isAppleStyle: isAppleStyle,
            isMacDesktop: isMacDesktop,
          );
          final highContrastLight = ThemeBuilder.applyDesignStyle(
            ThemeBuilder.buildHighContrastLightTheme(
              seedColor,
              isDynamic: isDynamic,
            ),
            isAppleStyle: isAppleStyle,
            isMacDesktop: isMacDesktop,
            isHighContrast: true,
          );
          final highContrastDark = ThemeBuilder.applyDesignStyle(
            ThemeBuilder.buildHighContrastDarkTheme(
              seedColor,
              isDynamic: isDynamic,
            ),
            isAppleStyle: isAppleStyle,
            isMacDesktop: isMacDesktop,
            isHighContrast: true,
          );

          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
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
                  data: ThemeBuilder.buildCupertinoTheme(
                    colorScheme,
                    isMacDesktop: isMacDesktop,
                    isHighContrast: MediaQuery.highContrastOf(context),
                  ),
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
