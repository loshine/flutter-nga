import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/data/entity/forum.dart';
import 'package:mobx/mobx.dart';

part 'favourite_forum_list.g.dart';

class FavouriteForumList = _FavouriteForumList with _$FavouriteForumList;

abstract class _FavouriteForumList with Store {
  @observable
  List<Forum> list = [];

  @action
  void refresh() {
    Data().forumRepository.getFavouriteList().then((list) {
      this.list = list;
    });
  }
}
