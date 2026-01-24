import 'package:flutter/material.dart';
import 'package:flutter_nga/providers/forum/favourite_forum_list_provider.dart';
import 'package:flutter_nga/providers/forum/favourite_forum_provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ForumFavouriteButtonWidget extends ConsumerStatefulWidget {
  const ForumFavouriteButtonWidget(
      {super.key, this.name, required this.fid, this.type});

  final String? name;
  final int fid;
  final int? type;

  @override
  ConsumerState<ForumFavouriteButtonWidget> createState() =>
      _ForumFavouriteButtonState();
}

class _ForumFavouriteButtonState
    extends ConsumerState<ForumFavouriteButtonWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(favouriteForumProvider.notifier)
          .load(widget.fid, widget.name ?? "");
    });
  }

  @override
  Widget build(BuildContext context) {
    final isFavourite = ref.watch(favouriteForumProvider);
    final notifier = ref.read(favouriteForumProvider.notifier);

    return IconButton(
      icon: Icon(
        isFavourite ? Icons.star : Icons.star_border,
      ),
      onPressed: () {
        notifier.toggle(widget.fid, widget.name, widget.type).then((_) {
          ref.read(favouriteForumListProvider.notifier).refresh();
        }).catchError((err) {
          Fluttertoast.showToast(msg: err.message);
        });
      },
    );
  }
}
