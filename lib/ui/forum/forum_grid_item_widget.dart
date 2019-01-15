import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nga/data/entity/forum.dart';
import 'package:flutter_nga/ui/topic/topic_list.dart';

class ForumGridItemWidget extends StatefulWidget {
  final Forum forum;
  final OnFavouriteChangedCallback onFavouriteChanged;

  ForumGridItemWidget(this.forum, {Key key, this.onFavouriteChanged})
      : super(key: key);

  @override
  _ForumGridItemState createState() => _ForumGridItemState();
}

class _ForumGridItemState extends State<ForumGridItemWidget> {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (_) {
            return TopicListPage(widget.forum);
          })).then((changed) {
            if (widget.onFavouriteChanged != null) {
              widget.onFavouriteChanged(changed);
            }
          });
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CachedNetworkImage(
              width: 48,
              height: 48,
              imageUrl:
                  "http://img4.nga.178.com/ngabbs/nga_classic/f/app/${widget.forum.fid}.png",
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
              child: Text(
                widget.forum.name,
                overflow: TextOverflow.ellipsis,
              ),
            )
          ],
        ),
      ),
    );
  }
}

typedef OnFavouriteChangedCallback = void Function(bool);
