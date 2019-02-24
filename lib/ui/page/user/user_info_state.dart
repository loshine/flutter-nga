class UserInfoState {
  final int uid;
  final String username;
  final String avatar;
  final Map<String, String> basicInfoMap;
  final String signature;
  final Map<int, String> moderatorForums; // 管理版面
  final Map<String, String> reputationMap; // 声望
  final Map<int, String> personalForum; // 个人版面

  const UserInfoState({
    this.uid,
    this.username,
    this.avatar,
    this.basicInfoMap,
    this.signature,
    this.moderatorForums,
    this.reputationMap,
    this.personalForum,
  });

  factory UserInfoState.initial() => UserInfoState(
        uid: 0,
        username: "",
        avatar: "",
        basicInfoMap: {
          '用户ID': 'N/A',
          '用户名': 'N/A',
          '用户组': 'N/A',
          '财富': 'N/A',
          '注册日期': 'N/A'
        },
        signature: "N/A",
        moderatorForums: {},
        reputationMap: {
          '威望': '0.0',
        },
        personalForum: {},
      );
}
