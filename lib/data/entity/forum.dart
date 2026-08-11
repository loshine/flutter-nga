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
