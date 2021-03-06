import 'dart:collection';

import 'package:flutter/material.dart';
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
  Future<TopicSinglePageStoreData> refresh(
      BuildContext context, int tid, int page, int? authorid) async {
    try {
      TopicDetailData data =
          await Data().topicRepository.getTopicDetail(tid, page, authorid);
      List<Reply> replyList = [];
      data.replyList.values.forEach((reply) {
        replyList.add(reply);
      });
      List<User> userList = data.userList.values.toList();
      Set<Group> groups = data.groupList.values.toSet();
      Set<Medal> medals = data.medalList.values.toSet();
      List<Reply> hotReplyList = [];
      if (page == 1 && data.hotReplies.isNotEmpty && authorid == null) {
        List<TopicDetailData> hots = await Future.wait(data.hotReplies
            .map((e) => Data().topicRepository.getTopicReplies(e)));
        hots.forEach((e) {
          userList.addAll(e.userList.values);
          groups.addAll(e.groupList.values);
          medals.addAll(e.medalList.values);
          hotReplyList.addAll(e.replyList.values);
        });
      }
      state = TopicSinglePageStoreData(
        page: 1,
        maxPage: data.maxPage,
        maxFloor: data.rows,
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
  final int page;
  final int maxPage;
  final int maxFloor;
  final bool enablePullUp;
  final Topic? topic;
  final List<Reply> replyList;
  final List<Reply> hotReplyList;
  final List<User> userList;
  final Set<Group> groupSet;
  final Set<Medal> medalSet;

  const TopicSinglePageStoreData({
    required this.page,
    required this.maxPage,
    required this.maxFloor,
    required this.enablePullUp,
    this.topic,
    required this.replyList,
    required this.hotReplyList,
    required this.userList,
    required this.groupSet,
    required this.medalSet,
  });

  factory TopicSinglePageStoreData.initial() => TopicSinglePageStoreData(
        page: 1,
        maxPage: 1,
        maxFloor: 1,
        enablePullUp: false,
        topic: null,
        replyList: [],
        hotReplyList: [],
        userList: [],
        groupSet: HashSet(),
        medalSet: HashSet(),
      );
}
