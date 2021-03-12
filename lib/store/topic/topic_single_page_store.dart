import 'dart:collection';

import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/data/entity/topic.dart';
import 'package:flutter_nga/data/entity/topic_detail.dart';
import 'package:flutter_nga/data/entity/user.dart';
import 'package:mobx/mobx.dart';

part 'topic_single_page_store.g.dart';

class TopicSinglePageStore = _TopicSinglePageStore with _$TopicSinglePageStore;

abstract class _TopicSinglePageStore with Store {
  @observable
  TopicSinglePageStoreData state = TopicSinglePageStoreData.initial();

  @action
  Future<TopicSinglePageStoreData> refresh(int tid, int page) async {
    try {
      TopicDetailData data =
          await Data().topicRepository.getTopicDetail(tid, page);
      List<Reply> replyList = [];
      data.replyList!.values.forEach((reply) {
        replyList.add(reply);
      });
      List<User> userList = data.userList!.values.toList();
      Set<Group> groups = data.groupList!.values.toSet();
      Set<Medal> medals = data.medalList!.values.toSet();
      List<Reply> hotReplyList = [];
      if (page == 1 && data.hotReplies.isNotEmpty) {
        List<TopicDetailData> hots = await Future.wait(data.hotReplies
            .map((e) => Data().topicRepository.getTopicReply(e)));
        hots.forEach((e) {
          userList.addAll(e.userList!.values);
          groups.addAll(e.groupList!.values);
          medals.addAll(e.medalList!.values);
          hotReplyList.addAll(e.replyList!.values);
        });
      }
      state = TopicSinglePageStoreData(
        page: 1,
        maxPage: data.maxPage,
        enablePullUp: 1 < data.maxPage,
        topic: data.topic,
        replyList: replyList,
        hotReplyList: hotReplyList,
        userList: userList,
        groupSet: groups,
        medalSet: medals,
      );
      return state;
    } catch (err) {
      rethrow;
    }
  }
}

class TopicSinglePageStoreData {
  final int? page;
  final int? maxPage;
  final bool? enablePullUp;
  final Topic? topic;
  final List<Reply>? replyList;
  final List<Reply>? hotReplyList;
  final List<User>? userList;
  final Set<Group>? groupSet;
  final Set<Medal>? medalSet;

  const TopicSinglePageStoreData({
    this.page,
    this.maxPage,
    this.enablePullUp,
    this.topic,
    this.replyList,
    this.hotReplyList,
    this.userList,
    this.groupSet,
    this.medalSet,
  });

  factory TopicSinglePageStoreData.initial() => TopicSinglePageStoreData(
        page: 1,
        maxPage: 1,
        enablePullUp: false,
        topic: null,
        replyList: [],
        hotReplyList: [],
        userList: [],
        groupSet: HashSet(),
        medalSet: HashSet(),
      );
}
