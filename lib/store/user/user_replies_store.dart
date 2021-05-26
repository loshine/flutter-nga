import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/data/entity/topic.dart';
import 'package:mobx/mobx.dart';

part 'user_replies_store.g.dart';

class UserRepliesStore = _UserRepliesStore with _$UserRepliesStore;

abstract class _UserRepliesStore with Store {
  @observable
  UserRepliesStoreData state = UserRepliesStoreData.initial();

  @action
  Future<UserRepliesStoreData> refresh(int authorid) async {
    try {
      TopicListData data =
          await Data().topicRepository.getUserReplies(authorid, 1);
      state = UserRepliesStoreData(
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

  @action
  Future<UserRepliesStoreData> loadMore(int authorid) async {
    try {
      TopicListData data =
          await Data().topicRepository.getUserReplies(authorid, state.page + 1);
      state = UserRepliesStoreData(
        size: data.rRows,
        page: state.page + 1,
        enablePullUp: state.list.length + data.topicList.length ==
            data.rRows * (state.page + 1),
        list: state.list..addAll(data.topicList.values),
      );
      return state;
    } catch (err) {
      rethrow;
    }
  }
}

class UserRepliesStoreData {
  final int size;
  final int page;
  final bool enablePullUp;
  final List<Topic> list;

  const UserRepliesStoreData({
    this.size = 20,
    this.page = 1,
    this.enablePullUp = false,
    this.list = const [],
  });

  factory UserRepliesStoreData.initial() => UserRepliesStoreData(
        size: 20,
        page: 1,
        enablePullUp: false,
        list: [],
      );
}
