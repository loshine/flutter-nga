import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gal/gal.dart';
import 'package:gal/gal_platform_interface.dart';

import 'package:flutter_nga/data/core/nga_dio_configurator.dart';
import 'package:flutter_nga/data/entity/user.dart';
import 'package:flutter_nga/data/repository/resource_repository.dart';
import 'package:flutter_nga/data/repository/user_repository.dart'
    show TAG_CID, TAG_UID;

const _url = 'https://img.nga.178.com/attachments/mon_202105/23/abc-def.gif';

// GIF 文件头 + 若干字节；也包含非法 GBK/UTF-8 序列，用来确认拦截器未改动内容。
final _gifBytes = Uint8List.fromList([
  0x47,
  0x49,
  0x46,
  0x38,
  0x39,
  0x61,
  0x01,
  0x00,
  0xFF,
  0xFE,
  0x81,
  0x00,
]);

final class _FakeGalPlatform extends GalPlatform {
  bool hasPermissionResult = true;
  bool requestPermissionResult = true;
  int requestPermissionCalls = 0;
  GalException? putError;
  final List<({Uint8List bytes, String name, String? album})> saved = [];

  @override
  Future<bool> hasPermission({bool toAlbum = false}) async =>
      hasPermissionResult;

  @override
  Future<bool> requestPermission({bool toAlbum = false}) async {
    requestPermissionCalls++;
    return requestPermissionResult;
  }

  @override
  Future<void> putImageBytes(
    Uint8List bytes, {
    String? album,
    required String name,
  }) async {
    final error = putError;
    if (error != null) throw error;
    saved.add((bytes: bytes, name: name, album: album));
  }
}

class _BytesAdapter implements HttpClientAdapter {
  _BytesAdapter(this.bytes);

