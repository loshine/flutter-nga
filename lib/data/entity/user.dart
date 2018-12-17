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

  Map toMap() {
    return {'uid': uid, 'cid': cid, 'nickname': nickname};
  }

  factory User.fromMap(Map map) {
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
