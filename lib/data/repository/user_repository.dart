import 'package:flutter_nga/data/entity/user.dart';
import 'package:gbk2utf8/gbk2utf8.dart';
import 'package:objectdb/objectdb.dart';

const TAG_CID = "ngaPassportCid";
const TAG_OID = "ngaPassportOid";
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

  Future<User> saveLoginCookies(Map<String, String> cookies) async {
    String uid;
    String cid;
    String username;
    for (MapEntry<String, String> entry in cookies.entries) {
      print("key = ${entry.key}, value = ${entry.value}");
      // 因为 key 带空格，so。。
      if (entry.key.contains(TAG_UID)) {
        uid = entry.value;
      } else if (entry.key.contains(TAG_OID)) {
        cid = entry.value;
      } else if (entry.key.contains(TAG_USER_NAME)) {
        username = entry.value;
        try {
          username = decodeGbk(username.codeUnits);
          username = decodeGbk(username.codeUnits);
        } catch (e) {
          print(e.toString());
        }
      }
    }
    print("cid = $cid, uid = $uid, username = $username");
    if (cid != null &&
        cid.isNotEmpty &&
        uid != null &&
        uid.isNotEmpty &&
        username != null &&
        username.isNotEmpty) {
      var user = User(uid, cid, username);
      await _userDb.insert(user.toMap());
      return user;
    }
    throw "cookies parse error: cookies = $cookies";
  }

  Future<User> getDefaultUser() async {
    final list = await _userDb.find({});
    if (list.isNotEmpty) {
      final map = await _userDb.first({});
      return User.fromMap(map);
    } else {
      throw "no login user";
    }
  }
}
