import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_nga/ui/widget/simple_scroll_behavior.dart';
import 'package:flutter_nga/utils/dimen.dart';
import 'package:flutter_nga/utils/palette.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'data/data.dart';
import 'store/forum/favourite_forum_list_store.dart';
import 'utils/route.dart';

class MyApp extends StatefulWidget {
  final AdaptiveThemeMode? savedThemeMode;

  const MyApp({Key? key, this.savedThemeMode}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final FluroRouter _router = FluroRouter();

  _MyAppState() {
    Routes.configureRoutes(_router);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    debugPrint('current state : $state');
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    Data().close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<FluroRouter>(create: (_) => _router),
        Provider<FavouriteForumListStore>(
            create: (_) => FavouriteForumListStore()),
      ],
      child: AdaptiveTheme(
        light: ThemeData(
          brightness: Brightness.light,
          primarySwatch: Palette.colorPrimary,
          scaffoldBackgroundColor: Palette.colorBackground,
          backgroundColor: Palette.colorBackground,
          dividerColor: Palette.colorDivider,
          splashColor: Palette.colorSplash,
          highlightColor: Palette.colorHighlight,
          iconTheme: IconThemeData(color: Palette.colorIcon),
          textTheme: TextTheme(
            bodyText1: TextStyle(
              color: Palette.colorTextPrimary,
              fontSize: Dimen.body,
            ),
            bodyText2: TextStyle(
              color: Palette.colorTextSecondary,
              fontSize: Dimen.body,
            ),
            caption: TextStyle(
              color: Palette.colorTextSecondary,
              fontSize: Dimen.caption,
            ),
          ),
        ),
        dark: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Palette.colorDarkPrimary,
          toggleableActiveColor: Palette.colorDarkPrimary[700],
          accentColor: Palette.colorDarkPrimary[700],
          textTheme: TextTheme(
            bodyText1: TextStyle(
              color: Colors.white,
              fontSize: Dimen.body,
            ),
            bodyText2: TextStyle(
              color: Colors.white70,
              fontSize: Dimen.body,
            ),
            caption: TextStyle(
              color: Colors.white70,
              fontSize: Dimen.caption,
            ),
          ),
        ),
        initial: AdaptiveThemeMode.light,
        builder: (theme, darkTheme) {
          return RefreshConfiguration(
            headerBuilder: () => MaterialClassicHeader(
              distance: 50,
              height: 70,
            ),
            headerTriggerDistance: 50,
            child: MaterialApp(
              builder: (context, c) => ScrollConfiguration(
                behavior: SimpleScrollBehavior(),
                child: c!,
              ),
              theme: theme,
              darkTheme: darkTheme,
              localizationsDelegates: [
                // 这行是关键
                RefreshLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalMaterialLocalizations.delegate
              ],
              supportedLocales: [
                const Locale('en'),
                const Locale('zh'),
              ],
              onGenerateRoute: _router.generator,
              localeResolutionCallback: (locale, supportedLocales) => locale,
            ),
          );
        },
      ),
    );
  }
}
