import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';

class DownloadUtils {
  static Future<File> saveImage(String url) async {
    // XXX: 有问题
    final completer = Completer<ImageInfo>();
    CachedNetworkImageProvider(url)
        .resolve(ImageConfiguration())
        .addListener((ImageInfo info, _) => completer.complete(info));
    ImageInfo info = await completer.future;
    Directory dir = await getExternalStorageDirectory();
    String path = [dir.path, 'NationalGayAlliance', 'Image'].join('/');
    // Save the thumbnail as a PNG.
    ByteData data = await info.image.toByteData();
    return File('$path/${DateTime.now().toUtc().toIso8601String()}.png')
      ..create(recursive: true)
      ..writeAsBytes(
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
  }
}
