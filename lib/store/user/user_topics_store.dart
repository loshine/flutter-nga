import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/data/entity/topic.dart';
import 'package:mobx/mobx.dart';

part 'user_topics_store.g.dart';

class UserTopicsStore = _UserTopicsStore with _$UserTopicsStore;

abstract class _UserTopicsStore with Store {
  @observable
  UserTopicsStoreData state = UserTopicsStoreData.initial();

  @action
  Future<UserTopicsStoreData> refresh(int authorid) async {
    try {
      TopicListData data = await Data()
          .topicRepository
          .getTopicList(authorid: authorid, page: 1);
      state = UserTopicsStoreData(
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

  @action
  Future<UserTopicsStoreData> loadMore(int authorid) async {
    try {
      TopicListData data = await Data()
          .topicRepository
          .getTopicList(authorid: authorid, page: state.page + 1);
      state = UserTopicsStoreData(
        size: data.topicRows,
        page: state.page + 1,
        maxPage: data.maxPage,
        enablePullUp: state.page + 1 < data.maxPage,
        list: state.list..addAll(data.topicList.values),
      );
      return state;
    } catch (err) {
      rethrow;
    }
  }
}

class UserTopicsStoreData {
  final int size;
  final int page;
  final int maxPage;
  final bool enablePullUp;
  final List<Topic> list;

  const UserTopicsStoreData({
    this.size = 35,
    this.page = 1,
    this.maxPage = 1,
    this.enablePullUp = false,
    this.list = const [],
  });

  factory UserTopicsStoreData.initial() => UserTopicsStoreData(
        size: 35,
        page: 1,
        maxPage: 1,
        enablePullUp: false,
        list: [],
      );
}
