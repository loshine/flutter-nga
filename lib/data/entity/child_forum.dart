import 'package:flutter_nga/data/entity/forum.dart';

class ChildForum extends Forum {
  final String desc;
  final bool selected;

  ChildForum(int fid, String name, {this.desc, this.selected = false})
      : super(fid, name);
}
