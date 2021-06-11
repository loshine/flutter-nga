import 'dart:io';

import 'package:flutter/services.dart';

class Login {
  static Stream<dynamic> get cookieStream {
    if (Platform.isAndroid) {
      return _AndroidLogin.cookieStream;
    }
    throw Exception("Not implemented!!!");
  }

  static Future<String> startLogin() async {
    if (Platform.isAndroid) {
      return _AndroidLogin.startLogin();
    }
    throw Exception("Not implemented!!!");
  }

  static void dispose() {
    if (Platform.isAndroid) {
      return _AndroidLogin.dispose();
    }
  }
}

class _AndroidLogin {
  static const loginChannel =
      const MethodChannel('io.github.loshine.flutternga.login/plugin');
  static const cookieChannel =
      const EventChannel('io.github.loshine.flutternga.cookies/plugin');

  static Stream<dynamic> get cookieStream =>
      cookieChannel.receiveBroadcastStream();

  static Future<String> startLogin() async {
    return await loginChannel.invokeMethod('start_login');
  }

  static void dispose() {
    loginChannel.setMethodCallHandler(null);
  }
}
