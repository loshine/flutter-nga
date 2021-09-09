import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_nga/data/entity/child_forum.dart';
import 'package:flutter_nga/store/forum/child_forum_subscription_store.dart';
import 'package:flutter_nga/utils/code_utils.dart';
import 'package:flutter_nga/utils/route.dart';

class ChildForumItemWidget extends StatefulWidget {
  final ChildForum childForum;

  const ChildForumItemWidget(this.childForum, {Key? key}) : super(key: key);

  @override
  _ChildForumItemState createState() => _ChildForumItemState();
}

class _ChildForumItemState extends State<ChildForumItemWidget> {
  final _store = ChildForumSubscriptionStore();

  @override
  void initState() {
    super.initState();
    _store.setSubscribed(widget.childForum.selected);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Routes.navigateTo(
        context,
        "${Routes.FORUM_DETAIL}?fid=${widget.childForum.fid}"
        "&name=${fluroCnParamsEncode(widget.childForum.name)}"
        "&type=${widget.childForum.type}",
      ),
      child: Column(
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
              errorWidget: (context, url, err) => Image.asset(
                'images/default_forum_icon.png',
                width: 48,
                height: 48,
              ),
            ),
            title: Text(widget.childForum.name),
            subtitle: Text(widget.childForum.desc ?? ""),
            trailing: widget.childForum.tid != null
                ? Observer(
                    builder: (_) {
                      return Switch(
                        value: _store.subscribed,
                        onChanged: (v) {
                          if (v) {
                            _store.addSubscription(widget.childForum.tid!,
                                widget.childForum.parentId);
                          } else {
                            _store.deleteSubscription(widget.childForum.tid!,
                                widget.childForum.parentId);
                          }
                        },
                      );
                    },
                  )
                : null,
          ),
          Divider(height: 1),
        ],
      ),
    );
  }
}
