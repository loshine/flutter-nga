import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/data/entity/topic_detail.dart';
import 'package:flutter_nga/data/entity/user.dart';
import 'package:flutter_nga/utils/palette.dart';
import 'package:mobx/mobx.dart';

part 'topic_reply_store.g.dart';

class TopicReplyStore = _TopicReplyStore with _$TopicReplyStore;

abstract class _TopicReplyStore with Store {
  @observable
  TopicReplyStoreData state = TopicReplyStoreData.initial();

  Future<TopicReplyStoreData> load(BuildContext context, int? pid) async {
    try {
      TopicDetailData data = await Data().topicRepository.getTopicReply(pid);
      List<Reply> replyList = [];
      data.replyList!.values.forEach((reply) {
        replyList.add(reply);
      });
      List<User> userList = data.userList!.values.toList();
      Set<Group> groups = data.groupList!.values.toSet();
      Set<Medal> medals = data.medalList!.values.toSet();
      final isDark = await Palette.isDark(context);
      state = TopicReplyStoreData(
        replyList: replyList,
        userList: userList,
        groupSet: groups,
        medalSet: medals,
        isDark: isDark,
      );
      return state;
    } catch (err) {
      rethrow;
    }
  }
}

class TopicReplyStoreData {
  final List<Reply> replyList;
  final List<User> userList;
  final Set<Group> groupSet;
  final Set<Medal> medalSet;
  final bool isDark;

  TopicReplyStoreData({
    this.replyList = const [],
    this.userList = const [],
    this.groupSet = const {},
    this.medalSet = const {},
    this.isDark = false,
  });

  factory TopicReplyStoreData.initial() {
    return TopicReplyStoreData(
      replyList: [],
      userList: [],
      groupSet: Set(),
      medalSet: HashSet(),
      isDark: false,
    );
  }
}
