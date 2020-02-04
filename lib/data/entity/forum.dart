/// 版块实体类
class Forum {
  const Forum(this.fid, this.name)
      : assert(fid != null),
        assert(name != null);

  final int fid;
  final String name;

  factory Forum.fromJson(Map map) {
    return Forum(map['fid'], map['name']);
  }

  Map<String, dynamic> toJson() {
    return {'fid': fid, 'name': name};
  }

  String getIconUrl() {
    return "http://img4.nga.178.com/ngabbs/nga_classic/f/app/$fid.png";
  }
}

/// 版块组实体类
class ForumGroup {
  const ForumGroup(this.name, this.forumList)
      : assert(name != null),
        assert(forumList != null);

  final String name;
  final List<Forum> forumList;
}
