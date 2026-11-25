import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_nga/data/entity/user.dart';
import 'package:flutter_nga/providers/core/repository_providers.dart';
import 'package:flutter_nga/providers/forum/favourite_forum_list_provider.dart';
import 'package:flutter_nga/providers/home/home_drawer_header_provider.dart';
import 'package:flutter_nga/providers/message/conversation_list_provider.dart';
import 'package:flutter_nga/providers/notification/notification_list_provider.dart';
import 'package:flutter_nga/providers/notification/unread_count_provider.dart';
import 'package:flutter_nga/providers/topic/favourite_topic_list_provider.dart';

class AccountListState {
  final List<CacheUser> list;

  const AccountListState({this.list = const []});

  AccountListState copyWith({List<CacheUser>? list}) {
    return AccountListState(list: list ?? this.list);
  }
}

class AccountListNotifier extends Notifier<AccountListState> {
  @override
  AccountListState build() => const AccountListState();

  /// 统一广播默认账号变化（登录、切换、删除或全部退出后调用），由应用级 Provider
  /// 完成页头清空与未读刷新，避免依赖即将关闭的登录页生命周期。
  void notifyAccountChanged() {
    ref.read(accountSessionVersionProvider.notifier).bump();
    ref.read(unreadCountProvider.notifier).clear();
    ref.read(homeDrawerHeaderProvider.notifier).clear();
    ref.read(favouriteForumListProvider.notifier).onAccountChanged();
    ref.invalidate(conversationListProvider);
    ref.invalidate(notificationListProvider);
    ref.invalidate(favouriteTopicListProvider);
    unawaited(
      ref
          .read(homeDrawerHeaderProvider.notifier)
          .refresh()
          .then((_) {
            if (ref.mounted) {
              return ref.read(unreadCountProvider.notifier).refresh();
            }
          })
          .catchError((_) {}),
    );
  }

  Future<void> refresh() async {
    final repository = ref.read(userRepositoryProvider);
    List<CacheUser> accountList = await repository.getAllLoginUser();
    state = state.copyWith(list: accountList);
  }

  Future<int> quitAll() async {
    final repository = ref.read(userRepositoryProvider);
    final result = await repository.quitAllLoginUser();
    notifyAccountChanged();
    return result;
  }

  Future<bool> setDefault(CacheUser cacheUser) async {
    final repository = ref.read(userRepositoryProvider);
    final result = await repository.setDefault(cacheUser);
    if (result) {
      notifyAccountChanged();
    }
    return result;
  }

  Future<bool> delete(CacheUser cacheUser) async {
    final repository = ref.read(userRepositoryProvider);
    final result = await repository.deleteCacheUser(cacheUser);
    if (result) {
      notifyAccountChanged();
    }
    return result;
  }
}

final accountListProvider =
    NotifierProvider<AccountListNotifier, AccountListState>(
      AccountListNotifier.new,
    );
