import 'package:flutter/material.dart';
import 'package:flutter_nga/providers/forum/favourite_forum_list_provider.dart';
import 'package:flutter_nga/providers/forum/favourite_forum_provider.dart';
import 'package:flutter_nga/utils/app_toast.dart';
import 'package:flutter_nga/utils/hooks/easy_refresh_hooks.dart';
import 'package:flutter_nga/utils/motion.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ForumFavouriteButtonWidget extends HookConsumerWidget {
  const ForumFavouriteButtonWidget(
      {super.key, this.name, required this.fid, this.type});

  final String? name;
  final int fid;
  final int? type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    usePostFrameEffect(() {
      ref.read(favouriteForumProvider.notifier).load(fid, name ?? "");
    }, [fid, name]);

    final isFavourite = ref.watch(favouriteForumProvider);
    final notifier = ref.read(favouriteForumProvider.notifier);

    return IconButton(
      icon: AnimatedSwitcher(
        duration: Motion.durationShort4,
        switchInCurve: Motion.emphasizedDecelerate,
        switchOutCurve: Motion.emphasizedAccelerate,
        transitionBuilder: (child, animation) => ScaleTransition(
          scale: animation,
          child: FadeTransition(opacity: animation, child: child),
        ),
        child: Icon(
          isFavourite ? Icons.star : Icons.star_border,
          key: ValueKey(isFavourite),
        ),
      ),
      onPressed: () {
        notifier.toggle(fid, name, type).then((_) {
          ref.read(favouriteForumListProvider.notifier).refresh();
        }).catchError((err) {
          AppToast.error(err.message);
        });
      },
    );
  }
}