  final Uint8List bytes;
  RequestOptions? lastRequest;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastRequest = options;
    return ResponseBody.fromBytes(
      bytes,
      200,
      headers: {
        Headers.contentTypeHeader: ['image/gif'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

GalException _galException(GalExceptionType type) => GalException(
  type: type,
  platformException: PlatformException(code: type.code),
  stackTrace: StackTrace.empty,
);

void main() {
  late _FakeGalPlatform gal;

  setUp(() {
    gal = _FakeGalPlatform();
    GalPlatform.instance = gal;
  });

  group('imageNameFromUrl', () {
    test('uses the last path segment without extension', () {
      expect(imageNameFromUrl(_url), 'abc-def');
      expect(
        imageNameFromUrl(
          'https://img.nga.178.com/attachments/mon_202105/23/dbQ2o-obK18T1kSh2-eb.jpg',
        ),
        'dbQ2o-obK18T1kSh2-eb',
      );
    });

    test('drops every suffix after the first dot and ignores query', () {
      expect(
        imageNameFromUrl('https://a.com/x/photo.jpg.medium.jpg?v=1#top'),
        'photo',
      );
    });

    test('replaces unsafe characters', () {
      expect(imageNameFromUrl('https://a.com/%E5%9B%BE%20a.png'), '__a');
    });

    test('falls back when no usable name exists', () {
      expect(imageNameFromUrl('https://a.com/'), 'nga_image');
      expect(imageNameFromUrl('https://a.com/.png'), 'nga_image');
    });

    test('truncates very long names', () {
      final name = imageNameFromUrl('https://a.com/${'a' * 100}.jpg');
      expect(name.length, 64);
    });
  });

  test('galErrorMessage maps every type to readable text', () {
    for (final type in GalExceptionType.values) {
      expect(galErrorMessage(type), isNotEmpty);
    }
    expect(galErrorMessage(GalExceptionType.permissionDenied), contains('权限'));
    expect(galErrorMessage(GalExceptionType.notEnoughSpace), contains('空间'));
  });

  group('ResourceDataRepository.saveImageToGallery', () {
    test('saves cached bytes without downloading', () async {
      var downloads = 0;
      final repository = ResourceDataRepository(
        Dio(),
        loadCachedBytes: (url) async => url == _url ? _gifBytes : null,
        downloadBytes: (_) async {
          downloads++;
          return Uint8List(0);
        },
      );

      await repository.saveImageToGallery(_url);

      expect(downloads, 0);
      expect(gal.saved.single.bytes, same(_gifBytes));
      expect(gal.saved.single.name, 'abc-def');
      expect(gal.saved.single.album, isNull);
    });

    test('downloads when the cache misses or is empty', () async {
      for (final cached in <Uint8List?>[null, Uint8List(0)]) {
        gal.saved.clear();
        final requested = <String>[];
        final repository = ResourceDataRepository(
          Dio(),
          loadCachedBytes: (_) async => cached,
          downloadBytes: (url) async {
            requested.add(url);
            return _gifBytes;
          },
        );

        await repository.saveImageToGallery(_url);

        expect(requested, [_url]);
        expect(gal.saved.single.bytes, _gifBytes);
      }
    });

    test('downloads raw bytes through the NGA dio with cookie', () async {
      final dio = Dio();
      final adapter = _BytesAdapter(_gifBytes);
      dio.httpClientAdapter = adapter;
      NgaDioConfigurator(() async => CacheUser('42', 'cid', 'nick', true))
          .configure(dio);
      final repository = ResourceDataRepository(
        dio,
        loadCachedBytes: (_) async => null,
      );

      await repository.saveImageToGallery(_url);

      expect(gal.saved.single.bytes, _gifBytes);
      expect(
        adapter.lastRequest!.headers['Cookie'],
        '$TAG_UID=42;$TAG_CID=cid',
      );
    });

    test('does not send the NGA cookie to third-party image hosts', () async {
      final dio = Dio();
      final adapter = _BytesAdapter(_gifBytes);
      dio.httpClientAdapter = adapter;
      NgaDioConfigurator(() async => CacheUser('42', 'cid', 'nick', true))
          .configure(dio);
      dio.options.baseUrl = 'https://bbs.nga.cn/';
      final repository = ResourceDataRepository(
        dio,
        loadCachedBytes: (_) async => null,
      );

      await repository.saveImageToGallery('https://i.example.com/a/pic.gif');

      expect(gal.saved.single.bytes, _gifBytes);
      expect(adapter.lastRequest!.uri.host, 'i.example.com');
      expect(adapter.lastRequest!.headers.containsKey('Cookie'), isFalse);
    });

    test('requests permission when missing', () async {
      gal.hasPermissionResult = false;
      final repository = ResourceDataRepository(
        Dio(),
        loadCachedBytes: (_) async => _gifBytes,
      );

      await repository.saveImageToGallery(_url);

      expect(gal.requestPermissionCalls, 1);
      expect(gal.saved, hasLength(1));
    });

    test('throws readable error when permission is denied', () async {
      gal
        ..hasPermissionResult = false
        ..requestPermissionResult = false;
      var loads = 0;
      final repository = ResourceDataRepository(
        Dio(),
        loadCachedBytes: (_) async {
          loads++;
          return _gifBytes;
        },
      );

      await expectLater(
        repository.saveImageToGallery(_url),
        throwsA(
          isA<SaveImageException>().having(
            (e) => e.message,
            'message',
            galErrorMessage(GalExceptionType.permissionDenied),
          ),
        ),
      );
      expect(loads, 0);
      expect(gal.saved, isEmpty);
    });

    test('maps GalException to readable error', () async {
      gal.putError = _galException(GalExceptionType.notSupportedFormat);
      final repository = ResourceDataRepository(
        Dio(),
        loadCachedBytes: (_) async => _gifBytes,
      );

      await expectLater(
        repository.saveImageToGallery(_url),
        throwsA(
          isA<SaveImageException>().having(
            (e) => e.toString(),
            'toString',
            galErrorMessage(GalExceptionType.notSupportedFormat),
          ),
        ),
      );
    });

    test('maps download failures to readable error', () async {
      Future<void> expectMessage(Object error, String message) async {
        final repository = ResourceDataRepository(
          Dio(),
          loadCachedBytes: (_) async => null,
          downloadBytes: (url) async => throw error,
        );
        await expectLater(
          repository.saveImageToGallery(_url),
          throwsA(
            isA<SaveImageException>().having(
              (e) => e.message,
              'message',
              message,
            ),
          ),
        );
      }

      final options = RequestOptions(path: _url);
      await expectMessage(
        DioException(requestOptions: options, error: '网络错误，请稍候重试。'),
        '网络错误，请稍候重试。',
      );
      await expectMessage(
        DioException.badResponse(
          statusCode: 404,
          requestOptions: options,
          response: Response(requestOptions: options, statusCode: 404),
        ),
        '图片下载失败',
      );
      await expectMessage(StateError('boom'), '保存到相册失败');
      expect(gal.saved, isEmpty);
    });

    test('treats an empty download as failure', () async {
      final repository = ResourceDataRepository(
        Dio(),
        loadCachedBytes: (_) async => null,
        downloadBytes: (_) async => Uint8List(0),
      );

      await expectLater(
        repository.saveImageToGallery(_url),
        throwsA(
          isA<SaveImageException>().having(
            (e) => e.message,
            'message',
            '图片下载失败',
          ),
        ),
      );
    });
  });
}
