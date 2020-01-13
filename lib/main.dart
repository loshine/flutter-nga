import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/ui/page/home/home_page.dart';
import 'package:flutter_nga/utils/custom_time_messages.dart';
import 'package:flutter_nga/utils/palette.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:timeago/timeago.dart' as timeAgo;

import 'store/favourite_forum_list.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 初始化数据库
  await Data().init();
  timeAgo.setLocaleMessages('en', CustomTimeMessages());
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<FavouriteForumList>(create: (_) => FavouriteForumList())
      ],
      child: MaterialApp(
        showPerformanceOverlay: true,
        theme: ThemeData(
          primarySwatch: Palette.colorPrimary,
          scaffoldBackgroundColor: Palette.colorBackground,
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
        localeResolutionCallback: (locale, supportedLocales) => locale,
        home: HomePage(title: 'NGA'),
      ),
    );
  }
}
