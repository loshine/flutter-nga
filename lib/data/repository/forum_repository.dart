import 'package:dio/dio.dart';
import 'package:sembast/sembast.dart';

import 'package:flutter_nga/data/entity/forum.dart';
import 'package:flutter_nga/data/entity/user.dart';
import 'package:flutter_nga/data/repository/user_repository.dart';
import 'package:flutter_nga/utils/code_utils.dart' as code_utils;

/// 版块相关数据知识库
abstract class ForumRepository {
  /// 读取本地缓存的版块分类，没有缓存时返回 null
  Future<List<ForumCategory>?> getCachedForumCategories();

  /// 从服务端拉取版块分类，成功后覆盖本地缓存
  Future<List<ForumCategory>> fetchForumCategories();

  Future<bool> isFavourite(Forum forum);

  Future<void> saveFavourite(Forum forum);

  Future<void> deleteFavourite(Forum forum);

  Future<List<Forum>> getFavouriteList();

  Future<List<Forum>> syncFavouriteList();

  Future<List<Forum>> getForumByName(String keyword);

  Future<String?> addChildForumSubscription(int fid, int? parentId);

  Future<String?> deleteChildForumSubscription(int fid, int? parentId);
}

class ForumDataRepository implements ForumRepository {
  ForumDataRepository(this.database, this._dio, this._loadDefaultUser);

  static const _favouriteApiPath =
      'nuke.php?__lib=forum_favor2&__act=forum_favor&__inchst=UTF8&__output=8';
  static const _guestStoreName = 'forums';
  static const _accountStorePrefix = 'forum_favourites_';
  static const _pendingAddStoreName = 'forum_favourite_pending_adds';
  static const _metadataStoreName = 'forum_favourite_metadata';
  static const _legacyMigrationKey = 'legacy_migration';
  static const _forumCategoryApiPath =
      'app_api.php?__lib=home&__act=category&__inchst=UTF8&__output=8';
  static const _forumCategoryStoreName = 'forum_categories';

  final Database database;
  final Dio _dio;
  final Future<CacheUser?> Function() _loadDefaultUser;
  final Map<String, Future<List<Forum>>> _syncFutures = {};
  final Map<String, Future<void>> _accountOperationTails = {};

  StoreRef<int, dynamic> _favouriteStore(String? uid) =>
      intMapStoreFactory.store(
        uid == null ? _guestStoreName : '$_accountStorePrefix$uid',
      );

  StoreRef<String, dynamic> get _pendingAddStore =>
      stringMapStoreFactory.store(_pendingAddStoreName);

  StoreRef<String, dynamic> get _metadataStore =>
      stringMapStoreFactory.store(_metadataStoreName);

  RecordRef<String, dynamic> get _forumCategoryRecord =>
      stringMapStoreFactory.store(_forumCategoryStoreName).record('categories');

  @override
  Future<List<ForumCategory>?> getCachedForumCategories() async {
    final value = await _forumCategoryRecord.get(database);
    if (value is! Map) return null;
    final categories = value['categories'];
    if (categories is! List) return null;
    return categories
        .map((category) => ForumCategory.fromJson(category as Map))
        .toList();
  }

  @override
  Future<List<ForumCategory>> fetchForumCategories() async {
    // 空 FormData 保证带上请求体，否则服务端返回 411
    final response = await _dio.post<dynamic>(
      _forumCategoryApiPath,
      data: FormData(),
    );
    final categories = _parseRemoteCategories(response.data);
    await _forumCategoryRecord.put(database, {
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
      'categories': categories.map((category) => category.toJson()).toList(),
    });
    return categories;
  }

  /// 解析 `app_api.php?__lib=home&__act=category` 的 data：
  /// 分类 → groups → forums 三层均为以序号为 key 的对象。
  /// 单个版块解析失败只跳过该版块，避免服务端个别脏数据导致整体不可用。
  List<ForumCategory> _parseRemoteCategories(Object? data) {
    final categories = <ForumCategory>[];
    for (final rawCategory in _jsonValues(data)) {
      if (rawCategory is! Map) continue;
      final id = rawCategory['_id']?.toString();
      final name = rawCategory['name']?.toString();
      if (id == null || name == null) continue;

      final groups = <ForumGroup>[];
      for (final rawGroup in _jsonValues(rawCategory['groups'])) {
        if (rawGroup is! Map) continue;
        final forums = <Forum>[];
        for (final rawForum in _jsonValues(rawGroup['forums'])) {
          if (rawForum is! Map) continue;
          try {
            forums.add(Forum.fromJson(rawForum));
          } on FormatException {
            continue;
          }
        }
        if (forums.isEmpty) continue;
        groups.add(ForumGroup(rawGroup['name']?.toString() ?? name, forums));
      }
      if (groups.isNotEmpty) {
        categories.add(ForumCategory(id, name, groups));
      }
    }
    if (categories.isEmpty) {
      throw const FormatException('Invalid forum category response.');
    }
    return categories;
  }

