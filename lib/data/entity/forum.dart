/// 版块实体类
class Forum {
  const Forum(this.fid, this.name);

  final int fid;
  final String name;

  factory Forum.fromJson(Map map) {
    return Forum(map['fid'], map['name']);
  }

  Map<String, dynamic> toJson() {
    return {'fid': fid, 'name': name};
  }

  String getIconUrl() {
    return "https://img4.nga.178.com/ngabbs/nga_classic/f/app/$fid.png";
  }
}

/// 版块组实体类
class ForumGroup {
  const ForumGroup(this.name, this.forumList);

  final String name;
  final List<Forum> forumList;
}
