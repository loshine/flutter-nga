import 'dart:collection';

import 'package:flutter_nga/data/entity/topic.dart';
import 'package:flutter_nga/data/entity/topic_detail.dart';
import 'package:flutter_nga/data/entity/user.dart';
import 'package:flutter_nga/providers/core/repository_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TopicSinglePageState {
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

  const TopicSinglePageState({
    this.page = 1,
    this.maxPage = 1,
    this.maxFloor = 1,
    this.enablePullUp = false,
    this.topic,
    this.replyList = const [],
    this.hotReplyList = const [],
    this.userList = const [],
    this.groupSet = const {},
    this.medalSet = const {},
  });

  factory TopicSinglePageState.initial() => TopicSinglePageState(
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

  TopicSinglePageState copyWith({
    int? page,
    int? maxPage,
    int? maxFloor,
    bool? enablePullUp,
    Topic? topic,
    List<Reply>? replyList,
    List<Reply>? hotReplyList,
    List<User>? userList,
    Set<Group>? groupSet,
    Set<Medal>? medalSet,
  }) {
    return TopicSinglePageState(
      page: page ?? this.page,
      maxPage: maxPage ?? this.maxPage,
      maxFloor: maxFloor ?? this.maxFloor,
      enablePullUp: enablePullUp ?? this.enablePullUp,
      topic: topic ?? this.topic,
      replyList: replyList ?? this.replyList,
      hotReplyList: hotReplyList ?? this.hotReplyList,
      userList: userList ?? this.userList,
      groupSet: groupSet ?? this.groupSet,
      medalSet: medalSet ?? this.medalSet,
    );
  }
}

/// Key for identifying a specific topic single page
class TopicSinglePageKey {
  final int tid;
  final int page;
  final int? authorid;

  const TopicSinglePageKey({
    required this.tid,
    required this.page,
    this.authorid,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TopicSinglePageKey &&
          runtimeType == other.runtimeType &&
          tid == other.tid &&
          page == other.page &&
          authorid == other.authorid;

  @override
  int get hashCode => tid.hashCode ^ page.hashCode ^ authorid.hashCode;
}

class TopicSinglePageNotifier extends Notifier<TopicSinglePageState> {
  TopicSinglePageNotifier(this.key);
  final TopicSinglePageKey key;

  @override
  TopicSinglePageState build() => TopicSinglePageState.initial();

  Future<TopicSinglePageState> refresh() async {
    try {
      final repository = ref.read(topicRepositoryProvider);
      final data = await repository.getTopicDetail(key.tid, key.page, key.authorid);

      List<Reply> replyList = [];
      data.replyList.values.forEach((reply) {
        replyList.add(reply);
      });

      List<User> userList = data.userList.values.toList();
      Set<Group> groups = data.groupList.values.toSet();
      Set<Medal> medals = data.medalList.values.toSet();

      List<Reply> hotReplyList = [];
      if (key.page == 1 && data.hotReplies.isNotEmpty && key.authorid == null) {
        List<dynamic> hots = await Future.wait(
            data.hotReplies.map((e) => repository.getTopicReplies(e)));
        hots.forEach((e) {
          userList.addAll(e.userList.values);
          groups.addAll(e.groupList.values);
          medals.addAll(e.medalList.values);
          hotReplyList.addAll(e.replyList.values);
        });
      }

      state = TopicSinglePageState(
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

final topicSinglePageProvider = NotifierProvider.family<
    TopicSinglePageNotifier, TopicSinglePageState, TopicSinglePageKey>(
  TopicSinglePageNotifier.new,
);
