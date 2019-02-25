import 'package:flutter_nga/data/entity/forum.dart';

class FavouriteForumGroupState {
  const FavouriteForumGroupState(this.forumList);

  final List<Forum> forumList;

  factory FavouriteForumGroupState.initial() => FavouriteForumGroupState([]);
}
