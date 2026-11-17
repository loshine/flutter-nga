import 'package:flutter_nga/data/entity/forum.dart';

class ChildForum extends Forum {
  final int? tid;
  final String? desc;
  final bool selected;
  final int? parentId;

  ChildForum(
    super.fid,
    super.name,
    this.tid, {
    this.parentId,
    this.desc,
    super.type = 0,
    this.selected = false,
  });
}
