import 'package:flutter/services.dart';

class AndroidGbk {
  static const _gbkChannel =
      const MethodChannel('xyz.loshine.flutternga.gbk/plugin');

  static Future<String> decode(List<int> bytes) async {
    return await _gbkChannel.invokeMethod('decode', {"bytes": bytes});
  }

  static Future<String> decodeList(List<int> content) async {
    return await _gbkChannel.invokeMethod('decodeList', {"content": content});
  }

  static Future<String> urlDecode(String content) async {
    return await _gbkChannel.invokeMethod('urlDecode', {"content": content});
  }

  static Future<String> urlEncode(String content) async {
    return await _gbkChannel.invokeMethod("urlEncode", {"content": content});
  }
}
