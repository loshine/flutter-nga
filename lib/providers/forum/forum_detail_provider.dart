import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/data/entity/topic.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ForumDetailState {
  final int page;
  final int maxPage;
  final bool enablePullUp;
  final List<Topic> list;
  final ForumInfo? info;
  final bool isLoading;
  final String? error;

  const ForumDetailState({
    this.page = 1,
    this.maxPage = 1,
    this.enablePullUp = false,
    this.list = const [],
    this.info,
    this.isLoading = false,
    this.error,
  });

  ForumDetailState copyWith({
    int? page,
    int? maxPage,
    bool? enablePullUp,
    List<Topic>? list,
    ForumInfo? info,
    bool? isLoading,
    String? error,
  }) {
    return ForumDetailState(
      page: page ?? this.page,
      maxPage: maxPage ?? this.maxPage,
      enablePullUp: enablePullUp ?? this.enablePullUp,
      list: list ?? this.list,
      info: info ?? this.info,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  factory ForumDetailState.initial() => const ForumDetailState();
}

class ForumDetailNotifier extends Notifier<ForumDetailState> {
  ForumDetailNotifier(this.fid);
  final int fid;

  @override
  ForumDetailState build() => ForumDetailState.initial();

  Future<ForumDetailState> refresh(bool recommend, int? type) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      TopicListData data = await Data().topicRepository.getTopicList(
            fid: fid,
            page: 1,
            recommend: recommend,
            type: type,
          );
      state = ForumDetailState(
        page: 1,
        maxPage: data.maxPage,
        enablePullUp: 1 < data.maxPage,
        list: data.topicList.values.toList(),
        info: data.forum,
        isLoading: false,
      );
      return state;
    } catch (err) {
      state = state.copyWith(isLoading: false, error: err.toString());
      rethrow;
    }
  }

  Future<ForumDetailState> loadMore(bool recommend, int? type) async {
    if (state.isLoading) return state;
    state = state.copyWith(isLoading: true);
    try {
      TopicListData data = await Data().topicRepository.getTopicList(
            fid: fid,
            page: state.page + 1,
            recommend: recommend,
            type: type,
          );
      state = ForumDetailState(
        page: state.page + 1,
        maxPage: data.maxPage,
        enablePullUp: state.page + 1 < data.maxPage,
        list: [...state.list, ...data.topicList.values],
        info: data.forum,
        isLoading: false,
      );
      return state;
    } catch (err) {
      state = state.copyWith(isLoading: false, error: err.toString());
      rethrow;
    }
  }
}

final forumDetailProvider =
    NotifierProvider.family<ForumDetailNotifier, ForumDetailState, int>(
        ForumDetailNotifier.new);

/// Provider for forum recommended topics (separate from main forum list)
final forumRecommendProvider =
    NotifierProvider.family<ForumDetailNotifier, ForumDetailState, int>(
        ForumDetailNotifier.new);
