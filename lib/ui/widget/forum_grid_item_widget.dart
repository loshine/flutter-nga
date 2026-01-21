import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nga/data/entity/forum.dart';
import 'package:flutter_nga/utils/dimen.dart';
import 'package:flutter_nga/utils/route.dart';

class ForumGridItemWidget extends StatelessWidget {
  final Forum forum;
  final GestureLongPressCallback? onLongPress;

  const ForumGridItemWidget(this.forum, {Key? key, this.onLongPress})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(Dimen.radiusM),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => Routes.navigateTo(
            context,
            "${Routes.FORUM_DETAIL}?fid=${forum.fid}&name=${forum.name}&type=${forum.type}",
          ),
          onLongPress: onLongPress,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 图标容器
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Dimen.radiusS),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: CachedNetworkImage(
                    imageUrl: forum.getIconUrl(),
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Image.asset(
                      'images/default_forum_icon.png',
                      fit: BoxFit.cover,
                    ),
                    errorWidget: (context, url, err) => Image.asset(
                      'images/default_forum_icon.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // 名称
                Text(
                  forum.name,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
