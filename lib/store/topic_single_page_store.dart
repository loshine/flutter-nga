import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/data/entity/topic_detail.dart';
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
      List<Reply> commentList = [];
      data.replyList.values.forEach((reply) {
        if (reply.tid == null && commentList.isNotEmpty) {
          Reply comment =
              commentList.firstWhere((comment) => comment.pid == reply.pid);
          if (comment != null) {
            reply.merge(comment);
          }
        }
        replyList.add(reply);
        commentList.addAll(reply.commentList);
      });
      state = TopicSinglePageStoreData(
        page: 1,
        maxPage: data.maxPage,
        enablePullUp: 1 < data.maxPage,
        replyList: replyList,
        userList: data.userList.values.toList(),
        commentList: commentList,
        groupSet: data.groupList.values.toSet(),
        medalSet: data.medalList.values.toSet(),
      );
      return state;
    } catch (err) {
      debugPrint(err.toString());
      rethrow;
    }
  }
}

class TopicSinglePageStoreData {
  final int page;
  final int maxPage;
  final bool enablePullUp;
  final List<Reply> replyList;
  final List<User> userList;
  final List<Reply> commentList;
  final Set<Group> groupSet;
  final Set<Medal> medalSet;

  const TopicSinglePageStoreData({
    this.page,
    this.maxPage,
    this.enablePullUp,
    this.replyList,
    this.userList,
    this.commentList,
    this.groupSet,
    this.medalSet,
  });

  factory TopicSinglePageStoreData.initial() => TopicSinglePageStoreData(
        page: 1,
        maxPage: 1,
        enablePullUp: false,
        replyList: [],
        userList: [],
        commentList: [],
        groupSet: HashSet(),
        medalSet: HashSet(),
      );
}
