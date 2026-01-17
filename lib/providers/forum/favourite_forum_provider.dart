import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/data/entity/forum.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FavouriteForumNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  Future<void> load(int fid, String? name) async {
    state = await Data()
        .forumRepository
        .isFavourite(Forum(fid, name ?? "", type: 0));
  }

  Future<void> toggle(int fid, String? name, int? type) async {
    if (state) {
      await Data()
          .forumRepository
          .deleteFavourite(Forum(fid, name ?? "", type: type ?? 0));
    } else {
      await Data()
          .forumRepository
          .saveFavourite(Forum(fid, name ?? "", type: type ?? 0));
    }
    state = !state;
  }
}

final favouriteForumProvider =
    NotifierProvider<FavouriteForumNotifier, bool>(FavouriteForumNotifier.new);
