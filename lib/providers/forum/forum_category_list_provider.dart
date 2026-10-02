import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_nga/data/entity/forum.dart';
import 'package:flutter_nga/providers/core/repository_providers.dart';
import 'package:flutter_nga/utils/error_utils.dart';

class ForumCategoryListState {
  const ForumCategoryListState({
    this.categories = const [],
    this.isInitialized = false,
    this.isLoading = false,
    this.error,
  });

  final List<ForumCategory> categories;
  final bool isInitialized;
  final bool isLoading;
  final String? error;

  ForumCategoryListState copyWith({
    List<ForumCategory>? categories,
    bool? isInitialized,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return ForumCategoryListState(
      categories: categories ?? this.categories,
      isInitialized: isInitialized ?? this.isInitialized,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
    );
  }
}

/// 版块分类：离线优先，先展示本地缓存，再静默刷新远端数据
class ForumCategoryListNotifier extends Notifier<ForumCategoryListState> {
  @override
  ForumCategoryListState build() => const ForumCategoryListState();

  Future<void> ensureLoaded() async {
    if (state.isInitialized || state.isLoading) return;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final cached =
          await ref.read(forumRepositoryProvider).getCachedForumCategories();
      if (cached != null && cached.isNotEmpty) {
        state = state.copyWith(categories: cached, isInitialized: true);
      }
    } catch (_) {
      // 缓存损坏时直接走远端，成功后会覆盖缓存。
    }
    try {
      await refresh();
    } catch (_) {
      // 有缓存时继续展示缓存，错误信息已经保存在 state 中。
    }
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final categories =
          await ref.read(forumRepositoryProvider).fetchForumCategories();
      state = state.copyWith(
        categories: categories,
        isInitialized: true,
        isLoading: false,
      );
    } catch (error) {
      state = state.copyWith(
        isInitialized: true,
        isLoading: false,
        error: errorMessage(error),
      );
      rethrow;
    }
  }
}

final forumCategoryListProvider =
    NotifierProvider<ForumCategoryListNotifier, ForumCategoryListState>(
  ForumCategoryListNotifier.new,
);
