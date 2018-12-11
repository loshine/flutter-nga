import 'package:flutter/material.dart';
import 'package:flutter_nga/data/entity/forum.dart';
import 'package:flutter_nga/utils/palette.dart';

class ForumGroupPage extends StatefulWidget {
  ForumGroupPage({Key key, this.group}) : super(key: key);

  final ForumGroup group;

  @override
  ForumGroupState createState() => ForumGroupState();
}

class ForumGroupState extends State<ForumGroupPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Palette.colorBackground,
      child: Center(
        child: Text(widget.group.name),
      ),
    );
  }
}
