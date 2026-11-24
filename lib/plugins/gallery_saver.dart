import 'dart:io';

import 'package:flutter/services.dart';

class GallerySaver {
  static Future<bool> save(String url) async {
    if (Platform.operatingSystem == 'ohos') {
      return _OhosGallerySaver.save(url);
    }
    throw UnsupportedError("当前平台不支持原生相册保存插件");
  }
}

class _OhosGallerySaver {
  static const _channel = MethodChannel(
    'io.github.loshine.flutternga.gallery_saver/plugin',
  );

  static Future<bool> save(String url) async {
    return await _channel.invokeMethod<bool>('save', {"url": url}) ?? false;
  }
}
