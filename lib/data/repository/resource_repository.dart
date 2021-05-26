import 'dart:async';

import 'package:dio/dio.dart';
import 'package:gallery_saver/gallery_saver.dart';

/// 资源资源库
abstract class ResourceRepository {
  Future<bool?> downloadImage(String url);
}

class ResourceDataRepository implements ResourceRepository {
  late Dio _dio;

  ResourceDataRepository() {
    _dio = Dio();
    _dio.options.responseType = ResponseType.bytes;
  }

  @override
  Future<bool?> downloadImage(String url) async {
    return GallerySaver.saveImage(url, albumName: "NationalGayAlliance");
  }
}
