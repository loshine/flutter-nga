import 'package:flutter/material.dart';
import 'package:flutter_nga/providers/forum/favourite_forum_list_provider.dart';
import 'package:flutter_nga/ui/widget/forum_grid_item_widget.dart';
import 'package:flutter_nga/utils/route.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class FavouriteForumGroupPage extends ConsumerStatefulWidget {
  @override
  ConsumerState<FavouriteForumGroupPage> createState() =>
      _FavouriteForumGroupState();
}

class _FavouriteForumGroupState extends ConsumerState<FavouriteForumGroupPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(favouriteForumListProvider.notifier).refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final forums = ref.watch(favouriteForumListProvider);
    final notifier = ref.read(favouriteForumListProvider.notifier);
    final size = MediaQuery.of(context).size;

    /*24 is for notification bar on Android*/
    final double itemHeight = 96;
    final double itemWidth = size.width / 3;

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: itemWidth / itemHeight,
      ),
      itemCount: forums.length,
      itemBuilder: (_, index) => ForumGridItemWidget(
        forums[index],
        onLongPress: () => _showDeleteDialog(notifier, forums[index].fid),
      ),
    );
  }

  @override
  void deactivate() {
    ref.read(favouriteForumListProvider.notifier).refresh();
    super.deactivate();
  }

  void _showDeleteDialog(FavouriteForumListNotifier notifier, int fid) {
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: Text("提示"),
            content: Text("是否删除该版面"),
            actions: <Widget>[
              TextButton(
                onPressed: () => Routes.pop(context),
                child: Text("取消"),
              ),
              TextButton(
                onPressed: () {
                  notifier.delete(fid).whenComplete(() => Routes.pop(context));
                },
                child: Text("确认"),
              ),
            ],
          );
        });
  }
}
