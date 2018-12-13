import 'package:flutter/material.dart';
import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/ui/home.dart';
import 'package:flutter_nga/utils/palette.dart';

void main() async {
  // 初始化数据库
  await Data().init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Palette.colorPrimary,
        scaffoldBackgroundColor: Palette.colorBackground,
        dividerColor: Palette.colorDivider,
        splashColor: Palette.colorSplash,
        highlightColor: Palette.colorHighlight,
      ),
      home: HomePage(title: 'NGA'),
    );
  }
}
