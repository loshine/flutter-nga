import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/data/entity/forum.dart';
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
}
