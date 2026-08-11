import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sembast/sembast_memory.dart';

import 'package:flutter_nga/data/entity/forum.dart';
import 'package:flutter_nga/data/entity/user.dart';
import 'package:flutter_nga/data/repository/forum_repository.dart';

void main() {
  group('Forum', () {
    test('parses fid and stid identities from string or numeric values', () {
      final forum = Forum.fromJson({'fid': '7', 'name': '议事厅'});
      final special = Forum.fromJson({
        'fid': 7,
        'stid': '8',
        'id': '80',
        'name': '特殊版块',
      });

      expect(forum.identity, const ForumIdentity(7, 0));
      expect(special.identity, const ForumIdentity(8, 1));
      expect(special.iconId, 80);
      expect(special.getIconUrl(), endsWith('/80.png'));
    });

    test('keeps fid and stid with the same value distinct', () {
      expect(const ForumIdentity(7, 0), isNot(const ForumIdentity(7, 1)));
    });
  });

  group('ForumDataRepository favourites', () {
    var databaseIndex = 0;
    late Database database;
    late _FakeFavouriteApi api;
    late CacheUser? currentUser;
    late ForumDataRepository repository;

    setUp(() async {
      database = await databaseFactoryMemory.openDatabase(
        'forum-test-${databaseIndex++}.db',
      );
      api = _FakeFavouriteApi();
      currentUser = null;
      repository = ForumDataRepository(
        database,
        api.dio,
        () async => currentUser,
      );
    });

    tearDown(() async {
      await database.close();
    });

    test('guest favourites stay local and distinguish fid from stid', () async {
      const forum = Forum(7, '普通版块');
      const special = Forum(7, '特殊版块', type: 1);

      await repository.saveFavourite(forum);
      await repository.saveFavourite(special);

      expect(
        (await repository.getFavouriteList()).map((item) => item.identity),
        [forum.identity, special.identity],
      );
      expect(api.requests, isEmpty);

      await repository.deleteFavourite(forum);

      expect(
        (await repository.getFavouriteList()).map((item) => item.identity),
        [special.identity],
      );
      expect(api.requests, isEmpty);
    });

    test('sync sends exact endpoint, auth form, and stable cookie', () async {
      currentUser = _user('1', 'token-1');
      api.remoteFor('1')[const ForumIdentity(7, 0)] =
          const Forum(7, '议事厅', iconId: 70);

      final forums = await repository.syncFavouriteList();

      expect(forums.single.name, '议事厅');
      final request = api.requests.single;
      expect(
        request.path,
        'nuke.php?__lib=forum_favor2&__act=forum_favor&__inchst=UTF8&__output=8',
      );
      expect(request.fields, {
        'action': 'get',
        'access_token': 'token-1',
        'access_uid': '1',
      });
      expect(
        request.cookie,
        'ngaPassportUid=1;ngaPassportCid=token-1',
      );
    });

    test('special forums send their stid value in the fid form field',
        () async {
      currentUser = _user('1', 'token-1');
      api.addAsSpecial = true;
      const special = Forum(88, '特殊版块', type: 1);

      await repository.saveFavourite(special);
      await repository.syncFavouriteList();
      await repository.deleteFavourite(special);

      final addRequest = api.requests.firstWhere(
        (request) => request.fields['action'] == 'add',
      );
      final deleteRequest = api.requests.firstWhere(
        (request) => request.fields['action'] == 'del',
      );
      expect(addRequest.fields['fid'], '88');
      expect(deleteRequest.fields['fid'], '88');
      expect(addRequest.fields['access_uid'], '1');
      expect(addRequest.fields['access_token'], 'token-1');
    });

    test('account caches are isolated by uid', () async {
      currentUser = _user('1', 'token-1');
      api.remoteFor('1')[const ForumIdentity(1, 0)] = const Forum(1, '账号一');
      await repository.syncFavouriteList();

      currentUser = _user('2', 'token-2');
      api.remoteFor('2')[const ForumIdentity(2, 0)] = const Forum(2, '账号二');
      await repository.syncFavouriteList();
      expect((await repository.getFavouriteList()).single.fid, 2);

      currentUser = _user('1', 'token-1');
      expect((await repository.getFavouriteList()).single.fid, 1);
    });

    test('offline add stays local and retries only one coalesced add',
        () async {
      currentUser = _user('1', 'token-1');
      const forum = Forum(42, '本地名称');

      await repository.saveFavourite(forum);
      await repository.saveFavourite(forum);
      api.failGet = true;
      await expectLater(
        repository.syncFavouriteList(),
        throwsA(isA<DioException>()),
      );
      expect((await repository.getFavouriteList()).single.identity,
          forum.identity);

      api.failGet = false;
      await repository.syncFavouriteList();
      await repository.syncFavouriteList();

      expect(api.actionCount('add'), 1);
      expect(api.remoteFor('1').keys, contains(forum.identity));
    });

    test('remote refresh failure preserves the confirmed local cache',
        () async {
      currentUser = _user('1', 'token-1');
      api.remoteFor('1')[const ForumIdentity(1, 0)] = const Forum(1, '旧数据');
      await repository.syncFavouriteList();

      api.remoteFor('1')
        ..clear()
        ..[const ForumIdentity(2, 0)] = const Forum(2, '新数据');
      api.failGet = true;
      await expectLater(
        repository.syncFavouriteList(),
        throwsA(isA<DioException>()),
      );

      final cached = await repository.getFavouriteList();
      expect(cached.single.fid, 1);
    });

    test('malformed remote response preserves the confirmed local cache',
        () async {
      currentUser = _user('1', 'token-1');
      api.remoteFor('1')[const ForumIdentity(1, 0)] = const Forum(1, '旧数据');
      await repository.syncFavouriteList();

      api.invalidGetResponse = true;
      await expectLater(
        repository.syncFavouriteList(),
        throwsA(isA<FormatException>()),
      );

      final cached = await repository.getFavouriteList();
      expect(cached.single.fid, 1);
    });

    test('delete changes local data only after remote success', () async {
      currentUser = _user('1', 'token-1');
      const forum = Forum(7, '议事厅');
      api.remoteFor('1')[forum.identity] = forum;
      await repository.syncFavouriteList();

      api.failDelete = true;
      await expectLater(
        repository.deleteFavourite(forum),
        throwsA(isA<DioException>()),
      );
      expect(await repository.isFavourite(forum), isTrue);

      api.failDelete = false;
      await repository.deleteFavourite(forum);
      expect(await repository.isFavourite(forum), isFalse);
      expect(api.remoteFor('1'), isEmpty);
    });

    test('successful delete also cancels an unsynced pending add', () async {
      currentUser = _user('1', 'token-1');
      const forum = Forum(9, '待同步版块');
      await repository.saveFavourite(forum);

      await repository.deleteFavourite(forum);
      await repository.syncFavouriteList();

      expect(api.actionCount('add'), 0);
      expect(await repository.isFavourite(forum), isFalse);
    });

    test('delete and sync are serialized for the same account', () async {
      currentUser = _user('1', 'token-1');
      const forum = Forum(7, '议事厅');
      api.remoteFor('1')[forum.identity] = forum;
      await repository.syncFavouriteList();

      api.deleteGate = Completer<void>();
      api.deleteStarted = Completer<void>();
      final deleteFuture = repository.deleteFavourite(forum);
      await api.deleteStarted!.future;

      final syncFuture = repository.syncFavouriteList();
      await Future<void>.delayed(Duration.zero);
      expect(api.actionCount('get'), 1);

      api.deleteGate!.complete();
      await deleteFuture;
      await syncFuture;

      expect(
        api.requests.map((request) => request.fields['action']),
        ['get', 'del', 'get'],
      );
      expect(await repository.isFavourite(forum), isFalse);
    });

    test('a newer add intent survives an in-flight successful delete',
        () async {
      currentUser = _user('1', 'token-1');
      const forum = Forum(7, '议事厅');
      api.remoteFor('1')[forum.identity] = forum;
      await repository.syncFavouriteList();

      api.deleteGate = Completer<void>();
      api.deleteStarted = Completer<void>();
      final deleteFuture = repository.deleteFavourite(forum);
      await api.deleteStarted!.future;

      await repository.saveFavourite(forum);
      api.deleteGate!.complete();
      await deleteFuture;

      expect(await repository.isFavourite(forum), isTrue);
      await repository.syncFavouriteList();
      expect(api.actionCount('add'), 1);
      expect(api.remoteFor('1').keys, contains(forum.identity));
    });

    test('legacy guest favourites migrate to the first account only', () async {
      const legacy = Forum(11, '旧本地收藏');
      await repository.saveFavourite(legacy);

      currentUser = _user('1', 'token-1');
      await repository.syncFavouriteList();
      expect(api.remoteFor('1').keys, contains(legacy.identity));

      currentUser = _user('2', 'token-2');
      await repository.syncFavouriteList();
      expect(api.remoteFor('2'), isEmpty);

      currentUser = null;
      expect(
        (await repository.getFavouriteList()).single.identity,
        legacy.identity,
      );
    });
  });
}

