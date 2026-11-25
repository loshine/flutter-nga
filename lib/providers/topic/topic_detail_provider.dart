import 'package:flutter_nga/data/entity/topic.dart';
import 'package:flutter_nga/providers/core/repository_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef TopicDetailKey = ({int tid});

/// 帖子收藏状态。帖子详情接口不返回是否已收藏，进入页面时为 [unknown]。
enum FavouriteStatus { unknown, favourited, notFavourited }

class TopicDetailState {
  final int currentPage;
  final int maxPage;
  final int maxFloor;
  final Topic? topic;
  final FavouriteStatus favourite;

  /// 收藏 / 取消收藏请求进行中
  final bool favouriteBusy;

  const TopicDetailState({
    this.currentPage = 1,
    this.maxPage = 1,
    this.maxFloor = 1,
    this.topic,
    this.favourite = FavouriteStatus.unknown,
    this.favouriteBusy = false,
  });

  String? get subject => topic?.subject;

  TopicDetailState copyWith({
    int? currentPage,
    int? maxPage,
    int? maxFloor,
    Topic? topic,
    FavouriteStatus? favourite,
    bool? favouriteBusy,
  }) {
    return TopicDetailState(
      currentPage: currentPage ?? this.currentPage,
      maxPage: maxPage ?? this.maxPage,
      maxFloor: maxFloor ?? this.maxFloor,
      topic: topic ?? this.topic,
      favourite: favourite ?? this.favourite,
      favouriteBusy: favouriteBusy ?? this.favouriteBusy,
    );
  }
}

class TopicDetailNotifier extends Notifier<TopicDetailState> {
  TopicDetailNotifier(this.key);

  final TopicDetailKey key;

  @override
  TopicDetailState build() => const TopicDetailState();

  void updateMetadata({
    required int maxPage,
    required int maxFloor,
    required Topic? topic,
  }) {
    final safeMaxPage = maxPage < 1 ? 1 : maxPage;
    var safeCurrentPage = state.currentPage;
    if (safeCurrentPage < 1) {
      safeCurrentPage = 1;
    } else if (safeCurrentPage > safeMaxPage) {
      safeCurrentPage = safeMaxPage;
    }
    state = state.copyWith(
      maxPage: safeMaxPage,
      maxFloor: maxFloor,
      currentPage: safeCurrentPage,
      topic: topic,
    );
  }

  void setCurrentPage(int currentPage) {
    final maxPage = state.maxPage < 1 ? 1 : state.maxPage;
    var safeCurrentPage = currentPage < 1 ? 1 : currentPage;
    if (safeCurrentPage > maxPage) {
      safeCurrentPage = maxPage;
    }
    state = state.copyWith(currentPage: safeCurrentPage);
  }

  /// 已收藏时取消收藏，否则（含状态未知）加入收藏，返回服务端提示。
  ///
  /// 请求进行中再次调用返回 null，不重复提交。
  Future<String?> toggleFavourite() async {
    if (state.favouriteBusy) return null;
    final remove = state.favourite == FavouriteStatus.favourited;
    state = state.copyWith(favouriteBusy: true);
    try {
      final repository = ref.read(topicRepositoryProvider);
      // 网页版删除收藏也带列表页码（默认 1），详情页没有页码，按 1 提交。
      final message = remove
          ? await repository.deleteFavouriteTopic(key.tid, 1)
          : await repository.addFavouriteTopic(key.tid);
      if (!ref.mounted) return message;
      state = state.copyWith(
        favourite: remove
            ? FavouriteStatus.notFavourited
            : FavouriteStatus.favourited,
        favouriteBusy: false,
      );
      return message;
    } catch (err) {
      if (ref.mounted) state = state.copyWith(favouriteBusy: false);
      rethrow;
    }
  }
}

final topicDetailProvider = NotifierProvider.autoDispose
    .family<TopicDetailNotifier, TopicDetailState, TopicDetailKey>(
      TopicDetailNotifier.new,
    );
