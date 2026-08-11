import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_nga/data/entity/forum.dart';
import 'package:flutter_nga/providers/core/repository_providers.dart';
import 'package:flutter_nga/utils/app_toast.dart';
import 'package:flutter_nga/utils/error_utils.dart';

class FavouriteForumListState {
  const FavouriteForumListState({
    this.forums = const [],
    this.busyIdentities = const {},
    this.isInitialized = false,
    this.isSyncing = false,
    this.error,
  });

  final List<Forum> forums;
  final Set<ForumIdentity> busyIdentities;
  final bool isInitialized;
  final bool isSyncing;
  final String? error;

  bool isFavourite(ForumIdentity identity) {
    return forums.any((forum) => forum.identity == identity);
  }

  bool isBusy(ForumIdentity identity) {
    return busyIdentities.contains(identity);
  }

  FavouriteForumListState copyWith({
    List<Forum>? forums,
    Set<ForumIdentity>? busyIdentities,
    bool? isInitialized,
    bool? isSyncing,
    String? error,
    bool clearError = false,
  }) {
    return FavouriteForumListState(
      forums: forums ?? this.forums,
      busyIdentities: busyIdentities ?? this.busyIdentities,
      isInitialized: isInitialized ?? this.isInitialized,
      isSyncing: isSyncing ?? this.isSyncing,
      error: clearError ? null : error ?? this.error,
    );
  }
}

class FavouriteForumListNotifier extends Notifier<FavouriteForumListState> {
  int _accountGeneration = 0;

  @override
  FavouriteForumListState build() => const FavouriteForumListState();

  Future<void> ensureLoaded() async {
    if (state.isInitialized || state.isSyncing) return;
    await _refreshQuietly();
  }

  Future<void> refresh() async {
    final generation = _accountGeneration;
    final repository = ref.read(forumRepositoryProvider);
    state = state.copyWith(isSyncing: true, clearError: true);

    try {
      final cachedForums = await repository.getFavouriteList();
      if (generation != _accountGeneration) return;
      state = state.copyWith(
        forums: cachedForums,
        isInitialized: true,
      );

      final syncedForums = await repository.syncFavouriteList();
      if (generation != _accountGeneration) return;
      state = state.copyWith(
        forums: syncedForums,
        isInitialized: true,
        isSyncing: false,
        clearError: true,
      );
    } catch (error) {
      if (generation == _accountGeneration) {
        state = state.copyWith(
          isInitialized: true,
          isSyncing: false,
          error: errorMessage(error),
        );
      }
      rethrow;
    }
  }

  Future<bool> add(
    int fid,
    String name, {
    int type = 0,
    int? iconId,
  }) async {
    final generation = _accountGeneration;
    final forum = Forum(fid, name, type: type, iconId: iconId);
    final repository = ref.read(forumRepositoryProvider);
    if (await repository.isFavourite(forum)) {
      AppToast.warning('您已添加过该版面');
      return false;
    }

    await _saveLocalAndScheduleSync(forum, generation);
    return true;
  }

  Future<void> delete(Forum forum) async {
    if (state.isBusy(forum.identity)) return;
    final generation = _accountGeneration;
    _setBusy(forum.identity, true);
    try {
      await ref.read(forumRepositoryProvider).deleteFavourite(forum);
      await _reloadCachedForums(generation);
    } catch (error) {
      if (generation == _accountGeneration) {
        state = state.copyWith(error: errorMessage(error));
      }
      rethrow;
    } finally {
      if (generation == _accountGeneration) {
        _setBusy(forum.identity, false);
      }
    }
  }

  Future<void> toggle(Forum forum) async {
    if (state.isBusy(forum.identity)) return;
    final generation = _accountGeneration;
    if (state.isFavourite(forum.identity)) {
      await delete(forum);
      return;
    }

    _setBusy(forum.identity, true);
    try {
      await _saveLocalAndScheduleSync(forum, generation);
    } catch (error) {
      if (generation == _accountGeneration) {
        state = state.copyWith(error: errorMessage(error));
      }
      rethrow;
    } finally {
      if (generation == _accountGeneration) {
        _setBusy(forum.identity, false);
      }
    }
  }

  void onAccountChanged() {
    _accountGeneration++;
    state = const FavouriteForumListState();
    unawaited(_refreshQuietly());
  }

  void retryOnAppResume() {
    if (state.isSyncing) return;
    unawaited(_refreshQuietly());
  }

  Future<void> _saveLocalAndScheduleSync(
    Forum forum,
    int generation,
  ) async {
    await ref.read(forumRepositoryProvider).saveFavourite(forum);
    if (generation != _accountGeneration) return;
    await _reloadCachedForums(generation);
    unawaited(_syncAfterLocalAdd(generation));
  }

  Future<void> _syncAfterLocalAdd(int generation) async {
    state = state.copyWith(isSyncing: true, clearError: true);
    try {
      final forums =
          await ref.read(forumRepositoryProvider).syncFavouriteList();
      if (generation != _accountGeneration) return;
      state = state.copyWith(
        forums: forums,
        isSyncing: false,
        clearError: true,
      );
    } catch (error) {
      if (generation != _accountGeneration) return;
      state = state.copyWith(
        isSyncing: false,
        error: errorMessage(error),
      );
      AppToast.warning('已保存到本地，将稍后同步');
    }
  }

  Future<void> _reloadCachedForums(int generation) async {
    final forums = await ref.read(forumRepositoryProvider).getFavouriteList();
    if (generation != _accountGeneration) return;
    state = state.copyWith(
      forums: forums,
      isInitialized: true,
      clearError: true,
    );
  }

  Future<void> _refreshQuietly() async {
    try {
      await refresh();
    } catch (_) {
      // 缓存仍可使用，错误信息已经保存在 state 中。
    }
  }

  void _setBusy(ForumIdentity identity, bool busy) {
    final identities = {...state.busyIdentities};
    if (busy) {
      identities.add(identity);
    } else {
      identities.remove(identity);
    }
    state = state.copyWith(busyIdentities: identities);
  }
}

final favouriteForumListProvider =
    NotifierProvider<FavouriteForumListNotifier, FavouriteForumListState>(
  FavouriteForumListNotifier.new,
);
