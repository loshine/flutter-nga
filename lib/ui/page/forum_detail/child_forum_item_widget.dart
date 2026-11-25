import 'package:cached_network_image/cached_network_image.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_nga/data/entity/child_forum.dart';
import 'package:flutter_nga/providers/forum/child_forum_subscription_provider.dart';
import 'package:flutter_nga/providers/settings/design_style_provider.dart';
import 'package:flutter_nga/ui/widget/adaptive/adaptive_controls.dart';
import 'package:flutter_nga/utils/route.dart';

class ChildForumItemWidget extends ConsumerWidget {
  final ChildForum childForum;

  const ChildForumItemWidget(this.childForum, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tid = childForum.tid;
    final subscriptionKey = tid == null
        ? null
        : ChildForumSubscriptionKey(tid, initialSelected: childForum.selected);
    final subscribed = subscriptionKey == null
        ? false
        : ref.watch(childForumSubscriptionProvider(subscriptionKey));
    final notifier = subscriptionKey == null
        ? null
        : ref.read(childForumSubscriptionProvider(subscriptionKey).notifier);
    final isApple = context.isAppleStyle;
    final desc = childForum.desc?.trim();

    return InkWell(
      onTap: () => Routes.navigateToWithParams(context, Routes.FORUM_DETAIL, {
        'fid': '${childForum.fid}',
        'name': childForum.name,
        'type': '${childForum.type}',
      }),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                width: 48,
                height: 48,
                fit: BoxFit.cover,
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
            ),
            title: Text(
              childForum.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: desc != null && desc.isNotEmpty
                ? Text(desc, maxLines: 1, overflow: TextOverflow.ellipsis)
                : null,
            trailing: tid != null && notifier != null
                ? AppSwitch(
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
          Divider(
            height: isApple ? 0.5 : 1,
            thickness: isApple ? 0.5 : null,
            color: isApple
                ? Theme.of(context).colorScheme.outlineVariant
                : null,
          ),
        ],
      ),
    );
  }
}
