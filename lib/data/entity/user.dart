class User {
  User(
    this.uid,
    this.cid,
    this.nickname, {
    this.avatarUrl,
    this.replyCount,
    this.replyString,
  });

  final String uid;
  final String cid;
  final String nickname;
  final String avatarUrl;

  int replyCount;
  String replyString;

  Map<String, dynamic> toJson() {
    return {'uid': uid, 'cid': cid, 'nickname': nickname};
  }

  factory User.fromJson(Map map) {
    return User(
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
  final int uid;
  final String username;
  final int gid;
  final int groupId;
  final int memberId;
  final String group;
  final int registerDate;
  final String avatar;
  final String sign;
  final int posts;
  final int fame;
  final int money;
  final Map<String, dynamic> adminForums;
  final Map<String, dynamic> userForum;
  final List<ForumReputation> reputation;

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
    Map<String, dynamic> reputationMap = map['reputation'];
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
      adminForums: adminForums is Map ? adminForums : null,
      userForum: userForum is Map ? userForum : null,
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

  final int id;
  final String name;
  final int value;
  final String description;

  factory ForumReputation.fromJson(Map map) {
    return ForumReputation(
      id: map['id'],
      name: map['0'],
      value: map['1'],
      description: map['2'],
    );
  }
}
