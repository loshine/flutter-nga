import 'package:dio/dio.dart';
import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/data/entity/user.dart';
import 'package:flutter_nga/utils/code_utils.dart' as codeUtils;
import 'package:sembast/sembast.dart';

const TAG_CID = "ngaPassportCid";
const TAG_UID = "ngaPassportUid";
const TAG_USER_NAME = "ngaPassportUrlencodedUname";

abstract class UserRepository {
  Future<CacheUser> saveLoginCookies(String cookies);

  Future<CacheUser> saveLogin(String uid, String token, String username);

  Future<CacheUser?> getDefaultUser();

  Future<List<CacheUser>> getAllLoginUser();

  Future<int> quitAllLoginUser();

  Future<UserInfo> getUserInfoByName(String? username);

  Future<UserInfo> getUserInfoByUid(String? uid);

  Future<bool> setDefault(CacheUser cacheUser);

  Future<bool> deleteCacheUser(CacheUser cacheUser);
}

class UserDataRepository implements UserRepository {
  UserDataRepository(this.database);

  final Database database;

  StoreRef<int, dynamic> get _store {
    if (_lateInitStore == null) {
      _lateInitStore = intMapStoreFactory.store('users');
    }
    return _lateInitStore!;
  }

  StoreRef<int, dynamic>? _lateInitStore;

  @override
  Future<CacheUser> saveLoginCookies(String cookies) async {
    String? uid;
    String? cid;
    String? username;
    for (String c in cookies.split(";")) {
      final value = c.trim();
      print(value);
      if (value.contains(TAG_UID)) {
        uid = value.substring(TAG_UID.length + 1);
      } else if (c.contains(TAG_CID)) {
        cid = value.substring(TAG_CID.length + 1);
      } else if (c.contains(TAG_USER_NAME)) {
        username = value.substring(TAG_USER_NAME.length + 1);
        username = codeUtils.urlDecode(username);
      }
    }
    if (cid != null &&
        cid.isNotEmpty &&
        uid != null &&
        uid.isNotEmpty &&
        username != null &&
        username.isNotEmpty) {
      return saveLogin(uid, cid, username);
    }
    throw "cookies parse error: cookies = $cookies";
  }

  @override
  Future<CacheUser> saveLogin(String uid, String token, String username) async {
    final user = CacheUser(uid, token, username, true);
    return saveCacheUser(user);
  }

  @override
  Future<CacheUser?> getDefaultUser() async {
    final record = await _store.findFirst(
      database,
      finder: Finder(
        filter: Filter.equals('enabled', true),
      ),
    );
    if (record != null) {
      return CacheUser.fromJson(record.value);
    } else {
      return null;
    }
  }

  @override
  Future<List<CacheUser>> getAllLoginUser() async {
    final list = await _store.find(database);
    return list.map((m) => CacheUser.fromJson(m.value)).toList();
  }

  @override
  Future<int> quitAllLoginUser() {
    return _store.delete(database);
  }

  @override
  Future<UserInfo> getUserInfoByName(String? username) async {
    try {
      final encodedUsername = codeUtils.urlEncode(username!);
      Response<Map<String, dynamic>> response = await Data().dio.get(
          "nuke.php?__lib=ucp&__act=get&__output=8&username=$encodedUsername");
      // {"0": { userinfo }};
      Map<String, dynamic> userInfoMap = response.data!["0"];
      return UserInfo.fromJson(userInfoMap);
    } catch (err) {
      rethrow;
    }
  }

  @override
  Future<UserInfo> getUserInfoByUid(String? uid) async {
    try {
      Response<Map<String, dynamic>> response = await Data()
          .dio
          .get("nuke.php?__lib=ucp&__act=get&__output=8&uid=$uid");
      // {"0": { userinfo }};
      Map<String, dynamic> userInfoMap = response.data!["0"];
      return UserInfo.fromJson(userInfoMap);
    } catch (err) {
      rethrow;
    }
  }

  @override
  Future<bool> setDefault(CacheUser cacheUser) async {
    final preUser = await getDefaultUser();
    if (preUser != null) {
      if (preUser.uid == cacheUser.uid) {
        return false;
      }
      await saveCacheUser(
          CacheUser(preUser.uid, preUser.cid, preUser.nickname, false));
    }
    await saveCacheUser(
        CacheUser(cacheUser.uid, cacheUser.cid, cacheUser.nickname, true));
    return true;
  }

  Future<CacheUser> saveCacheUser(CacheUser user) async {
    final finder = Finder(filter: Filter.equals('uid', user.uid));
    List<RecordSnapshot<int, dynamic>> list =
        await _store.find(database, finder: finder);
    // 有以前登陆过的就把以前登陆过的删除
    if (list.isNotEmpty) {
      await _store.delete(database, finder: finder);
    }
    await _store.add(database, user.toJson());
    return user;
  }

  @override
  Future<bool> deleteCacheUser(CacheUser cacheUser) async {
    final count = await _store.delete(database,
        finder: Finder(filter: Filter.equals('uid', cacheUser.uid)));
    final defaultUser = await getDefaultUser();
    final totalCount = await _store.count(database);
    if (defaultUser == null && totalCount > 0) {
      final record = await _store.findFirst(database);
      if (record != null) {
        final firstUser = CacheUser.fromJson(record.value);
        await saveCacheUser(
            CacheUser(firstUser.uid, firstUser.cid, firstUser.nickname, true));
      }
    }
    return count > 0;
  }
}
