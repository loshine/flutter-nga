import 'package:flutter/foundation.dart';
import 'package:flutter_nga/data/entity/topic.dart';
import 'package:flutter_nga/providers/core/repository_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FavouriteTopicListState {
  final int size;
  final int page;
  final int maxPage;
  final bool enablePullUp;
  final List<Topic> list;
  final bool isLoading;

  const FavouriteTopicListState({
    this.size = 35,
    this.page = 1,
    this.maxPage = 1,
    this.enablePullUp = false,
    this.list = const [],
    this.isLoading = false,
  });

  FavouriteTopicListState copyWith({
    int? size,
    int? page,
    int? maxPage,
    bool? enablePullUp,
    List<Topic>? list,
    bool? isLoading,
  }) {
    return FavouriteTopicListState(
      size: size ?? this.size,
      page: page ?? this.page,
      maxPage: maxPage ?? this.maxPage,
      enablePullUp: enablePullUp ?? this.enablePullUp,
      list: list ?? this.list,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  factory FavouriteTopicListState.initial() => const FavouriteTopicListState();
}

/// 已从列表移除、等待提交到服务端的收藏删除（`index` 为移除前位置，撤销或失败时按原位插回）
typedef _PendingDeletion = ({Topic topic, int index});

class FavouriteTopicListNotifier extends Notifier<FavouriteTopicListState> {
  /// tid → 待提交的删除。删除先只改本地列表，撤销窗口结束后再调接口，
  /// 这样撤销能真正恢复原状（重新收藏会改变排序和所在收藏夹）。
  final _pending = <int, _PendingDeletion>{};

  /// 已发出、尚未返回的删除请求。刷新前必须等它们完成，否则服务端还没删掉，
  /// 刷新结果会把条目带回来，之后删除成功也不会再移除。
  final _inFlight = <Future<void>>{};

  @override
  FavouriteTopicListState build() => FavouriteTopicListState.initial();

  bool get hasPendingDeletion => _pending.isNotEmpty;

  /// 先从本地列表移除，等待 [commitDeletion] 或 [undoDeletion]。
  void removeLocally(Topic topic) {
    final tid = topic.tid;
    if (tid == null) return;
    final index = state.list.indexWhere((t) => t.tid == tid);
    if (index < 0) return;
    _pending[tid] = (topic: topic, index: index);
    state = state.copyWith(list: [...state.list]..removeAt(index));
  }

  /// 撤销删除：按原位置插回。
  void undoDeletion(int tid) {
    final pending = _pending.remove(tid);
    if (pending != null) _restore(pending);
  }

  /// 提交删除到服务端；失败时插回列表并抛出错误。已提交或已撤销时返回 null。
  Future<String?> commitDeletion(int tid) async {
    final pending = _pending.remove(tid);
    if (pending == null) return null;
    // page 用移除时条目自带的收藏列表页码，与网页版删除参数一致。
    final request = ref
        .read(topicRepositoryProvider)
        .deleteFavouriteTopic(tid, pending.topic.page);
    final tracked = request.then<void>((_) {}, onError: (_) {});
    _inFlight.add(tracked);
    try {
      return await request;
    } catch (err) {
      if (ref.mounted) _restore(pending);
      rethrow;
    } finally {
      _inFlight.remove(tracked);
    }
  }

  /// 提交全部待删条目，并等待已在进行中的删除请求结束；
  /// 返回本次提交的第一个错误（全部成功为 null）。
  Future<Object?> commitAllDeletions() async {
    Object? firstError;
    for (final tid in [..._pending.keys]) {
      try {
        await commitDeletion(tid);
      } catch (err) {
        firstError ??= err;
      }
    }
    await Future.wait([..._inFlight]);
    return firstError;
  }

  void _restore(_PendingDeletion pending) {
    if (state.list.any((t) => t.tid == pending.topic.tid)) return;
    final index = pending.index.clamp(0, state.list.length);
    state = state.copyWith(list: [...state.list]..insert(index, pending.topic));
  }

  /// 刷新 / 翻页前先提交待删条目，否则服务端数据会把它们带回来；
  /// 提交失败的条目会随刷新结果重新出现。
  Future<void> _flushBeforeLoading() async {
    final err = await commitAllDeletions();
    if (err != null) debugPrint('提交收藏删除失败: $err');
  }

  Future<FavouriteTopicListState> refresh() async {
    await _flushBeforeLoading();
    state = state.copyWith(isLoading: true);
    try {
      TopicListData data = await ref
          .read(topicRepositoryProvider)
          .getFavouriteTopicList(1);
      state = FavouriteTopicListState(
        size: data.topicRows,
        page: 1,
        maxPage: data.maxPage,
        enablePullUp: 1 < data.maxPage,
        list: data.topicList.values.toList(),
        isLoading: false,
      );
      return state;
    } catch (err) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  Future<FavouriteTopicListState> loadMore() async {
    if (state.isLoading) return state;
    await _flushBeforeLoading();
    state = state.copyWith(isLoading: true);
    try {
      TopicListData data = await ref
          .read(topicRepositoryProvider)
          .getFavouriteTopicList(state.page + 1);
      final loadedTids = {for (final t in state.list) t.tid};
      state = FavouriteTopicListState(
        size: data.topicRows,
        page: state.page + 1,
        maxPage: data.maxPage,
        enablePullUp: state.page + 1 < data.maxPage,
        // 删除后服务端分页前移，下一页可能与已加载内容重叠，按 tid 去重
        list: [
          ...state.list,
          ...data.topicList.values.where((t) => !loadedTids.contains(t.tid)),
        ],
        isLoading: false,
      );
      return state;
    } catch (err) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }
}

final favouriteTopicListProvider =
    NotifierProvider<FavouriteTopicListNotifier, FavouriteTopicListState>(
      FavouriteTopicListNotifier.new,
    );
