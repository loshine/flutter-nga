import 'package:dio/dio.dart';
import 'package:fast_gbk/fast_gbk.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import 'package:flutter_nga/data/core/nga_dio_configurator.dart';
import 'package:flutter_nga/data/core/nga_domains.dart';
import 'package:flutter_nga/data/entity/user.dart';

class _RecordingAdapter implements HttpClientAdapter {
  _RecordingAdapter([this.responder]);

  final List<RequestOptions> requests = [];
  final ResponseBody Function(RequestOptions options)? responder;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return responder?.call(options) ??
        ResponseBody.fromString('{"data":{}}', 200);
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  group('isNgaHost', () {
    test('matches NGA domains and their subdomains', () {
      for (final host in [
        'nga.178.com',
        'img.nga.178.com',
        'img4.nga.178.com',
        'bbs.nga.cn',
        'img8.nga.cn',
        'ngabbs.com',
        'bbs.ngabbs.com',
        'ngabbs.cn',
        'img.ngacn.cc',
        'bbs.ngacn.cc',
        'IMG.NGA.178.COM',
      ]) {
        expect(isNgaHost(host), isTrue, reason: host);
      }
    });

    test('rejects other hosts, including look-alikes', () {
      for (final host in [
        '',
        'example.com',
        'i.imgur.com',
        '178.com',
        'evilnga.cn',
        'nga.cn.evil.com',
        'fakengabbs.com',
        'img.nga.178.com.example.org',
      ]) {
        expect(isNgaHost(host), isFalse, reason: host);
      }
    });
  });

  group('shouldAttachLoginCookie', () {
    RequestOptions options(String path, {String baseUrl = ''}) =>
        RequestOptions(path: path, baseUrl: baseUrl);

    test('allows relative API paths resolved against the NGA baseUrl', () {
      expect(
        NgaDioConfigurator.shouldAttachLoginCookie(
          options('nuke.php?__output=8', baseUrl: 'https://bbs.nga.cn/'),
        ),
        isTrue,
      );
    });

    test('allows a user-defined custom baseUrl host', () {
      expect(
        NgaDioConfigurator.shouldAttachLoginCookie(
          options('thread.php', baseUrl: 'https://mirror.example.org/'),
        ),
        isTrue,
      );
    });

    test('allows absolute NGA urls and rejects third-party urls', () {
      expect(
        NgaDioConfigurator.shouldAttachLoginCookie(
          options(
            'https://img8.nga.cn/attach.php',
            baseUrl: 'https://bbs.nga.cn/',
          ),
        ),
        isTrue,
      );
      expect(
        NgaDioConfigurator.shouldAttachLoginCookie(
          options('https://i.imgur.com/x.png', baseUrl: 'https://bbs.nga.cn/'),
        ),
        isFalse,
      );
    });
  });

  test('interceptor injects cookie only for NGA requests', () async {
    final dio = Dio();
    final adapter = _RecordingAdapter();
    dio.httpClientAdapter = adapter;
    NgaDioConfigurator(() async => CacheUser('42', 'cid', 'nick', true))
        .configure(dio);
    dio.options.baseUrl = 'https://bbs.nga.cn/';

    await dio.get('nuke.php?__output=8');
    await dio.get('https://i.example.com/a.json');

    expect(adapter.requests[0].headers['Cookie'], contains('42'));
    expect(adapter.requests[1].headers.containsKey('Cookie'), isFalse);
  });

  group('PrettyDioLogger', () {
    bool hasLogger(Dio dio) =>
        dio.interceptors.any((interceptor) => interceptor is PrettyDioLogger);

    test('is not added when logging is disabled (release builds)', () {
      final dio = Dio();
      NgaDioConfigurator(() async => null, enableLogging: false).configure(dio);
      expect(hasLogger(dio), isFalse);
    });

    test('is added when logging is enabled', () {
      final dio = Dio();
      NgaDioConfigurator(() async => null, enableLogging: true).configure(dio);
      expect(hasLogger(dio), isTrue);
    });

    test('defaults to kDebugMode', () {
      final dio = Dio();
      NgaDioConfigurator(() async => null).configure(dio);
      expect(hasLogger(dio), kDebugMode);
    });
  });

  group('malformed / truncated JSON handling', () {
    test('rejects truncated JSON for guest with login hint instead of leaking String', () async {
      final dio = Dio();
      dio.httpClientAdapter = _RecordingAdapter(
        (_) => ResponseBody.fromString(
          '{"data":{"__R":{"0":{"lou":0,"postdate":"2026',
          200,
        ),
      );
      NgaDioConfigurator(() async => null, enableLogging: false).configure(dio);
      dio.options.baseUrl = 'https://bbs.nga.cn/';

      await expectLater(
        () => dio.get<Map<String, dynamic>>(
          'read.php?__output=8&tid=8494523&page=1',
        ),
        throwsA(
          isA<DioException>().having(
            (e) => e.error,
            'error',
            contains('请登录后重试'),
          ),
        ),
      );
    });

    test(
      'rejects malformed JSON for logged-in user with parse error',
      () async {
        final dio = Dio();
        dio.httpClientAdapter = _RecordingAdapter(
          (_) => ResponseBody.fromString('{"data":{"broken', 200),
        );
        NgaDioConfigurator(
          () async => CacheUser('42', 'cid', 'nick', true),
          enableLogging: false,
        ).configure(dio);
        dio.options.baseUrl = 'https://bbs.nga.cn/';

        await expectLater(
          () =>
              dio.get<Map<String, dynamic>>('read.php?__output=8&tid=1&page=1'),
          throwsA(
            isA<DioException>().having(
              (e) => e.error,
              'error',
              contains('解析失败'),
            ),
          ),
        );
      },
    );

    test(
      'keeps HTML string response for non-JSON endpoints like post.php',
      () async {
        final dio = Dio();
        dio.httpClientAdapter = _RecordingAdapter(
          (_) => ResponseBody.fromBytes(
            gbk.encode('<html><body>发帖成功</body></html>'),
            200,
          ),
        );
        NgaDioConfigurator(
          () async => null,
          enableLogging: false,
        ).configure(dio);
        dio.options.baseUrl = 'https://bbs.nga.cn/';

        final response = await dio.post<String>('post.php');
        expect(response.data, contains('发帖成功'));
      },
    );
  });
}
