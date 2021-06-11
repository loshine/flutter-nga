import 'dart:io';

import 'package:flutter/services.dart';

class Json {
  static Future<String> fix(String json) async {
    if (Platform.isAndroid) {
      return _AndroidJson.fix(json);
    }
    throw Exception("Not implemented!!!");
  }
}

class _AndroidJson {
  static const _channel =
      const MethodChannel('io.github.loshine.flutternga.json/plugin');

  static Future<String> fix(String json) async {
    return await _channel.invokeMethod('fix', {"json": json});
  }
}
