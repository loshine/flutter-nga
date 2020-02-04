import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nga/data/entity/child_forum.dart';

class ChildForumItemWidget extends StatefulWidget {
  final ChildForum childForum;

  const ChildForumItemWidget(this.childForum, {Key key}) : super(key: key);

  @override
  _ChildForumItemState createState() => _ChildForumItemState();
}

class _ChildForumItemState extends State<ChildForumItemWidget> {
  bool _selected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: CachedNetworkImage(
            width: 48,
            height: 48,
            imageUrl: widget.childForum.getIconUrl(),
            placeholder: (context, url) => Image.asset(
              'images/default_forum_icon.png',
              width: 48,
              height: 48,
            ),
          ),
          title: Text(widget.childForum.name),
          subtitle: Text(widget.childForum.desc ?? ""),
          trailing: Switch(
            value: _selected ?? widget.childForum.selected,
            onChanged: (v) {
              setState(() {
                _selected = v;
              });
            },
          ),
        ),
        Divider(height: 1),
      ],
    );
  }
}
