import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/data/entity/topic.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchTopicListState {
  final int page;
  final int maxPage;
  final bool enablePullUp;
  final List<Topic> list;
  final bool isLoading;

  const SearchTopicListState({
    this.page = 1,
    this.maxPage = 1,
    this.enablePullUp = false,
    this.list = const [],
    this.isLoading = false,
  });

  SearchTopicListState copyWith({
    int? page,
    int? maxPage,
    bool? enablePullUp,
    List<Topic>? list,
    bool? isLoading,
  }) {
    return SearchTopicListState(
      page: page ?? this.page,
      maxPage: maxPage ?? this.maxPage,
      enablePullUp: enablePullUp ?? this.enablePullUp,
      list: list ?? this.list,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  factory SearchTopicListState.initial() => const SearchTopicListState();
}

class SearchTopicListNotifier extends Notifier<SearchTopicListState> {
  @override
  SearchTopicListState build() => SearchTopicListState.initial();

  Future<SearchTopicListState> refresh(
      String keyword, int? fid, bool content) async {
    state = state.copyWith(isLoading: true);
    try {
      TopicListData data =
          await Data().topicRepository.searchTopic(keyword, fid, content, 1);
      state = SearchTopicListState(
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

  Future<SearchTopicListState> loadMore(
      String keyword, int? fid, bool content) async {
    if (state.isLoading) return state;
    state = state.copyWith(isLoading: true);
    try {
      TopicListData data = await Data()
          .topicRepository
          .searchTopic(keyword, fid, content, state.page + 1);
      state = SearchTopicListState(
        page: state.page + 1,
        maxPage: data.maxPage,
        enablePullUp: state.page + 1 < data.maxPage,
        list: [...state.list, ...data.topicList.values],
        isLoading: false,
      );
      return state;
    } catch (err) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }
}

final searchTopicListProvider =
    NotifierProvider<SearchTopicListNotifier, SearchTopicListState>(SearchTopicListNotifier.new);
