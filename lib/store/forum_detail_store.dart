import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/data/entity/topic.dart';
import 'package:mobx/mobx.dart';

part 'forum_detail_store.g.dart';

class ForumDetailStore = _ForumDetailStore with _$ForumDetailStore;

abstract class _ForumDetailStore with Store {
  @observable
  ForumDetailStoreData state = ForumDetailStoreData.initial();

  @action
  Future<ForumDetailStoreData> refresh(int fid, bool recommend) async {
    try {
      TopicListData data = await Data()
          .topicRepository
          .getTopicList(fid, 1, recommend: recommend);
      state = ForumDetailStoreData(
        page: 1,
        maxPage: data.maxPage,
        enablePullUp: 1 < data.maxPage,
        list: data.topicList.values.toList(),
        info: data.forum,
      );
      return state;
    } catch (err) {
      rethrow;
    }
  }

  @action
  Future<ForumDetailStoreData> loadMore(int fid, bool recommend) async {
    try {
      TopicListData data = await Data()
          .topicRepository
          .getTopicList(fid, state.page + 1, recommend: recommend);
      state = ForumDetailStoreData(
        page: state.page + 1,
        maxPage: data.maxPage,
        enablePullUp: state.page + 1 < data.maxPage,
        list: state.list..addAll(data.topicList.values),
        info: data.forum,
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
  final ForumInfo info;

  const ForumDetailStoreData({
    this.page,
    this.maxPage,
    this.enablePullUp,
    this.list,
    this.info,
  });

  factory ForumDetailStoreData.initial() => ForumDetailStoreData(
        page: 1,
        maxPage: 1,
        enablePullUp: false,
        list: [],
      );
}
