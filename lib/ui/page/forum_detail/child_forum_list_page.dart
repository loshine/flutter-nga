import 'package:flutter/material.dart';
import 'package:flutter_nga/data/entity/topic.dart';
import 'package:flutter_nga/utils/dimen.dart';
import 'package:flutter_nga/utils/palette.dart';

import 'child_forum_item_widget.dart';

class ChildForumListPage extends StatefulWidget {
  final ForumInfo forumInfo;

  const ChildForumListPage(this.forumInfo, {Key key}) : super(key: key);

  @override
  _ChildForumListPage createState() => _ChildForumListPage();
}

class _ChildForumListPage extends State<ChildForumListPage> {
  @override
  Widget build(BuildContext context) {
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: widget.forumInfo == null || widget.forumInfo.subForums.isEmpty
          ? Center(
              child: Text(
                "本版暂无子版",
                style: TextStyle(
                  fontSize: Dimen.subheading,
                  color: Palette.colorTextSecondary,
                ),
              ),
            )
          : ListView.builder(
              physics: BouncingScrollPhysics(),
              itemCount: widget.forumInfo == null
                  ? 0
                  : widget.forumInfo.subForums.length,
              itemBuilder: (_, index) =>
                  ChildForumItemWidget(widget.forumInfo.subForums[index]),
            ),
    );
  }
}
