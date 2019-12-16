import 'package:flutter/services.dart';

class AndroidGbk {
  static const _gbkChannel =
      const MethodChannel('xyz.loshine.flutternga.gbk/plugin');

  static Future<String> urlDecode(String content) async {
    return await _gbkChannel.invokeMethod('urlDecode', {"content": content});
  }

  static Future<String> urlEncode(String content) async {
    return await _gbkChannel.invokeMethod("urlEncode", {"content": content});
  }

  static Future<String> decodeName(String name) async {
    return await urlDecode(await urlDecode(name));
  }
}
