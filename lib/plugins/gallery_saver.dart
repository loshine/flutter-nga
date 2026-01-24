import 'dart:io';

import 'package:flutter/services.dart';

class GallerySaver {
  static Future<bool> save(String url) async {
    if (Platform.isAndroid) {
      return _AndroidGallerySaver.save(url);
    } else if (Platform.isIOS) {
      return _IOSGallerySaver.save(url);
    }
    throw UnsupportedError("当前平台不支持保存图片");
  }
}

class _AndroidGallerySaver {
  static const _channel =
      MethodChannel('io.github.loshine.flutternga.gallery_saver/plugin');

  static Future<bool> save(String url) async {
    return await _channel.invokeMethod('save', {"url": url});
  }
}

class _IOSGallerySaver {
  static const _channel =
      MethodChannel('io.github.loshine.flutternga.gallery_saver/plugin');

  static Future<bool> save(String url) async {
    return await _channel.invokeMethod('save', {"url": url});
  }
}
