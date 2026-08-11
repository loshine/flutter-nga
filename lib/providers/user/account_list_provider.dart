import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_nga/data/entity/user.dart';
import 'package:flutter_nga/providers/core/repository_providers.dart';
import 'package:flutter_nga/providers/forum/favourite_forum_list_provider.dart';

class AccountListState {
  final List<CacheUser> list;

  const AccountListState({
    this.list = const [],
  });

  AccountListState copyWith({
    List<CacheUser>? list,
  }) {
    return AccountListState(
      list: list ?? this.list,
    );
  }
}

class AccountListNotifier extends Notifier<AccountListState> {
  @override
  AccountListState build() => const AccountListState();

  Future<void> refresh() async {
    final repository = ref.read(userRepositoryProvider);
    List<CacheUser> accountList = await repository.getAllLoginUser();
    state = state.copyWith(list: accountList);
  }

  Future<int> quitAll() async {
    final repository = ref.read(userRepositoryProvider);
    final result = await repository.quitAllLoginUser();
    ref.read(favouriteForumListProvider.notifier).onAccountChanged();
    return result;
  }

  Future<bool> setDefault(CacheUser cacheUser) async {
    final repository = ref.read(userRepositoryProvider);
    final result = await repository.setDefault(cacheUser);
    if (result) {
      ref.read(favouriteForumListProvider.notifier).onAccountChanged();
    }
    return result;
  }

  Future<bool> delete(CacheUser cacheUser) async {
    final repository = ref.read(userRepositoryProvider);
    final result = await repository.deleteCacheUser(cacheUser);
    if (result) {
      ref.read(favouriteForumListProvider.notifier).onAccountChanged();
    }
    return result;
  }
}

final accountListProvider =
    NotifierProvider<AccountListNotifier, AccountListState>(
        AccountListNotifier.new);
