import 'package:flutter/services.dart';

class AndroidGallerySaver {
  static const _channel =
      const MethodChannel('io.github.loshine.flutternga.gallery_saver/plugin');

  static Future<bool> save(String url) async {
    return await _channel.invokeMethod('save', {"url": url});
  }
}
