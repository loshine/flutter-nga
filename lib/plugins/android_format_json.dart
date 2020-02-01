import 'package:flutter/services.dart';

class AndroidFormatJson {
  static const _jsonChannel =
      const MethodChannel('io.github.loshine.flutternga.json/plugin');

  static Future<String> decode(String json) async {
    return await _jsonChannel.invokeMethod('decode', {"json": json});
  }
}
