import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/data/entity/user.dart';
import 'package:flutter_nga/plugins/android_gbk.dart';
import 'package:flutter_nga/utils/constant.dart';
import 'package:gbk2utf8/gbk2utf8.dart';
import 'package:objectdb/objectdb.dart';

const TAG_CID = "ngaPassportCid";
const TAG_UID = "ngaPassportUid";
const TAG_USER_NAME = "ngaPassportUrlencodedUname";

class UserRepository {
  static final UserRepository _singleton = UserRepository._internal();

  ObjectDB _userDb;

  factory UserRepository() {
    return _singleton;
  }

  UserRepository._internal();

  void init(ObjectDB db) async {
    _userDb = db;
    _userDb.open();
  }

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
        try {
          username = decodeGbk(username.codeUnits);
          username = decodeGbk(username.codeUnits);
        } catch (e) {
          print(e.toString());
        }
      }
    }
    print("cid = $cid, uid = $uid, username = $username");
    List<Cookie> cookieList = [
      Cookie(TAG_CID, cid),
      Cookie(TAG_UID, uid),
    ];
    var uri = Uri.parse(DOMAIN);
    Data().dio.cookieJar.saveFromResponse(uri, cookieList);
    if (cid != null &&
        cid.isNotEmpty &&
        uid != null &&
        uid.isNotEmpty &&
        username != null &&
        username.isNotEmpty) {
      var user = User(uid, cid, username);
      List<Map<dynamic, dynamic>> list = await _userDb.find({'uid': uid});
      // 有以前登陆过的就把以前登陆过的删除
      if (list.isNotEmpty) {
        await _userDb.remove({'uid': uid});
      }
      await _userDb.insert(user.toJson());
      return user;
    }
    throw "cookies parse error: cookies = $cookies";
  }

  Future<User> getDefaultUser() async {
    final list = await _userDb.find({});
    if (list.isNotEmpty) {
      final map = await _userDb.first({});
      return User.fromJson(map);
    } else {
      return null;
    }
  }

  Future<UserInfo> getUserInfo(String username) async {
    try {
      final encodedUsername = await AndroidGbk.urlEncode(username);
      Response<Map<String, dynamic>> response = await Data().dio.get(
          "nuke.php?__lib=ucp&__act=get&lite=js&noprefix&username=$encodedUsername");
      // {"0": { userinfo }};
      Map<String, dynamic> userInfoMap = response.data["0"];
      return UserInfo.fromJson(userInfoMap);
    } catch (error) {
      rethrow;
    }
  }
}
