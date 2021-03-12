import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_nga/utils/palette.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'data/data.dart';
import 'store/forum/favourite_forum_list_store.dart';
import 'utils/route.dart';

class MyApp extends StatefulWidget {
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
      child: MaterialApp(
//        showPerformanceOverlay: true,
        theme: ThemeData(
          primarySwatch: Palette.colorPrimary,
          scaffoldBackgroundColor: Palette.colorBackground,
          backgroundColor: Palette.colorBackground,
          dividerColor: Palette.colorDivider,
          splashColor: Palette.colorSplash,
          highlightColor: Palette.colorHighlight,
        ),
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
  }
}
