/// 版块实体类
class Forum {
  const Forum(this.fid, this.name, {this.type = 0, this.iconId});

  final int fid;
  final String name;
  final int type;
  final int? iconId;

  ForumIdentity get identity => ForumIdentity(fid, type);

  factory Forum.fromJson(Map map) {
    final stid = _parseNonZeroInt(map['stid']);
    final fid = stid ?? _parseInt(map['fid']);
    final name = map['name']?.toString();
    if (fid == null || name == null) {
      throw const FormatException('Invalid forum data.');
    }

    return Forum(
      fid,
      name,
      type: stid == null ? _parseInt(map['type']) ?? 0 : 1,
      iconId: _parseInt(map['id'] ?? map['iconId']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fid': fid,
      'name': name,
      'type': type,
      if (iconId != null) 'iconId': iconId,
    };
  }

  String getIconUrl() {
    final imageId = iconId ?? fid;
    return "https://img4.nga.178.com/ngabbs/nga_classic/f/app/$imageId.png";
  }
}

class ForumIdentity {
  const ForumIdentity(this.id, this.type);

  final int id;
  final int type;

  String get storageKey => '$type:$id';

  @override
  bool operator ==(Object other) {
    return other is ForumIdentity && other.id == id && other.type == type;
  }

  @override
  int get hashCode => Object.hash(id, type);
}

/// 版块组实体类
class ForumGroup {
  const ForumGroup(this.name, this.forumList);

  final String name;
  final List<Forum> forumList;

  factory ForumGroup.fromJson(Map map) {
    final name = map['name']?.toString();
    final forums = map['forums'];
    if (name == null || forums is! List) {
      throw const FormatException('Invalid forum group data.');
    }
    return ForumGroup(
      name,
      forums.map((forum) => Forum.fromJson(forum as Map)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'forums': forumList.map((forum) => forum.toJson()).toList(),
    };
  }
}

/// 版块分类实体类（首页一级 Tab），包含若干版块组
class ForumCategory {
  const ForumCategory(this.id, this.name, this.groups);

  final String id;
  final String name;
  final List<ForumGroup> groups;

  factory ForumCategory.fromJson(Map map) {
    final id = map['id']?.toString();
    final name = map['name']?.toString();
    final groups = map['groups'];
    if (id == null || name == null || groups is! List) {
      throw const FormatException('Invalid forum category data.');
    }
    return ForumCategory(
      id,
      name,
      groups.map((group) => ForumGroup.fromJson(group as Map)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'groups': groups.map((group) => group.toJson()).toList(),
    };
  }
}

int? _parseInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '');
}

int? _parseNonZeroInt(Object? value) {
  final parsed = _parseInt(value);
  return parsed == null || parsed == 0 ? null : parsed;
}
