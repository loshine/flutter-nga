import 'package:flutter/material.dart';
import 'package:flutter_nga/data/entity/forum.dart';

class ForumListPage extends StatefulWidget {
  ForumListPage({Key key, this.forumList}) : super(key: key);
  final List<Forum> forumList;

  @override
  _ForumListState createState() => _ForumListState();
}

class _ForumListState extends State<ForumListPage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[],
    );
  }
}
