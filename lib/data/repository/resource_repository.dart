import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:gal/gal.dart';

import 'package:flutter_nga/data/core/nga_dio_configurator.dart';

/// 从图片缓存读取 [url] 对应的原始字节，未命中返回 null。
typedef CachedImageBytesLoader = Future<Uint8List?> Function(String url);

/// 从网络下载 [url] 对应的原始字节。
typedef ImageBytesDownloader = Future<Uint8List> Function(String url);

/// 保存图片失败，[message] 可直接展示给用户。
class SaveImageException implements Exception {
  const SaveImageException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// 资源资源库
abstract class ResourceRepository {
  /// 把 [url] 对应的图片原样保存到系统相册。
  ///
  /// 失败时抛出 [SaveImageException]。
  Future<void> saveImageToGallery(String url);
}

class ResourceDataRepository implements ResourceRepository {
  ResourceDataRepository(
    this._dio, {
    CachedImageBytesLoader? loadCachedBytes,
    ImageBytesDownloader? downloadBytes,
  }) {
    _loadCachedBytes = loadCachedBytes ?? _loadFromImageCache;
    _downloadBytes = downloadBytes ?? _downloadWithDio;
  }

  final Dio _dio;
  late final CachedImageBytesLoader _loadCachedBytes;
  late final ImageBytesDownloader _downloadBytes;

  @override
  Future<void> saveImageToGallery(String url) async {
    try {
      await _ensurePermission();
      final bytes = await _loadBytes(url);
      // 直接保存原始字节，避免 GIF 等格式被重新编码；扩展名由 gal 按字节识别。
      await Gal.putImageBytes(bytes, name: imageNameFromUrl(url));
    } on SaveImageException {
      rethrow;
    } on GalException catch (e) {
      debugPrint(e.toString());
      throw SaveImageException(galErrorMessage(e.type));
    } on DioException catch (e) {
      debugPrint(e.toString());
      final error = e.error;
      throw SaveImageException(
        error is String && error.isNotEmpty ? error : '图片下载失败',
      );
    } catch (e) {
      debugPrint(e.toString());
      throw const SaveImageException('保存到相册失败');
    }
  }

  Future<void> _ensurePermission() async {
    if (await Gal.hasPermission()) return;
    if (await Gal.requestPermission()) return;
    throw SaveImageException(
      galErrorMessage(GalExceptionType.permissionDenied),
    );
  }

  Future<Uint8List> _loadBytes(String url) async {
    final cached = await _loadCachedBytes(url);
    if (cached != null && cached.isNotEmpty) return cached;
    final downloaded = await _downloadBytes(url);
    if (downloaded.isEmpty) throw const SaveImageException('图片下载失败');
    return downloaded;
  }

  /// 读取 [CachedNetworkImageProvider] 使用的缓存（key 即 url）。
  static Future<Uint8List?> _loadFromImageCache(String url) async {
    try {
      final fileInfo = await CachedNetworkImageProvider.defaultCacheManager
          .getFileFromCache(url);
      return await fileInfo?.file.readAsBytes();
    } catch (e) {
      debugPrint('读取图片缓存失败: $e');
      return null;
    }
  }

  /// 使用项目 Dio 下载（自动带上 Cookie 与 UA），并跳过 GBK/JSON 拦截处理。
  Future<Uint8List> _downloadWithDio(String url) async {
    final response = await _dio.get<List<int>>(
      url,
      options: Options(
        responseType: ResponseType.bytes,
        extra: {NgaDioConfigurator.rawResponseKey: true},
      ),
    );
    final data = response.data;
    if (data == null) return Uint8List(0);
    return data is Uint8List ? data : Uint8List.fromList(data);
  }
}

/// 由图片 URL 推断保存到相册时的文件名（不含扩展名）。
///
/// 取路径最后一段第一个 `.` 之前的部分，非 `[A-Za-z0-9_-]` 字符替换为 `_`，
/// 推断不出时回退为 `nga_image`。同名文件由系统/gal 自动追加序号。
@visibleForTesting
String imageNameFromUrl(String url) {
  const fallback = 'nga_image';
  const maxLength = 64;
  final segments = Uri.tryParse(url)?.pathSegments ?? const <String>[];
  final last = segments.lastWhere((s) => s.isNotEmpty, orElse: () => '');
  final dot = last.indexOf('.');
  final base = (dot == -1 ? last : last.substring(0, dot)).replaceAll(
    RegExp(r'[^A-Za-z0-9_-]'),
    '_',
  );
  if (base.isEmpty) return fallback;
  return base.length > maxLength ? base.substring(0, maxLength) : base;
}

/// 把 [GalExceptionType] 转成用户可读的提示。
@visibleForTesting
String galErrorMessage(GalExceptionType type) {
  return switch (type) {
    GalExceptionType.permissionDenied => '没有相册访问权限，请在系统设置中允许后重试',
    GalExceptionType.notEnoughSpace => '存储空间不足，无法保存图片',
    GalExceptionType.notSupportedFormat => '不支持的图片格式',
    GalExceptionType.unexpected => '保存到相册失败',
  };
}
