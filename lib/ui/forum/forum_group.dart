import 'package:flutter/material.dart';
import 'package:flutter_nga/data/entity/forum.dart';
import 'package:flutter_nga/ui/forum/forum_grid.dart';
import 'package:flutter_nga/utils/palette.dart';

class ForumGroupPage extends StatefulWidget {
  ForumGroupPage({Key key, this.group}) : super(key: key);

  final ForumGroup group;

  @override
  _ForumGroupState createState() => _ForumGroupState();
}

class _ForumGroupState extends State<ForumGroupPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Palette.colorBackground,
      child: ForumGridPage(
        forumList: widget.group.forumList,
      ),
    );
  }
}
