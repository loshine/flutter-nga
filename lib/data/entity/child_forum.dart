import 'package:flutter_nga/data/entity/forum.dart';

class ChildForum extends Forum {
  final String desc;
  final bool selected;
  final int parentId;

  ChildForum(int fid, String name,
      {this.parentId, this.desc, this.selected = false})
      : super(fid, name);
}
