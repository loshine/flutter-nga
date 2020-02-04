import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_nga/utils/palette.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'store/favourite_forum_list_store.dart';
import 'utils/route.dart';

void main() {
  // 打开 debug 布局边界
//  debugPaintSizeEnabled = true;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final Router _router = Router();

  MyApp() {
    Routes.configureRoutes(_router);
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<Router>(create: (_) => _router),
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
