import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/data/entity/forum.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_nga/utils/app_toast.dart';

class FavouriteForumListNotifier extends Notifier<List<Forum>> {
  @override
  List<Forum> build() => [];

  void refresh() {
    Data().forumRepository.getFavouriteList().then((list) {
      state = list;
    });
  }

  Future<void> add(int fid, String name) async {
    final isFavourite =
        await Data().forumRepository.isFavourite(Forum(fid, name));
    if (isFavourite) {
      AppToast.warning("您已添加过该版面");
    } else {
      await Data().forumRepository.saveFavourite(Forum(fid, name));
      refresh();
    }
  }

  Future<void> delete(int fid) async {
    await Data().forumRepository.deleteFavourite(Forum(fid, ""));
    refresh();
  }
}

final favouriteForumListProvider =
    NotifierProvider<FavouriteForumListNotifier, List<Forum>>(
        FavouriteForumListNotifier.new);
