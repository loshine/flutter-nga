import 'package:flutter/services.dart';

class AndroidLogin {
  static const _loginChannel =
      const MethodChannel('io.github.loshine.flutternga.login/plugin');
  static const _cookieChannel =
      const EventChannel('io.github.loshine.flutternga.cookies/plugin');

  static Stream<dynamic> get cookieStream =>
      _cookieChannel.receiveBroadcastStream();

  static Future<String> startLogin() async {
    return await _loginChannel.invokeMethod('start_login');
  }

  static void dispose() {
    _loginChannel.setMethodCallHandler(null);
  }
}
