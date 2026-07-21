import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nga/data/entity/child_forum.dart';
import 'package:flutter_nga/providers/forum/child_forum_subscription_provider.dart';
import 'package:flutter_nga/utils/route.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ChildForumItemWidget extends ConsumerWidget {
  final ChildForum childForum;

  const ChildForumItemWidget(this.childForum, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tid = childForum.tid;
    final subscriptionKey = tid == null
        ? null
        : ChildForumSubscriptionKey(
            tid,
            initialSelected: childForum.selected,
          );
    final subscribed = subscriptionKey == null
        ? false
        : ref.watch(childForumSubscriptionProvider(subscriptionKey));
    final notifier = subscriptionKey == null
        ? null
        : ref.read(childForumSubscriptionProvider(subscriptionKey).notifier);

    return InkWell(
      onTap: () => Routes.navigateTo(
        context,
        "${Routes.FORUM_DETAIL}?fid=${childForum.fid}"
        "&name=${childForum.name}"
        "&type=${childForum.type}",
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CachedNetworkImage(
              width: 48,
              height: 48,
              imageUrl: childForum.getIconUrl(),
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
            title: Text(childForum.name),
            subtitle: Text(childForum.desc ?? ""),
            trailing: tid != null && notifier != null
                ? Switch(
                    value: subscribed,
                    onChanged: (v) {
                      if (v) {
                        notifier.addSubscription(childForum.parentId);
                      } else {
                        notifier.deleteSubscription(childForum.parentId);
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
