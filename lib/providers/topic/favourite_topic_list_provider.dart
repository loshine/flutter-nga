import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/data/entity/topic.dart';
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

class FavouriteTopicListNotifier extends Notifier<FavouriteTopicListState> {
  @override
  FavouriteTopicListState build() => FavouriteTopicListState.initial();

  Future<FavouriteTopicListState> refresh() async {
    state = state.copyWith(isLoading: true);
    try {
      TopicListData data =
          await Data().topicRepository.getFavouriteTopicList(1);
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
    state = state.copyWith(isLoading: true);
    try {
      TopicListData data =
          await Data().topicRepository.getFavouriteTopicList(state.page + 1);
      state = FavouriteTopicListState(
        size: data.topicRows,
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

  Future<String?> delete(Topic topic) async {
    try {
      String? message = await Data()
          .topicRepository
          .deleteFavouriteTopic(topic.tid, topic.page);
      state = state.copyWith(
        list: state.list.where((t) => t.tid != topic.tid).toList(),
      );
      return message;
    } catch (err) {
      rethrow;
    }
  }
}

final favouriteTopicListProvider =
    NotifierProvider<FavouriteTopicListNotifier, FavouriteTopicListState>(
        FavouriteTopicListNotifier.new);
