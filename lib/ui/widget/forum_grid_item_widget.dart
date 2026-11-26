import 'package:cached_network_image/cached_network_image.dart';
import 'package:material_ui/material_ui.dart';

import 'package:flutter_nga/data/entity/forum.dart';
import 'package:flutter_nga/providers/settings/design_style_provider.dart';
import 'package:flutter_nga/utils/dimen.dart';
import 'package:flutter_nga/utils/route.dart';

class ForumGridItemWidget extends StatelessWidget {
  final Forum forum;
  final GestureLongPressCallback? onLongPress;
  final VoidCallback? onTap;
  final GestureTapDownCallback? onSecondaryTapDown;
  final bool? cardStyle;

  const ForumGridItemWidget(
    this.forum, {
    super.key,
    this.onLongPress,
    this.onTap,
    this.onSecondaryTapDown,
    this.cardStyle,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isAppleCard = cardStyle ?? context.isMacDesktopAppleStyle;

    void handleTap() {
      if (onTap != null) {
        onTap!();
        return;
      }
      Routes.navigateToWithParams(context, Routes.FORUM_DETAIL, {
        'fid': '${forum.fid}',
        'name': forum.name,
        'type': '${forum.type}',
      });
    }

    final content = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: isAppleCard ? 42 : 48,
          height: isAppleCard ? 42 : 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              isAppleCard ? 10 : Dimen.radiusL,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: CachedNetworkImage(
            imageUrl: forum.getIconUrl(),
            fit: BoxFit.cover,
            placeholder: (context, url) => Image.asset(
              'images/default_forum_icon.png',
              width: isAppleCard ? 42 : 48,
              height: isAppleCard ? 42 : 48,
            ),
            errorWidget: (context, url, err) => Image.asset(
              'images/default_forum_icon.png',
              width: isAppleCard ? 42 : 48,
              height: isAppleCard ? 42 : 48,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Text(
            forum.name,
            style: (isAppleCard ? textTheme.bodySmall : textTheme.titleSmall)
                ?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: isAppleCard ? FontWeight.w500 : null,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );

    if (isAppleCard) {
      return GestureDetector(
        onSecondaryTapDown: onSecondaryTapDown,
        child: Material(
          color: colorScheme.surfaceContainerLow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: colorScheme.outlineVariant, width: 0.5),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: handleTap,
            onLongPress: onLongPress,
            child: content,
          ),
        ),
      );
    }

    return GestureDetector(
      onSecondaryTapDown: onSecondaryTapDown,
      child: InkWell(
        borderRadius: BorderRadius.circular(Dimen.radiusM),
        onTap: handleTap,
        onLongPress: onLongPress,
        child: content,
      ),
    );
  }
}
