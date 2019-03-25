import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class ResourceRepository {
  Dio _dio;

  static final ResourceRepository _singleton = ResourceRepository._internal();

  factory ResourceRepository() {
    return _singleton;
  }

  ResourceRepository._internal() {
    _dio = Dio();
    _dio.options.responseType = ResponseType.bytes;
  }

  Future<File> downloadImage(String url) async {
    Response<List<int>> bytesResponse = await _dio.get(url);
    Directory dir = await getExternalStorageDirectory();
    String path = [dir.path, 'NationalGayAlliance', 'Image'].join('/');
    // Save the thumbnail as a PNG.
    return File('$path/${DateTime.now().toUtc().toIso8601String()}.png')
      ..create(recursive: true)
      ..writeAsBytes(bytesResponse.data);
  }
}
