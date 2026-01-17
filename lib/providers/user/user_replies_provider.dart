import 'package:flutter_nga/data/entity/topic.dart';
import 'package:flutter_nga/providers/core/repository_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserRepliesState {
  final int size;
  final int page;
  final bool enablePullUp;
  final List<Topic> list;

  const UserRepliesState({
    this.size = 20,
    this.page = 1,
    this.enablePullUp = false,
    this.list = const [],
  });

  factory UserRepliesState.initial() => const UserRepliesState(
        size: 20,
        page: 1,
        enablePullUp: false,
        list: [],
      );

  UserRepliesState copyWith({
    int? size,
    int? page,
    bool? enablePullUp,
    List<Topic>? list,
  }) {
    return UserRepliesState(
      size: size ?? this.size,
      page: page ?? this.page,
      enablePullUp: enablePullUp ?? this.enablePullUp,
      list: list ?? this.list,
    );
  }
}

class UserRepliesNotifier extends StateNotifier<UserRepliesState> {
  final Ref ref;

  UserRepliesNotifier(this.ref) : super(UserRepliesState.initial());

  Future<UserRepliesState> refresh(int authorid) async {
    try {
      final repository = ref.read(topicRepositoryProvider);
      TopicListData data = await repository.getUserReplies(authorid, 1);
      state = UserRepliesState(
        size: data.rRows,
        page: 1,
        enablePullUp: data.topicList.length == data.rRows,
        list: data.topicList.values.toList(),
      );
      return state;
    } catch (err) {
      rethrow;
    }
  }

  Future<UserRepliesState> loadMore(int authorid) async {
    try {
      final repository = ref.read(topicRepositoryProvider);
      TopicListData data =
          await repository.getUserReplies(authorid, state.page + 1);
      final newList = List<Topic>.from(state.list)
        ..addAll(data.topicList.values);
      state = UserRepliesState(
        size: data.rRows,
        page: state.page + 1,
        enablePullUp:
            newList.length == data.rRows * (state.page + 1),
        list: newList,
      );
      return state;
    } catch (err) {
      rethrow;
    }
  }
}

final userRepliesProvider =
    StateNotifierProvider<UserRepliesNotifier, UserRepliesState>((ref) {
  return UserRepliesNotifier(ref);
});
