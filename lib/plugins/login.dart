import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

class Login {
  static Stream<dynamic> get cookieStream {
    if (Platform.operatingSystem == 'ohos') {
      return _OhosLogin.cookieStream;
    }
    return const Stream.empty();
  }

  static Future<String> startLogin() async {
    if (Platform.operatingSystem == 'ohos') {
      return _OhosLogin.startLogin();
    }
    throw UnsupportedError("当前平台不支持原生登录，请使用网页登录");
  }
}

class _OhosLogin {
  static const loginChannel = MethodChannel(
    'io.github.loshine.flutternga.login/plugin',
  );
  static const cookieChannel = EventChannel(
    'io.github.loshine.flutternga.cookies/plugin',
  );

  static Stream<dynamic> get cookieStream =>
      cookieChannel.receiveBroadcastStream();

  static Future<String> startLogin() async {
    return await loginChannel.invokeMethod<String>('start_login') ?? '';
  }
}
