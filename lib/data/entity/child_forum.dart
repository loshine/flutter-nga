import 'package:flutter_nga/data/entity/forum.dart';

class ChildForum extends Forum {
  final int? tid;
  final String? desc;
  final bool selected;
  final int? parentId;
  final int type;

  ChildForum(int fid, String name, this.tid,
      {this.parentId, this.desc, this.type = 0, this.selected = false})
      : super(fid, name, type: type);
}
