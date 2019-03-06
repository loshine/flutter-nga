import 'dart:collection';

import 'package:flutter_nga/data/entity/topic_detail.dart';

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
}
