import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_nga/data/data.dart';
import 'package:path_provider/path_provider.dart';

class ResourceRepository {
  static final ResourceRepository _singleton = ResourceRepository._internal();

  factory ResourceRepository() {
    return _singleton;
  }

  ResourceRepository._internal();

  Future<File> downloadImage(String url) async {
    final options = Options();
    options.responseType = ResponseType.bytes;
    Response<List<int>> bytesResponse =
        await Data().dio.get(url, options: options);
    Directory dir = await getExternalStorageDirectory();
    String path = [dir.path, 'NationalGayAlliance', 'Image'].join('/');
    // Save the thumbnail as a PNG.
    return File('$path/${DateTime.now().toUtc().toIso8601String()}.png')
      ..create(recursive: true)
      ..writeAsBytes(bytesResponse.data);
  }
}
