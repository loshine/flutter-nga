import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/data/entity/forum.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchForumNotifier extends StateNotifier<List<Forum>> {
  SearchForumNotifier() : super([]);

  Future<List<Forum>> search(String keyword) async {
    List<Forum> results = await Data().forumRepository.getForumByName(keyword);
    state = results;
    return results;
  }
}

final searchForumProvider =
    StateNotifierProvider<SearchForumNotifier, List<Forum>>((ref) {
  return SearchForumNotifier();
});
