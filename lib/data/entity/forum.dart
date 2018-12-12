/// 版块实体类
class Forum {
  const Forum(this.fid, this.name)
      : assert(fid != null),
        assert(name != null);

  final int fid;
  final String name;

  Map toMap() {
    return {'fid': fid, 'name': name};
  }

  factory Forum.fromMap(Map map){
    return Forum(map['fid'], map['name']);
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
