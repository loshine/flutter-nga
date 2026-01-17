import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nga/data/entity/child_forum.dart';
import 'package:flutter_nga/providers/forum/child_forum_subscription_provider.dart';
import 'package:flutter_nga/utils/code_utils.dart';
import 'package:flutter_nga/utils/route.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ChildForumItemWidget extends ConsumerStatefulWidget {
  final ChildForum childForum;

  const ChildForumItemWidget(this.childForum, {Key? key}) : super(key: key);

  @override
  ConsumerState<ChildForumItemWidget> createState() =>
      _ChildForumItemState();
}

class _ChildForumItemState extends ConsumerState<ChildForumItemWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(childForumSubscriptionProvider.notifier)
          .setSubscribed(widget.childForum.selected);
    });
  }

  @override
  Widget build(BuildContext context) {
    final subscribed = ref.watch(childForumSubscriptionProvider);
    final notifier = ref.read(childForumSubscriptionProvider.notifier);

    return InkWell(
      onTap: () => Routes.navigateTo(
        context,
        "${Routes.FORUM_DETAIL}?fid=${widget.childForum.fid}"
        "&name=${widget.childForum.name}"
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
                ? Switch(
                    value: subscribed,
                    onChanged: (v) {
                      if (v) {
                        notifier.addSubscription(
                            widget.childForum.tid!, widget.childForum.parentId);
                      } else {
                        notifier.deleteSubscription(
                            widget.childForum.tid!, widget.childForum.parentId);
                      }
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
