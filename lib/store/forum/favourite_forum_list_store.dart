import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/data/entity/forum.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mobx/mobx.dart';

part 'favourite_forum_list_store.g.dart';

class FavouriteForumListStore = _FavouriteForumListStore
    with _$FavouriteForumListStore;

abstract class _FavouriteForumListStore with Store {
  @observable
  List<Forum> list = [];

  @action
  void refresh() {
    Data().forumRepository.getFavouriteList().then((list) {
      this.list = list;
    });
  }

  @action
  Future<void> add(int fid, String name) async {
    final isFavourite =
        await Data().forumRepository.isFavourite(Forum(fid, name));
    if (isFavourite) {
      Fluttertoast.showToast(msg: "您已添加过该版面");
    } else {
      await Data().forumRepository.saveFavourite(Forum(fid, name));
      refresh();
    }
  }

  @action
  Future<void> delete(int fid) async {
    await Data().forumRepository.deleteFavourite(Forum(fid, ""));
    refresh();
  }
}
