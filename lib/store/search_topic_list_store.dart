import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/data/entity/topic.dart';
import 'package:mobx/mobx.dart';

part 'search_topic_list_store.g.dart';

class SearchTopicListStore = _SearchTopicListStore with _$SearchTopicListStore;

abstract class _SearchTopicListStore with Store {
  @observable
  SearchTopicListState state = SearchTopicListState.initial();

  @action
  Future<SearchTopicListState> refresh(
      String keyword, int fid, bool content) async {
    try {
      TopicListData data =
          await Data().topicRepository.searchTopic(keyword, fid, content, 1);
      state = SearchTopicListState(
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
  Future<SearchTopicListState> loadMore(
      String keyword, int fid, bool content) async {
    try {
      TopicListData data = await Data()
          .topicRepository
          .searchTopic(keyword, fid, content, state.page);
      state = SearchTopicListState(
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

class SearchTopicListState {
  final int page;
  final int maxPage;
  final bool enablePullUp;
  final List<Topic> list;

  const SearchTopicListState({
    this.page,
    this.maxPage,
    this.enablePullUp,
    this.list,
  });

  factory SearchTopicListState.initial() => SearchTopicListState(
        page: 1,
        maxPage: 1,
        enablePullUp: false,
        list: [],
      );
}
