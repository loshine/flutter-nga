import 'package:flutter/material.dart';
import 'package:flutter_nga/ui/home.dart';
import 'package:flutter_nga/utils/palette.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Palette.colorPrimary,
        dividerColor: Colors.grey,
      ),
      home: HomePage(title: 'NGA'),
    );
  }
}
