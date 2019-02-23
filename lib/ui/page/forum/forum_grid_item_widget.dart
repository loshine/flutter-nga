import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nga/data/entity/forum.dart';
import 'package:flutter_nga/ui/page/topic/topic_list.dart';

class ForumGridItemWidget extends StatefulWidget {
  final Forum forum;
  final OnFavouriteChangedCallback onFavouriteChanged;

  const ForumGridItemWidget(this.forum, {Key key, this.onFavouriteChanged})
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
            return TopicListPage(
              fid: widget.forum.fid,
              name: widget.forum.name,
            );
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
              placeholder: (context, url) => Image.asset(
                    'images/default_forum_icon.png',
                    width: 48,
                    height: 48,
                  ),
              errorWidget: (context, url, e) => Image.asset(
                    'images/default_forum_icon.png',
                    width: 48,
                    height: 48,
                  ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 8),
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
