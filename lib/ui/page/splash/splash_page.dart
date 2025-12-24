import 'package:flutter/material.dart';
import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/utils/custom_time_messages.dart';
import 'package:flutter_nga/utils/route.dart';
import 'package:timeago/timeago.dart' as timeAgo;

class SplashPage extends StatefulWidget {
  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<SplashPage> {
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    timeAgo.setLocaleMessages('en', CustomTimeMessages());
    _initApp();
  }

  Future<void> _initApp() async {
    try {
      await Data().init();
      if (mounted) {
        Routes.navigateTo(context, Routes.HOME, replace: true);
      }
    } catch (e) {
      debugPrint('初始化失败: $e');
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
        });
        // 即使初始化失败，也尝试进入首页
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Routes.navigateTo(context, Routes.HOME, replace: true);
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _errorMessage != null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("欢迎使用"),
                  const SizedBox(height: 16),
                  Text(
                    "初始化异常: $_errorMessage",
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
              )
            : const Text("欢迎使用"),
      ),
    );
  }
}
