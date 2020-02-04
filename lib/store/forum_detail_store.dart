import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/data/entity/topic.dart';
import 'package:mobx/mobx.dart';

part 'forum_detail_store.g.dart';

class ForumDetailStore = _ForumDetailStore with _$ForumDetailStore;

abstract class _ForumDetailStore with Store {
  @observable
  ForumDetailStoreData state = ForumDetailStoreData.initial();

  @action
  Future<ForumDetailStoreData> refresh(int fid) async {
    try {
      TopicListData data = await Data().topicRepository.getTopicList(fid, 1);
      state = ForumDetailStoreData(
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
  Future<ForumDetailStoreData> loadMore(int fid) async {
    try {
      TopicListData data =
          await Data().topicRepository.getTopicList(fid, state.page);
      state = ForumDetailStoreData(
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

class ForumDetailStoreData {
  final int page;
  final int maxPage;
  final bool enablePullUp;
  final List<Topic> list;

  const ForumDetailStoreData({
    this.page,
    this.maxPage,
    this.enablePullUp,
    this.list,
  });

  factory ForumDetailStoreData.initial() => ForumDetailStoreData(
        page: 1,
        maxPage: 1,
        enablePullUp: false,
        list: [],
      );
}
