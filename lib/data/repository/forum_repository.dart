import 'package:dio/dio.dart';
import 'package:sembast/sembast.dart';

import 'package:flutter_nga/data/entity/forum.dart';
import 'package:flutter_nga/data/entity/user.dart';
import 'package:flutter_nga/data/repository/user_repository.dart';
import 'package:flutter_nga/utils/code_utils.dart' as code_utils;

/// 版块相关数据知识库
abstract class ForumRepository {
  List<ForumGroup> getForumGroups();

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

  final List<ForumGroup> forumGroupList = [];

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

  @override
  List<ForumGroup> getForumGroups() {
    if (forumGroupList.isEmpty) {
      var forumList = [
        Forum(-7, "大漩涡"),
        Forum(-187579, "历史博物馆"),
        Forum(-447601, "二次元"),
        Forum(-353371, "宠物养成"),
        Forum(-343809, "汽车俱乐部"),
        Forum(-81981, "生命之杯"),
        Forum(485, "篮球"),
        Forum(-576177, "影音讨论区"),
        Forum(414, "游戏综合讨论"),
        Forum(436, "消费电子 IT新闻"),
        Forum(334, "硬件配置"),
        Forum(498, "二手交易"),
      ];
      var group = ForumGroup("网事杂谈", forumList);
      forumGroupList.add(group);

      forumList = [
        Forum(7, "议事厅"),
        Forum(181, "铁血沙场"),
        Forum(184, "圣光广场"),
        Forum(320, "黑锋要塞"),
        Forum(187, "猎手大厅"),
        Forum(185, "风暴祭坛"),
        Forum(189, "暗影裂口"),
        Forum(186, "翡翠梦境"),
        Forum(477, "伊利达雷"),
        Forum(390, "五晨寺"),
        Forum(182, "魔法圣堂"),
        Forum(188, "恶魔深渊"),
        Forum(183, "信仰神殿"),
        Forum(310, "精英议会"),
        Forum(190, "任务讨论"),
        Forum(213, "战争档案"),
        Forum(218, "副本专区"),
        Forum(258, "战场讨论"),
        Forum(272, "竞技场"),
        Forum(191, "地精商会"),
        Forum(200, "插件研究"),
        Forum(460, "BigFoot"),
        Forum(274, "插件发布"),
        Forum(333, "DKP系统"),
        Forum(327, "成就讨论"),
        Forum(388, "幻化讨论"),
        Forum(411, "宠物讨论"),
        Forum(255, "公会管理"),
        Forum(306, "人员招募"),
        Forum(264, "卡拉赞剧院"),
        Forum(8, "大图书馆"),
        Forum(102, "作家协会"),
        Forum(124, "壁画洞窟"),
        Forum(254, "镶金玫瑰"),
        Forum(355, "龟岩兄弟会"),
        Forum(116, "奇迹之泉"),
        Forum(323, "国服以外"),
        Forum(10, "银色黎明"),
        Forum(230, "风纪委员会"),
      ];

      group = ForumGroup("魔兽世界", forumList);
      forumGroupList.add(group);

      forumList = [
        Forum(459, "守望先锋"),
        Forum(422, "炉石传说"),
        Forum(318, "暗黑破坏神3"),
        Forum(431, "风暴英雄"),
        Forum(406, "星际争霸2"),
        Forum(490, "魔兽争霸"),
      ];
      group = ForumGroup("暴雪游戏", forumList);
      forumGroupList.add(group);

      forumList = [
        Forum(-152678, "英雄联盟"),
        Forum(479, "英雄联盟赛事"),
        Forum(418, "英雄联盟视频"),
        Forum(660, "云顶之弈"),
      ];
      group = ForumGroup("拳头游戏", forumList);
      forumGroupList.add(group);

      forumList = [
        Forum(482, "CS:GO"),
        Forum(321, "DOTA2"),
        Forum(622, "刀塔卡牌 Artifact"),
        Forum(641, "DotA自走棋"),
        Forum(659, "刀塔霸业"),
      ];
      group = ForumGroup("Valve Games", forumList);
      forumGroupList.add(group);

      forumList = [
        Forum(614, "PlayStation"),
        Forum(615, "XBox"),
        Forum(616, "Nintendo"),
      ];
      group = ForumGroup("主机游戏", forumList);
      forumGroupList.add(group);

      forumList = [
        Forum(414, "游戏综合讨论"),
        Forum(428, "手机游戏"),
        Forum(-452227, "口袋妖怪"),
        Forum(426, "智龙迷城"),
        Forum(-51095, "部落冲突"),
        Forum(492, "部落冲突:皇室战争"),
        Forum(-362960, "最终幻想14"),
        Forum(-6194253, "战争雷霆"),
        Forum(489, "怪物猎人"),
        Forum(-47218, "地下城与勇士"),
        Forum(425, "行星边际2"),
        Forum(-65653, "剑灵"),
        Forum(412, "巫师之怒"),
        Forum(-235147, "激战2"),
        Forum(442, "逆战"),
        Forum(-46468, "洛拉斯的战争世界"),
        Forum(432, "战机世界"),
        Forum(441, "战舰世界"),
        Forum(-2371813, "EVE"),
        Forum(-7861121, "剑叁 "),
        Forum(448, "剑叁同人 "),
        Forum(-793427, "斗战神"),
        Forum(332, "战锤40K"),
        Forum(416, "火炬之光2"),
        Forum(420, "MT Online"),
        Forum(424, "圣斗士星矢"),
        Forum(-1513130, "鲜血兄弟会"),
        Forum(433, "神雕侠侣"),
        Forum(434, "神鬼幻想"),
        Forum(435, "上古卷轴Online"),
        Forum(443, "FIFA Online 3"),
        Forum(444, "刀塔传奇"),
        Forum(445, "迷你西游"),
        Forum(447, "锁链战记"),
        Forum(-532408, "沃土"),
        Forum(353, "纽沃斯英雄传"),
        Forum(452, "天涯明月刀"),
        Forum(453, "魔力宝贝"),
        Forum(454, "神之浩劫"),
        Forum(455, "鬼武者 魂"),
        Forum(480, "百万亚瑟王"),
        Forum(481, "Minecraft"),
        Forum(484, "热血江湖传"),
        Forum(486, "辐射"),
        Forum(487, "刀剑魔药2"),
        Forum(488, "村长打天下"),
        Forum(493, "刀塔战纪"),
        Forum(494, "魔龙之魂"),
        Forum(495, "光荣三国志系列"),
        Forum(496, "九十九姬"),
      ];
      group = ForumGroup("其他游戏", forumList);
      forumGroupList.add(group);

      forumList = [
        Forum(193, "帐号安全"),
        Forum(334, "PC软硬件"),
        Forum(201, "系统问题"),
        Forum(335, "网站开发"),
        Forum(275, "测试版面"),
      ];
      group = ForumGroup("系统软硬件讨论", forumList);
      forumGroupList.add(group);

      forumList = [
        Forum(-447601, "二次元国家地理"),
        Forum(-84, "模玩之魂"),
        Forum(-8725919, "小窗视界"),
        Forum(-965240, "树洞"),
        Forum(-131429, "红茶馆——小说馆"),
        Forum(-608808, "血腥厨房"),
        Forum(-469608, "影~视~秀"),
        Forum(-55912, "音乐讨论"),
        Forum(-522474, "综合体育讨论区"),
        Forum(-1068355, "晴风村"),
        Forum(-168888, "育儿版"),
        Forum(-54214, "时尚板"),
        Forum(-353371, "宠物养成"),
        Forum(-538800, "乙女向二次元"),
        Forum(-7678526, "麻将科学院"),
        Forum(-202020, "程序员职业交流"),
        Forum(-444012, "我们的骑迹"),
        Forum(-349066, "开心茶园"),
        Forum(-314508, "世界尽头的百货公司"),
        Forum(-2671, "耳机区"),
        Forum(-970841, "东方教主陈乔恩"),
        Forum(-3355501, "饭饭的小窝"),
        Forum(-403298, "怨灵图纸收藏室"),
        Forum(-3432136, "飘落的诗章"),
        Forum(-187628, "家居 装修"),
        Forum(-8627585, "牛头人酋长乐队"),
        Forum(-17100, "全民健身中心"),
      ];
      group = ForumGroup("个人版面", forumList);
      forumGroupList.add(group);
    }

    return forumGroupList;
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
