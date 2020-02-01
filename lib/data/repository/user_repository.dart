import 'package:dio/dio.dart';
import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/data/entity/user.dart';
import 'package:flutter_nga/plugins/android_gbk.dart';
import 'package:objectdb/objectdb.dart';

const TAG_CID = "ngaPassportCid";
const TAG_UID = "ngaPassportUid";
const TAG_USER_NAME = "ngaPassportUrlencodedUname";

abstract class UserRepository {
  Future<User> saveLoginCookies(String cookies);

  Future<User> getDefaultUser();

  Future<List<User>> getAllLoginUser();

  Future<UserInfo> getUserInfoByName(String username);

  Future<UserInfo> getUserInfoByUid(String uid);

  Future<int> quitAllLoginUser();
}

class UserDataRepository implements UserRepository {
  UserDataRepository(this.userDb);

  final ObjectDB userDb;

  @override
  Future<User> saveLoginCookies(String cookies) async {
    String uid;
    String cid;
    String username;
    for (String c in cookies.split(";")) {
      print(c);
      // 因为 key 带空格，so。。
      if (c.contains(TAG_UID)) {
        uid = c.trim().substring(TAG_UID.length + 1);
      } else if (c.contains(TAG_CID)) {
        cid = c.trim().substring(TAG_CID.length + 1);
      } else if (c.contains(TAG_USER_NAME)) {
        username = c.trim().substring(TAG_USER_NAME.length + 1);
        username = await AndroidGbk.decodeName(username);
      }
    }
    if (cid != null &&
        cid.isNotEmpty &&
        uid != null &&
        uid.isNotEmpty &&
        username != null &&
        username.isNotEmpty) {
      var user = User(uid, cid, username);
      List<Map<dynamic, dynamic>> list = await userDb.find({'uid': uid});
      // 有以前登陆过的就把以前登陆过的删除
      if (list.isNotEmpty) {
        await userDb.remove({'uid': uid});
      }
      await userDb.insert(user.toJson());
      return user;
    }
    throw "cookies parse error: cookies = $cookies";
  }

  @override
  Future<User> getDefaultUser() async {
    final list = await userDb.find({});
    if (list.isNotEmpty) {
      final map = await userDb.first({});
      return User.fromJson(map);
    } else {
      return null;
    }
  }

  @override
  Future<List<User>> getAllLoginUser() async {
    final list = await userDb.find({});
    print(list.toString());
    return list.map((m) => User.fromJson(m)).toList();
  }

  @override
  Future<UserInfo> getUserInfoByName(String username) async {
    try {
      final encodedUsername = await AndroidGbk.urlEncode(username);
      Response<Map<String, dynamic>> response = await Data().dio.get(
          "nuke.php?__lib=ucp&__act=get&lite=js&noprefix&username=$encodedUsername");
      // {"0": { userinfo }};
      Map<String, dynamic> userInfoMap = response.data["0"];
      return UserInfo.fromJson(userInfoMap);
    } catch (err) {
      rethrow;
    }
  }

  @override
  Future<UserInfo> getUserInfoByUid(String uid) async {
    try {
      Response<Map<String, dynamic>> response = await Data()
          .dio
          .get("nuke.php?__lib=ucp&__act=get&lite=js&noprefix&uid=$uid");
      // {"0": { userinfo }};
      Map<String, dynamic> userInfoMap = response.data["0"];
      return UserInfo.fromJson(userInfoMap);
    } catch (err) {
      rethrow;
    }
  }

  @override
  Future<int> quitAllLoginUser() {
    return userDb.remove({});
  }
}
