import 'dart:collection';

import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/data/entity/topic_detail.dart';
import 'package:flutter_nga/data/entity/user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TopicReplyState {
  final List<Reply> replyList;
  final List<User> userList;
  final Set<Group> groupSet;
  final Set<Medal> medalSet;
  final bool isLoading;

  const TopicReplyState({
    this.replyList = const [],
    this.userList = const [],
    this.groupSet = const {},
    this.medalSet = const {},
    this.isLoading = false,
  });

  factory TopicReplyState.initial() {
    return TopicReplyState(
      replyList: [],
      userList: [],
      groupSet: {},
      medalSet: HashSet(),
    );
  }
}

class TopicReplyNotifier extends StateNotifier<TopicReplyState> {
  TopicReplyNotifier() : super(TopicReplyState.initial());

  Future<TopicReplyState> load(int? pid) async {
    state = TopicReplyState(isLoading: true);
    try {
      TopicDetailData data = await Data().topicRepository.getTopicReplies(pid);
      List<Reply> replyList = data.replyList.values.toList();
      List<User> userList = data.userList.values.toList();
      Set<Group> groups = data.groupList.values.toSet();
      Set<Medal> medals = data.medalList.values.toSet();
      state = TopicReplyState(
        replyList: replyList,
        userList: userList,
        groupSet: groups,
        medalSet: medals,
        isLoading: false,
      );
      return state;
    } catch (err) {
      state = TopicReplyState.initial();
      rethrow;
    }
  }
}

final topicReplyProvider =
    StateNotifierProvider.family<TopicReplyNotifier, TopicReplyState, int?>((ref, pid) {
  return TopicReplyNotifier();
});
