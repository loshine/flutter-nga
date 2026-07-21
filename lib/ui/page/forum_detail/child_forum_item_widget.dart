import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nga/data/entity/child_forum.dart';
import 'package:flutter_nga/providers/forum/child_forum_subscription_provider.dart';
import 'package:flutter_nga/utils/hooks/easy_refresh_hooks.dart';
import 'package:flutter_nga/utils/route.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ChildForumItemWidget extends HookConsumerWidget {
  final ChildForum childForum;

  const ChildForumItemWidget(this.childForum, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    usePostFrameEffect(() {
      ref
          .read(childForumSubscriptionProvider.notifier)
          .setSubscribed(childForum.selected);
    }, [childForum.selected]);

    final subscribed = ref.watch(childForumSubscriptionProvider);
    final notifier = ref.read(childForumSubscriptionProvider.notifier);

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
            trailing: childForum.tid != null
                ? Switch(
                    value: subscribed,
                    onChanged: (v) {
                      if (v) {
                        notifier.addSubscription(
                            childForum.tid!, childForum.parentId);
                      } else {
                        notifier.deleteSubscription(
                            childForum.tid!, childForum.parentId);
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
