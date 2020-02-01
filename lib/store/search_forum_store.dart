import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/data/entity/forum.dart';
import 'package:mobx/mobx.dart';

part 'search_forum_store.g.dart';

class SearchForumStore = _SearchForumStore with _$SearchForumStore;

abstract class _SearchForumStore with Store {
  @observable
  List<Forum> forums = [];

  @action
  Future<List<Forum>> search(String keyword) async {
    List<Forum> results = await Data().forumRepository.getForumByName(keyword);
    forums = results;
    return results;
  }
}
