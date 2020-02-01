import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/data/entity/topic.dart';
import 'package:mobx/mobx.dart';

part 'forum_detail_store.g.dart';

class ForumDetailStore = _ForumDetailStore with _$ForumDetailStore;

abstract class _ForumDetailStore with Store {
  @observable
  ForumDetailState state = ForumDetailState.initial();

  @action
  Future<ForumDetailState> refresh(int fid) async {
    try {
      TopicListData data = await Data().topicRepository.getTopicList(fid, 1);
      state = ForumDetailState(
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
  Future<ForumDetailState> loadMore(int fid) async {
    try {
      TopicListData data =
          await Data().topicRepository.getTopicList(fid, state.page);
      state = ForumDetailState(
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

class ForumDetailState {
  final int page;
  final int maxPage;
  final bool enablePullUp;
  final List<Topic> list;

  const ForumDetailState({
    this.page,
    this.maxPage,
    this.enablePullUp,
    this.list,
  });

  factory ForumDetailState.initial() => ForumDetailState(
        page: 1,
        maxPage: 1,
        enablePullUp: false,
        list: [],
      );
}