CacheUser _user(String uid, String token) {
  return CacheUser(uid, token, 'user-$uid', true);
}

class _CapturedRequest {
  const _CapturedRequest({
    required this.path,
    required this.fields,
    required this.cookie,
  });

  final String path;
  final Map<String, String> fields;
  final String? cookie;
}

class _FakeFavouriteApi {
  _FakeFavouriteApi() {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          try {
            final fields = Map<String, String>.fromEntries(
              (options.data as FormData).fields,
            );
            requests.add(_CapturedRequest(
              path: options.path,
              fields: fields,
              cookie: options.headers['Cookie']?.toString(),
            ));
            if (fields['action'] == 'del') {
              final started = deleteStarted;
              if (started != null && !started.isCompleted) {
                started.complete();
              }
              await deleteGate?.future;
            }
            handler.resolve(Response<dynamic>(
              requestOptions: options,
              data: _handle(fields),
            ));
          } catch (error) {
            handler.reject(DioException(
              requestOptions: options,
              error: error,
            ));
          }
        },
      ),
    );
  }

  final Dio dio = Dio();
  final List<_CapturedRequest> requests = [];
  final Map<String, Map<ForumIdentity, Forum>> _remoteByUid = {};
  bool failGet = false;
  bool failDelete = false;
  bool invalidGetResponse = false;
  bool addAsSpecial = false;
  Completer<void>? deleteGate;
  Completer<void>? deleteStarted;

  Map<ForumIdentity, Forum> remoteFor(String uid) {
    return _remoteByUid.putIfAbsent(uid, () => {});
  }

  int actionCount(String action) {
    return requests
        .where((request) => request.fields['action'] == action)
        .length;
  }

  dynamic _handle(Map<String, String> fields) {
    final action = fields['action'];
    final uid = fields['access_uid']!;
    if (action == 'get') {
      if (failGet) throw StateError('get failed');
      if (invalidGetResponse) return {'unexpected': {}};
      var index = 0;
      return {
        '0': {
          for (final forum in remoteFor(uid).values)
            '${index++}': _forumJson(forum),
        },
      };
    }

    final fid = int.parse(fields['fid']!);
    if (action == 'add') {
      final type = addAsSpecial ? 1 : 0;
      final identity = ForumIdentity(fid, type);
      remoteFor(uid).putIfAbsent(
        identity,
        () => Forum(fid, '远程版块 $fid', type: type),
      );
      return [];
    }
    if (action == 'del') {
      if (failDelete) throw StateError('delete failed');
      remoteFor(uid).removeWhere((identity, _) => identity.id == fid);
      return [];
    }
    throw StateError('Unsupported action: $action');
  }

  Map<String, dynamic> _forumJson(Forum forum) {
    return {
      if (forum.type == 0) 'fid': forum.fid else 'stid': forum.fid,
      'name': forum.name,
      if (forum.iconId != null) 'id': forum.iconId,
    };
  }
}
