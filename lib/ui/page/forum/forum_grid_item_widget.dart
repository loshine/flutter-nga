import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nga/data/entity/forum.dart';
import 'package:flutter_nga/ui/page/topic_list/topic_list_page.dart';

class ForumGridItemWidget extends StatelessWidget {
  final Forum forum;

  const ForumGridItemWidget(this.forum, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (_) {
            return TopicListPage(
              fid: forum.fid,
              name: forum.name,
            );
          }));
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CachedNetworkImage(
              width: 48,
              height: 48,
              imageUrl: forum.getIconUrl(),
              placeholder: (context, url) => Image.asset(
                    'images/default_forum_icon.png',
                    width: 48,
                    height: 48,
                  ),
              errorWidget: (context, url, err) => Image.asset(
                    'images/default_forum_icon.png',
                    width: 48,
                    height: 48,
                  ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                forum.name,
                overflow: TextOverflow.ellipsis,
              ),
            )
          ],
        ),
      ),
    );
  }
}
