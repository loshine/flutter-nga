import 'package:flutter/material.dart';
import 'package:flutter_nga/data/entity/forum.dart';
import 'package:flutter_nga/ui/forum/forum_grid_item_widget.dart';

class ForumGroupPage extends StatefulWidget {
  ForumGroupPage({Key key, this.group}) : super(key: key);

  final ForumGroup group;

  @override
  _ForumGroupState createState() => _ForumGroupState();
}

class _ForumGroupState extends State<ForumGroupPage> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    /*24 is for notification bar on Android*/
    final double itemHeight = 96;
    final double itemWidth = size.width / 3;

    return GridView.count(
      crossAxisCount: 3,
      childAspectRatio: itemWidth / itemHeight,
      children: widget.group.forumList
          .map((forum) => ForumGridItemWidget(forum))
          .toList(),
    );
  }
}
