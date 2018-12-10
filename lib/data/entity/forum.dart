class Forum {
  const Forum(this.fid, this.name)
      : assert(fid != null),
        assert(name != null);

  final int fid;
  final String name;
}

class ForumGroup {
  const ForumGroup(this.name, this.forumList)
      : assert(name != null),
        assert(forumList != null);

  final String name;
  final List<Forum> forumList;
}
