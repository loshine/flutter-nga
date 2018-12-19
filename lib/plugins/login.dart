import 'dart:async';

import 'package:flutter/services.dart';

class AndroidLogin {
  static const _loginChannel =
      const MethodChannel('xyz.loshine.flutternga.login/plugin');
  static const _cookieChannel =
      const EventChannel('xyz.loshine.flutternga.cookies/plugin');

  static Stream<dynamic> get cookieStream =>
      _cookieChannel.receiveBroadcastStream();

  static Future<String> startLogin() async {
    return await _loginChannel.invokeMethod('start_login');
  }

  static void dispose() {
    _loginChannel.setMethodCallHandler(null);
  }
}
