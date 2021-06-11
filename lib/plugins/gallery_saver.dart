import 'dart:io';

import 'package:flutter/services.dart';

class GallerySaver {
  static Future<bool> save(String url) async {
    if (Platform.isAndroid) {
      return _AndroidGallerySaver.save(url);
    }
    throw Exception("Not implemented!!!");
  }
}

class _AndroidGallerySaver {
  static const _channel =
      const MethodChannel('io.github.loshine.flutternga.gallery_saver/plugin');

  static Future<bool> save(String url) async {
    return await _channel.invokeMethod('save', {"url": url});
  }
}