  Iterable<Object?> _jsonValues(Object? value) {
    if (value is Map) return value.values;
    if (value is List) return value;
    return const [];
  }

  @override
  Future<bool> isFavourite(Forum forum) async {
    final user = await _loadDefaultUser();
    final store = _favouriteStore(user?.uid);
    final record = await _findFavouriteRecord(database, store, forum.identity);
    return record != null;
  }

  @override
  Future<void> saveFavourite(Forum forum) async {
    final user = await _loadDefaultUser();
    final store = _favouriteStore(user?.uid);
    await database.transaction((transaction) async {
      await _upsertFavourite(transaction, store, forum);
      if (user != null) {
        await _putPendingAdd(transaction, user.uid, forum);
      }
    });
  }

  @override
  Future<void> deleteFavourite(Forum forum) async {
    final user = await _loadDefaultUser();
    final store = _favouriteStore(user?.uid);
    if (user == null) {
      await database.transaction((transaction) async {
        await _deleteLocalFavourite(
          transaction,
          store,
          forum.identity,
        );
      });
      return;
    }

    await _runAccountOperation(user.uid, () async {
      final pendingRecord = _pendingAddStore.record(
        _pendingAddKey(user.uid, forum.identity),
      );
      final pendingVersion = _pendingAddVersion(
        await pendingRecord.get(database),
      );

      await _updateRemoteFavourite(user, 'del', forum.fid);
      await database.transaction((transaction) async {
        final currentVersion = _pendingAddVersion(
          await pendingRecord.get(transaction),
        );
        if (currentVersion != pendingVersion) return;

        await _deleteLocalFavourite(
          transaction,
          store,
          forum.identity,
        );
        await pendingRecord.delete(transaction);
      });
    });
  }

  @override
  Future<List<Forum>> getFavouriteList() async {
    final user = await _loadDefaultUser();
    return _readForums(database, _favouriteStore(user?.uid));
  }

  @override
  Future<List<Forum>> syncFavouriteList() async {
    final user = await _loadDefaultUser();
    if (user == null) {
      return _readForums(database, _favouriteStore(null));
    }

    final runningSync = _syncFutures[user.uid];
    if (runningSync != null) {
      await runningSync;
      if (await _hasPendingAdds(user.uid)) {
        return _startSync(user);
      }
      return _readForums(database, _favouriteStore(user.uid));
    }
    return _startSync(user);
  }

  Future<List<Forum>> _startSync(CacheUser user) {
    final runningSync = _syncFutures[user.uid];
    if (runningSync != null) return runningSync;

    late final Future<List<Forum>> future;
    future = _runAccountOperation(
      user.uid,
      () => _syncUser(user),
    ).whenComplete(() {
      if (identical(_syncFutures[user.uid], future)) {
        _syncFutures.remove(user.uid);
      }
    });
    _syncFutures[user.uid] = future;
    return future;
  }

  Future<T> _runAccountOperation<T>(
    String uid,
    Future<T> Function() operation,
  ) {
    final previous = _accountOperationTails[uid] ?? Future<void>.value();
    final result = () async {
      try {
        await previous;
      } catch (_) {
        // 前一个操作失败不应阻断当前操作。
      }
      return operation();
    }();

    final completion = result.then<void>(
      (_) {},
      onError: (Object _, StackTrace __) {},
    );
    late final Future<void> tail;
    tail = completion.whenComplete(() {
      if (identical(_accountOperationTails[uid], tail)) {
        _accountOperationTails.remove(uid);
      }
    });
    _accountOperationTails[uid] = tail;
    return result;
  }

  Future<List<Forum>> _syncUser(CacheUser user) async {
    var remoteForums = await _fetchRemoteFavourites(user);
    await _claimLegacyFavourites(user, remoteForums);
    final remoteChanged = await _flushPendingAdds(user, remoteForums);
    if (remoteChanged) {
      remoteForums = await _fetchRemoteFavourites(user);
    }
    await _replaceAccountCache(user.uid, remoteForums);
    return _readForums(database, _favouriteStore(user.uid));
  }

