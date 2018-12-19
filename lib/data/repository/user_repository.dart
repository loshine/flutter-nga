import 'package:flutter_nga/data/entity/user.dart';
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
    if (cid != null &&
        cid.isNotEmpty &&
        uid != null &&
        uid.isNotEmpty &&
        username != null &&
        username.isNotEmpty) {
      var user = User(uid, cid, username);
      List<Map<dynamic, dynamic>> list = await _userDb.find({'uid': uid});
      if (list.isNotEmpty) {
        return User.fromMap(list[0]);
      }
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
