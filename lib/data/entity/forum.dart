

/// 版块实体类
class Forum {
  const Forum(this.fid, this.name, {this.type = 0});

  final int fid;
  final String name;
  final int type;

  factory Forum.fromJson(Map map) {
    return Forum(map['fid'], map['name'], type: map['type'] ?? 0);
  }

  Map<String, dynamic> toJson() {
    return {'fid': fid, 'name': name, 'type': type};
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
