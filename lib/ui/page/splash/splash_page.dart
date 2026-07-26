import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/utils/custom_time_messages.dart';
import 'package:flutter_nga/utils/route.dart';
import 'package:timeago/timeago.dart' as time_ago;

class SplashPage extends StatefulWidget {
  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<SplashPage> {
  static const _splashBackground = Color(0xFFFFF9E3);

  @override
  void initState() {
    time_ago.setLocaleMessages('en', CustomTimeMessages());
    Data().init().then((_) {
      if (!mounted) return;
      FlutterNativeSplash.remove();
      Routes.navigateTo(context, Routes.HOME, replace: true);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _splashBackground,
      body: Center(
        child: Image.asset(
          'images/launcher/splash_icon_1024.png',
          width: 200,
          height: 200,
        ),
      ),
    );
  }
}
