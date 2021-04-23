import 'package:flutter_nga/utils/name_utils.dart' as nameUtils;

class User {
  int? uid;
  final String? username;
  final int? credit;
  final String? medal;
  final String? reputation;
  final int? groupId;
  final int? memberId;
  final String? avatar; // 可能是 String，也可能是 map
  final List<String?>? avatarList; // 当 avatar 是 map 的时候用来替代
  final int? yz;
  final String? site;
  final String? honor;
  final int? regDate;
  final String? muteTime;
  final int? postNum;
  final int? rvrc;
  final int? money;
  final int? thisVisit;
  final String? signature;
  final int? bitData;

  User({
    this.uid,
    this.username,
    this.credit,
    this.medal,
    this.reputation,
    this.groupId,
    this.memberId,
    this.avatar,
    this.avatarList,
    this.yz,
    this.site,
    this.honor,
    this.regDate,
    this.muteTime,
    this.postNum,
    this.rvrc,
    this.money,
    this.thisVisit,
    this.signature,
    this.bitData,
  });

  factory User.fromJson(Map<String, dynamic> map) {
    dynamic avatar = map["avatar"];
    List<String?> avatarList = [];
    if (avatar != null) {
      if (avatar is String) {
        avatarList.add(avatar);
      } else if (avatar is Map) {
        final size = avatar["l"];
        if (size != null && size is int) {
          for (int i = 0; i < size; i++) {
            if (avatar["$i"] is String) {
              avatarList.add(avatar["$i"]);
            } else if (avatar["$i"] is Map) {
              avatarList.add(avatar["$i"][0]);
            }
          }
        }
        avatar = avatarList[0];
      }
    }
    return User(
      uid: map["uid"],
      username: map["username"].toString(),
      // 可能是int
      credit: map["credit"],
      medal: map["medal"].toString(),
      reputation: map["reputation"].toString(),
      groupId: map["groupid"],
      memberId: map["memberid"],
      avatar: avatar,
      avatarList: avatarList,
      yz: map["yz"],
      site: map["site"],
      honor: map["honor"],
      regDate: map["regdate"],
      muteTime: map["mute_time"].toString(),
      postNum: map["postnum"],
      rvrc: map["rvrc"],
      money: map["money"],
      thisVisit: map["thisvisit"],
      signature: map["signature"].toString(),
      bitData: map["bit_data"],
    );
  }

  String getShowName() {
    return nameUtils.getShowName(username!);
  }

  String getShowReputation() {
    return "${rvrc != null ? rvrc! / 10.0 : 0.0}";
  }
}

class CacheUser {
  CacheUser(
    this.uid,
    this.cid,
    this.nickname, {
    this.avatarUrl,
    this.replyCount,
    this.replyString,
  });

  final String? uid;
  final String? cid;
  final String? nickname;
  final String? avatarUrl;

  int? replyCount;
  String? replyString;

  Map<String, dynamic> toJson() {
    return {'uid': uid, 'cid': cid, 'nickname': nickname};
  }

  factory CacheUser.fromJson(Map map) {
    return CacheUser(
      map['uid'],
      map['cid'],
      map['nickname'],
      avatarUrl: map['avatarUrl'],
      replyCount: map['replyCount'],
      replyString: map['replyString'],
    );
  }
}

class UserInfo {
  final int? uid;
  final String? username;
  final int? gid;
  final int? groupId;
  final int? memberId;
  final String? group;
  final int? registerDate;
  final String? avatar;
  final String? sign;
  final int? posts;
  final int? fame;
  final int? money;
  final Map<String, dynamic>? adminForums;
  final Map<String, dynamic>? userForum;
  final List<ForumReputation>? reputation;

  const UserInfo({
    this.uid,
    this.username,
    this.gid,
    this.groupId,
    this.memberId,
    this.group,
    this.registerDate,
    this.avatar,
    this.sign,
    this.posts,
    this.fame,
    this.money,
    this.adminForums,
    this.userForum,
    this.reputation,
  });

  factory UserInfo.fromJson(Map map) {
    List<ForumReputation> reputationList = [];
    Map<String, dynamic>? reputationMap = map['reputation'];
    if (reputationMap != null) {
      reputationMap.forEach((k, v) {
        (v as Map)['id'] = int.parse(k);
        reputationList.add(ForumReputation.fromJson(v));
      });
    }
    final userForum = map['userForum'];
    final adminForums = map['adminForums'];
    return UserInfo(
      uid: map['uid'],
      username: map['username'],
      gid: map['gid'],
      groupId: map['groupid'],
      memberId: map['memberid'],
      group: map['group'],
      registerDate: map['regdate'],
      avatar: map['avatar'],
      sign: map['sign'],
      posts: map['posts'],
      fame: map['fame'],
      money: map['money'],
      adminForums:
          adminForums is Map ? adminForums as Map<String, dynamic>? : null,
      userForum: userForum is Map ? userForum as Map<String, dynamic>? : null,
      reputation: reputationList,
    );
  }
}

class ForumReputation {
  const ForumReputation({
    this.id,
    this.name,
    this.value,
    this.description,
  });

  final int? id;
  final String? name;
  final int? value;
  final String? description;

  factory ForumReputation.fromJson(Map map) {
    return ForumReputation(
      id: map['id'],
      name: map['0'],
      value: map['1'],
      description: map['2'],
    );
  }
}
