import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/data/entity/forum.dart';
import 'package:mobx/mobx.dart';

part 'favourite_forum.g.dart';

class FavouriteForum = _FavouriteForum with _$FavouriteForum;

abstract class _FavouriteForum with Store {
  @observable
  bool isFavourite = false;

  @action
  Future load(int fid, String name) async {
    isFavourite = await Data().forumRepository.isFavourite(Forum(fid, name));
  }

  @action
  Future toggle(int fid, String name) async {
    if (!isFavourite) {
      await Data().forumRepository.deleteFavourite(Forum(fid, name));
    } else {
      await Data().forumRepository.saveFavourite(Forum(fid, name));
    }
  }
}
