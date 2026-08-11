import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_nga/data/entity/forum.dart';
import 'package:flutter_nga/providers/forum/favourite_forum_list_provider.dart';

final favouriteForumProvider = Provider.family<bool, ForumIdentity>(
  (ref, identity) => ref.watch(
    favouriteForumListProvider.select(
      (state) => state.isFavourite(identity),
    ),
  ),
);

final favouriteForumBusyProvider = Provider.family<bool, ForumIdentity>(
  (ref, identity) => ref.watch(
    favouriteForumListProvider.select(
      (state) => state.isBusy(identity),
    ),
  ),
);
