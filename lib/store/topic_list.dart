import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/data/entity/topic.dart';
import 'package:mobx/mobx.dart';

part 'topic_list.g.dart';

class TopicList = _TopicList with _$TopicList;

abstract class _TopicList with Store {
  @observable
  TopicListState state = TopicListState.initial();

  @action
  Future<TopicListState> refresh(int fid) async {
    try {
      TopicListData data = await Data().topicRepository.getTopicList(fid, 1);
      state = TopicListState(
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
  Future<TopicListState> loadMore(int fid) async {
    try {
      TopicListData data =
          await Data().topicRepository.getTopicList(fid, state.page);
      state = TopicListState(
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

class TopicListState {
  final int page;
  final int maxPage;
  final bool enablePullUp;
  final List<Topic> list;

  const TopicListState({
    this.page,
    this.maxPage,
    this.enablePullUp,
    this.list,
  });

  factory TopicListState.initial() => TopicListState(
        page: 1,
        maxPage: 1,
        enablePullUp: false,
        list: [],
      );
}
