import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nga/data/entity/forum.dart';
import 'package:flutter_nga/utils/palette.dart';

class ForumGridPage extends StatefulWidget {
  ForumGridPage({Key key, this.forumList}) : super(key: key);
  final List<Forum> forumList;

  @override
  _ForumGridState createState() => _ForumGridState();
}

class _ForumGridState extends State<ForumGridPage> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    /*24 is for notification bar on Android*/
    final double itemHeight = 96;
    final double itemWidth = size.width / 3;

    return GridView.count(
      crossAxisCount: 3,
      childAspectRatio: itemWidth / itemHeight,
      children: widget.forumList
          .map((forum) => ForumGridItemWidget(forum: forum))
          .toList(),
    );
  }
}

class ForumGridItemWidget extends StatelessWidget {
  final Forum forum;

  ForumGridItemWidget({Key key, this.forum}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: InkWell(
        onTap: () => Scaffold.of(context).showSnackBar(
              SnackBar(content: Text("${forum.name} is taped!")),
            ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CachedNetworkImage(
              width: 48,
              height: 48,
              imageUrl:
                  "http://img4.nga.178.com/ngabbs/nga_classic/f/app/${forum.fid}.png",
              placeholder: Image.asset(
                'images/default_forum_icon.png',
                width: 48,
                height: 48,
              ),
              errorWidget: Image.asset(
                'images/default_forum_icon.png',
                width: 48,
                height: 48,
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
              child: Text(forum.name),
            )
          ],
        ),
      ),
      color: Palette.colorBackground,
    );
  }
}
