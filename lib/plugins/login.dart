import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

class Login {
  static Stream<dynamic> get cookieStream {
    if (Platform.isAndroid) {
      return _AndroidLogin.cookieStream;
    }
    // iOS 不支持原生登录，返回空流
    return const Stream.empty();
  }

  static Future<String> startLogin() async {
    if (Platform.isAndroid) {
      return _AndroidLogin.startLogin();
    }
    // iOS 不支持原生登录，请使用 WebView 登录
    throw UnsupportedError("iOS 不支持原生登录，请使用网页登录");
  }
}

class _AndroidLogin {
  static const loginChannel =
      MethodChannel('io.github.loshine.flutternga.login/plugin');
  static const cookieChannel =
      EventChannel('io.github.loshine.flutternga.cookies/plugin');

  static Stream<dynamic> get cookieStream =>
      cookieChannel.receiveBroadcastStream();

  static Future<String> startLogin() async {
    return await loginChannel.invokeMethod('start_login');
  }
}