  Future<List<Forum>> _fetchRemoteFavourites(CacheUser user) async {
    final response = await _postFavourite(user, {'action': 'get'});
    final responseData = response.data;
    final rawForums = responseData is Map ? responseData['0'] : null;
    if (rawForums is! Map) {
      throw const FormatException('Invalid favourite forum response.');
    }

    final forums = <Forum>[];
    for (final value in rawForums.values) {
      if (value is! Map) {
        throw const FormatException('Invalid favourite forum entry.');
      }
      forums.add(Forum.fromJson(value));
    }
    return forums;
  }

  Future<void> _claimLegacyFavourites(
    CacheUser user,
    List<Forum> remoteForums,
  ) async {
    final remoteIdentities =
        remoteForums.map((forum) => forum.identity).toSet();
    await database.transaction((transaction) async {
      final migration =
          await _metadataStore.record(_legacyMigrationKey).get(transaction);
      if (migration != null) return;

      final legacyForums =
          await _readForums(transaction, _favouriteStore(null));
      final accountStore = _favouriteStore(user.uid);
      for (final forum in legacyForums) {
        if (remoteIdentities.contains(forum.identity)) continue;
        await _upsertFavourite(transaction, accountStore, forum);
        await _putPendingAdd(transaction, user.uid, forum);
      }
      await _metadataStore.record(_legacyMigrationKey).put(
        transaction,
        {'uid': user.uid},
      );
    });
  }

  Future<bool> _flushPendingAdds(
    CacheUser user,
    List<Forum> remoteForums,
  ) async {
    final remoteIdentities =
        remoteForums.map((forum) => forum.identity).toSet();
    var remoteChanged = false;

    while (true) {
      final pendingAdds = await _readPendingAdds(database, user.uid);
      if (pendingAdds.isEmpty) return remoteChanged;

      for (final pending in pendingAdds) {
        if (!remoteIdentities.contains(pending.forum.identity)) {
          await _updateRemoteFavourite(user, 'add', pending.forum.fid);
          remoteIdentities.add(pending.forum.identity);
          remoteChanged = true;
        }
        await _deletePendingAddIfUnchanged(pending);
      }
    }
  }

  Future<void> _replaceAccountCache(
    String uid,
    List<Forum> remoteForums,
  ) async {
    final store = _favouriteStore(uid);
    await database.transaction((transaction) async {
      final merged = <ForumIdentity, Forum>{};
      for (final forum in remoteForums) {
        merged[forum.identity] = forum;
      }
      final pendingAdds = await _readPendingAdds(transaction, uid);
      for (final pending in pendingAdds) {
        merged[pending.forum.identity] = pending.forum;
      }

      await store.delete(transaction);
      for (final forum in merged.values) {
        await store.add(transaction, forum.toJson());
      }
    });
  }

  Future<void> _updateRemoteFavourite(
    CacheUser user,
    String action,
    int fid,
  ) async {
    await _postFavourite(user, {
      'action': action,
      'fid': fid.toString(),
    });
  }

  Future<Response<dynamic>> _postFavourite(
    CacheUser user,
    Map<String, String> fields,
  ) {
    final formData = FormData.fromMap({
      ...fields,
      'access_token': user.cid,
      'access_uid': user.uid,
    });
    final options = Options(headers: {
      'Cookie': '$TAG_UID=${user.uid};$TAG_CID=${user.cid}',
    });
    return _dio.post<dynamic>(
      _favouriteApiPath,
      data: formData,
      options: options,
    );
  }

  Future<List<Forum>> _readForums(
    DatabaseClient client,
    StoreRef<int, dynamic> store,
  ) async {
    final records = await store.find(client);
    return records.map((record) {
      final value = record.value;
      if (value is! Map) {
        throw const FormatException('Invalid cached forum data.');
      }
      return Forum.fromJson(value);
    }).toList();
  }

  Future<RecordSnapshot<int, dynamic>?> _findFavouriteRecord(
    DatabaseClient client,
    StoreRef<int, dynamic> store,
    ForumIdentity identity,
  ) async {
    final records = await store.find(
      client,
      finder: Finder(filter: Filter.equals('fid', identity.id)),
    );
    for (final record in records) {
      final value = record.value;
      if (value is Map && Forum.fromJson(value).identity == identity) {
        return record;
      }
    }
    return null;
  }

