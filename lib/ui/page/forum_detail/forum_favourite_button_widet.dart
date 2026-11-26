import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:flutter_nga/data/entity/forum.dart';
import 'package:flutter_nga/providers/forum/favourite_forum_list_provider.dart';
import 'package:flutter_nga/providers/forum/favourite_forum_provider.dart';
import 'package:flutter_nga/ui/widget/adaptive/app_icons.dart';
import 'package:flutter_nga/utils/app_toast.dart';
import 'package:flutter_nga/utils/haptics.dart';
import 'package:flutter_nga/utils/hooks/easy_refresh_hooks.dart';
import 'package:flutter_nga/utils/motion.dart';

class ForumFavouriteButtonWidget extends HookConsumerWidget {
  const ForumFavouriteButtonWidget({
    super.key,
    this.name,
    required this.fid,
    this.type,
  });

  final String? name;
  final int fid;
  final int? type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final forum = Forum(fid, name ?? '', type: type ?? 0);
    usePostFrameEffect(() {
      ref.read(favouriteForumListProvider.notifier).ensureLoaded();
    }, [fid, name, type]);

    final isFavourite = ref.watch(favouriteForumProvider(forum.identity));
    final isBusy = ref.watch(favouriteForumBusyProvider(forum.identity));
    final notifier = ref.read(favouriteForumListProvider.notifier);

    return IconButton(
      tooltip: isFavourite ? '取消收藏版块' : '收藏版块',
      isSelected: isFavourite,
      icon: AnimatedSwitcher(
        duration: Motion.resolveDuration(context, Motion.durationShort4),
        switchInCurve: Motion.emphasizedDecelerate,
        switchOutCurve: Motion.emphasizedAccelerate,
        transitionBuilder: (child, animation) => ScaleTransition(
          scale: animation,
          child: FadeTransition(opacity: animation, child: child),
        ),
        child: Icon(
          AppIcons.star(context, filled: isFavourite),
          key: ValueKey(isFavourite),
          color: isFavourite ? Theme.of(context).colorScheme.primary : null,
        ),
      ),
      onPressed: isBusy
          ? null
          : () async {
              try {
                await notifier.toggle(forum);
                AppHaptics.selectionChanged();
              } catch (error) {
                AppToast.error(error);
              }
            },
    );
  }
}
