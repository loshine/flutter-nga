import 'package:flutter_nga/data/entity/topic.dart';
import 'package:flutter_nga/providers/core/repository_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserTopicsState {
  final int size;
  final int page;
  final int maxPage;
  final bool enablePullUp;
  final List<Topic> list;

  const UserTopicsState({
    this.size = 35,
    this.page = 1,
    this.maxPage = 1,
    this.enablePullUp = false,
    this.list = const [],
  });

  factory UserTopicsState.initial() => const UserTopicsState(
        size: 35,
        page: 1,
        maxPage: 1,
        enablePullUp: false,
        list: [],
      );

  UserTopicsState copyWith({
    int? size,
    int? page,
    int? maxPage,
    bool? enablePullUp,
    List<Topic>? list,
  }) {
    return UserTopicsState(
      size: size ?? this.size,
      page: page ?? this.page,
      maxPage: maxPage ?? this.maxPage,
      enablePullUp: enablePullUp ?? this.enablePullUp,
      list: list ?? this.list,
    );
  }
}

class UserTopicsNotifier extends StateNotifier<UserTopicsState> {
  final Ref ref;

  UserTopicsNotifier(this.ref) : super(UserTopicsState.initial());

  Future<UserTopicsState> refresh(int authorid) async {
    try {
      final repository = ref.read(topicRepositoryProvider);
      TopicListData data =
          await repository.getTopicList(authorid: authorid, page: 1);
      state = UserTopicsState(
        size: data.topicRows,
        page: 1,
        maxPage: data.maxPage,
        enablePullUp: 1 < data.maxPage,
        list: data.topicList.values.toList(),
      );
      return state;
    } catch (err) {
      rethrow;
    }
  }

  Future<UserTopicsState> loadMore(int authorid) async {
    try {
      final repository = ref.read(topicRepositoryProvider);
      TopicListData data =
          await repository.getTopicList(authorid: authorid, page: state.page + 1);
      final newList = List<Topic>.from(state.list)
        ..addAll(data.topicList.values);
      state = UserTopicsState(
        size: data.topicRows,
        page: state.page + 1,
        maxPage: data.maxPage,
        enablePullUp: state.page + 1 < data.maxPage,
        list: newList,
      );
      return state;
    } catch (err) {
      rethrow;
    }
  }
}

final userTopicsProvider =
    StateNotifierProvider<UserTopicsNotifier, UserTopicsState>((ref) {
  return UserTopicsNotifier(ref);
});
