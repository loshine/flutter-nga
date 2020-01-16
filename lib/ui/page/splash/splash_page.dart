import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/ui/page/home/home_page.dart';
import 'package:flutter_nga/utils/custom_time_messages.dart';
import 'package:timeago/timeago.dart' as timeAgo;

class SplashPage extends StatefulWidget {
  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<SplashPage> {
  bool _initFinished = false;
  bool _delayFinished = false;

  @override
  void initState() {
    timeAgo.setLocaleMessages('en', CustomTimeMessages());
    Data().init().then((_) {
      _initFinished = true;
      maybeGoHome();
    });
    Future.delayed(const Duration(seconds: 1)).then((_) {
      _delayFinished = true;
      maybeGoHome();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("欢迎使用"),
      ),
    );
  }

  void maybeGoHome() {
    if (!_initFinished || !_delayFinished) return;
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) {
      return HomePage(title: 'NGA');
    }));
  }
}
