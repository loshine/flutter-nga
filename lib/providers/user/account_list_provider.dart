import 'package:flutter_nga/data/entity/user.dart';
import 'package:flutter_nga/providers/core/repository_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  Future<int> quitAll() {
    final repository = ref.read(userRepositoryProvider);
    return repository.quitAllLoginUser();
  }

  Future<bool> setDefault(CacheUser cacheUser) {
    final repository = ref.read(userRepositoryProvider);
    return repository.setDefault(cacheUser);
  }

  Future<bool> delete(CacheUser cacheUser) {
    final repository = ref.read(userRepositoryProvider);
    return repository.deleteCacheUser(cacheUser);
  }
}

final accountListProvider =
    NotifierProvider<AccountListNotifier, AccountListState>(AccountListNotifier.new);
