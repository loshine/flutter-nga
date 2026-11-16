import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_nga/data/core/nga_dio_configurator.dart';
import 'package:flutter_nga/data/core/nga_domains.dart';
import 'package:flutter_nga/data/entity/user.dart';

class _RecordingAdapter implements HttpClientAdapter {
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return ResponseBody.fromString('{"data":{}}', 200);
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
}
