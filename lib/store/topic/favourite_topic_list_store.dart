import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/data/entity/topic.dart';
import 'package:mobx/mobx.dart';

part 'favourite_topic_list_store.g.dart';

class FavouriteTopicListStore = _FavouriteTopicListStore
    with _$FavouriteTopicListStore;

abstract class _FavouriteTopicListStore with Store {
  @observable
  FavouriteTopicListStoreData state = FavouriteTopicListStoreData.initial();

  @action
  Future<FavouriteTopicListStoreData> refresh() async {
    try {
      TopicListData data =
          await Data().topicRepository.getFavouriteTopicList(1);
      state = FavouriteTopicListStoreData(
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
  Future<FavouriteTopicListStoreData> loadMore() async {
    try {
      TopicListData data =
          await Data().topicRepository.getFavouriteTopicList(state.page + 1);
      state = FavouriteTopicListStoreData(
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

  @action
  Future<String?> delete(Topic topic) async {
    try {
      String? message = await Data()
          .topicRepository
          .deleteFavouriteTopic(topic.tid, topic.page);
      state = FavouriteTopicListStoreData(
        size: state.size,
        page: state.page,
        maxPage: state.maxPage,
        enablePullUp: state.enablePullUp,
        list: state.list..removeWhere((t) => t.tid == topic.tid),
      );
      return message;
    } catch (err) {
      rethrow;
    }
  }
}

class FavouriteTopicListStoreData {
  final int size;
  final int page;
  final int maxPage;
  final bool enablePullUp;
  final List<Topic> list;

  const FavouriteTopicListStoreData({
    this.size = 35,
    this.page = 1,
    this.maxPage = 1,
    this.enablePullUp = false,
    this.list = const [],
  });

  factory FavouriteTopicListStoreData.initial() => FavouriteTopicListStoreData(
        size: 35,
        page: 1,
        maxPage: 1,
        enablePullUp: false,
        list: [],
      );
}
