import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

/// 资源资源库
abstract class ResourceRepository {
  Future<File> downloadImage(String url);
}

class ResourceDataRepository implements ResourceRepository {
  late Dio _dio;

  ResourceDataRepository() {
    _dio = Dio();
    _dio.options.responseType = ResponseType.bytes;
  }

  @override
  Future<File> downloadImage(String url) async {
    Response<List<int>> bytesResponse = await _dio.get(url);
    Directory dir =
        await (getExternalStorageDirectory() as FutureOr<Directory>);
    String path = [dir.path, 'NationalGayAlliance', 'Image'].join('/');
    // Save the thumbnail as a PNG.
    return File('$path/${DateTime.now().toUtc().toIso8601String()}.png')
      ..create(recursive: true)
      ..writeAsBytes(bytesResponse.data!);
  }
}
