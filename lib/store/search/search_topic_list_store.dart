import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/data/entity/topic.dart';
import 'package:mobx/mobx.dart';

part 'search_topic_list_store.g.dart';

class SearchTopicListStore = _SearchTopicListStore with _$SearchTopicListStore;

abstract class _SearchTopicListStore with Store {
  @observable
  SearchTopicListStoreData state = SearchTopicListStoreData.initial();

  @action
  Future<SearchTopicListStoreData> refresh(
      String keyword, int? fid, bool content) async {
    try {
      TopicListData data =
          await Data().topicRepository.searchTopic(keyword, fid, content, 1);
      state = SearchTopicListStoreData(
        page: 1,
        maxPage: data.maxPage,
        enablePullUp: 1 < data.maxPage,
        list: data.topicList!.values.toList(),
      );
      return state;
    } catch (err) {
      rethrow;
    }
  }

  @action
  Future<SearchTopicListStoreData> loadMore(
      String keyword, int? fid, bool content) async {
    try {
      TopicListData data = await Data()
          .topicRepository
          .searchTopic(keyword, fid, content, state.page);
      state = SearchTopicListStoreData(
        page: state.page + 1,
        maxPage: data.maxPage,
        enablePullUp: state.page + 1 < data.maxPage,
        list: state.list..addAll(data.topicList!.values),
      );
      return state;
    } catch (err) {
      rethrow;
    }
  }
}

class SearchTopicListStoreData {
  final int page;
  final int maxPage;
  final bool enablePullUp;
  final List<Topic> list;

  const SearchTopicListStoreData({
    this.page = 1,
    this.maxPage = 1,
    this.enablePullUp = false,
    this.list = const [],
  });

  factory SearchTopicListStoreData.initial() => SearchTopicListStoreData(
        page: 1,
        maxPage: 1,
        enablePullUp: false,
        list: [],
      );
}