  Future<void> _upsertFavourite(
    DatabaseClient client,
    StoreRef<int, dynamic> store,
    Forum forum,
  ) async {
    final record = await _findFavouriteRecord(client, store, forum.identity);
    if (record == null) {
      await store.add(client, forum.toJson());
      return;
    }
    await store.record(record.key).put(client, forum.toJson());
  }

  Future<void> _deleteLocalFavourite(
    DatabaseClient client,
    StoreRef<int, dynamic> store,
    ForumIdentity identity,
  ) async {
    final record = await _findFavouriteRecord(client, store, identity);
    if (record != null) {
      await store.record(record.key).delete(client);
    }
  }

  Future<void> _putPendingAdd(
    DatabaseClient client,
    String uid,
    Forum forum,
  ) async {
    final record = _pendingAddStore.record(_pendingAddKey(uid, forum.identity));
    final existing = await record.get(client);
    final previousVersion =
        existing is Map ? _parseStoredInt(existing['version']) ?? 0 : 0;
    await record.put(client, {
      ...forum.toJson(),
      'uid': uid,
      'version': previousVersion + 1,
    });
  }

  Future<List<_PendingFavouriteAdd>> _readPendingAdds(
    DatabaseClient client,
    String uid,
  ) async {
    final records = await _pendingAddStore.find(
      client,
      finder: Finder(filter: Filter.equals('uid', uid)),
    );
    return records.map(_PendingFavouriteAdd.fromRecord).toList();
  }

  Future<bool> _hasPendingAdds(String uid) async {
    return (await _readPendingAdds(database, uid)).isNotEmpty;
  }

  Future<void> _deletePendingAddIfUnchanged(
    _PendingFavouriteAdd pending,
  ) async {
    await database.transaction((transaction) async {
      final record = _pendingAddStore.record(pending.key);
      final current = await record.get(transaction);
      if (current is! Map ||
          _parseStoredInt(current['version']) != pending.version) {
        return;
      }
      await record.delete(transaction);
    });
  }

  int? _pendingAddVersion(Object? value) {
    return value is Map ? _parseStoredInt(value['version']) : null;
  }

  String _pendingAddKey(String uid, ForumIdentity identity) {
    return '$uid:${identity.storageKey}';
  }

  @override
  Future<List<Forum>> getForumByName(String keyword) async {
    try {
      Response<Map<String, dynamic>> response = await _dio
          .get("forum.php?&__output=8&key=${code_utils.urlEncode(keyword)}");
      Map<String, dynamic> map = response.data!;
      List<Forum> forums = [];
      map.forEach((k, v) {
        forums.add(Forum.fromJson(v));
      });
      return forums;
    } catch (err) {
      rethrow;
    }
  }

  @override
  Future<String?> addChildForumSubscription(int fid, int? parentId) async {
    try {
      final formData = FormData.fromMap({
        "fid": parentId,
        "type": 1,
        "info": "add_to_block_tids",
      });
      Response<Map<String, dynamic>> response = await _dio.post(
          "nuke.php?__lib=user_option&__act=set&raw=3&del=$fid",
          data: formData);
      return response.data!["0"];
    } catch (err) {
      rethrow;
    }
  }

  @override
  Future<String?> deleteChildForumSubscription(int fid, int? parentId) async {
    try {
      final formData = FormData.fromMap({
        "fid": parentId,
        "type": 1,
        "info": "add_to_block_tids",
      });
      Response<Map<String, dynamic>> response = await _dio.post(
          "nuke.php?__lib=user_option&__act=set&raw=3&add=$fid",
          data: formData);
      return response.data!["0"];
    } catch (err) {
      rethrow;
    }
  }
}

class _PendingFavouriteAdd {
  const _PendingFavouriteAdd({
    required this.key,
    required this.forum,
    required this.version,
  });

  final String key;
  final Forum forum;
  final int version;

  factory _PendingFavouriteAdd.fromRecord(
    RecordSnapshot<String, dynamic> record,
  ) {
    final value = record.value;
    if (value is! Map) {
      throw const FormatException('Invalid pending favourite forum data.');
    }
    final version = _parseStoredInt(value['version']);
    if (version == null) {
      throw const FormatException('Invalid pending favourite forum version.');
    }
    return _PendingFavouriteAdd(
      key: record.key,
      forum: Forum.fromJson(value),
      version: version,
    );
  }
}

int? _parseStoredInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '');
}
