import 'dart:collection';

import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/data/entity/topic_detail.dart';
import 'package:mobx/mobx.dart';

part 'topic_detail.g.dart';

class TopicDetail = _TopicDetail with _$TopicDetail;

abstract class _TopicDetail with Store {
  @observable
  TopicDetailState state = TopicDetailState.initial();

  @action
  Future<TopicDetailState> refresh(int tid) async {
    try {
      TopicDetailData data =
          await Data().topicRepository.getTopicDetail(tid, 1);
      List<Reply> replyList = [];
      List<Reply> commentList = [];
      data.replyList.values.forEach((reply) {
        if (reply.tid == null) {
          Reply comment =
              commentList.firstWhere((comment) => comment.pid == reply.pid);
          if (comment != null) {
            reply.merge(comment);
          }
        }
        replyList.add(reply);
        commentList.addAll(reply.commentList);
      });
      state = TopicDetailState(
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
      rethrow;
    }
  }

  @action
  Future<TopicDetailState> loadMore(int tid) async {
    try {
      TopicDetailData data =
          await Data().topicRepository.getTopicDetail(tid, state.page + 1);
      final commentList = state.commentList;
      final replyList = state.replyList;
      data.replyList.values.forEach((reply) {
        if (reply.tid == null) {
          Reply comment =
              commentList.firstWhere((comment) => comment.pid == reply.pid);
          if (comment != null) {
            reply.merge(comment);
          }
        }
        replyList.add(reply);
        commentList.addAll(reply.commentList);
      });
      state = TopicDetailState(
        page: state.page + 1,
        maxPage: data.maxPage,
        enablePullUp: state.page + 1 < data.maxPage,
        replyList: replyList,
        userList: state.userList..addAll(data.userList.values),
        commentList: commentList,
        groupSet: state.groupSet..addAll(data.groupList.values),
        medalSet: state.medalSet..addAll(data.medalList.values),
      );
      return state;
    } catch (err) {
      rethrow;
    }
  }
}

class TopicDetailState {
  final int page;
  final int maxPage;
  final bool enablePullUp;
  final List<Reply> replyList;
  final List<User> userList;
  final List<Reply> commentList;
  final Set<Group> groupSet;
  final Set<Medal> medalSet;

  const TopicDetailState({
    this.page,
    this.maxPage,
    this.enablePullUp,
    this.replyList,
    this.userList,
    this.commentList,
    this.groupSet,
    this.medalSet,
  });

  factory TopicDetailState.initial() => TopicDetailState(
        page: 1,
        maxPage: 1,
        enablePullUp: false,
        replyList: [],
        userList: [],
        commentList: [],
        groupSet: HashSet(),
        medalSet: HashSet(),
      );

  @override
  String toString() {
    return 'TopicDetailState{page: $page, maxPage: $maxPage, enablePullUp: $enablePullUp, replyList: $replyList, userList: $userList, commentList: $commentList, groupSet: $groupSet, medalSet: $medalSet}';
  }
}
