import 'package:flutter_riverpod/flutter_riverpod.dart';

// Top-level constants for backward compatibility
const int FIRST_RADIO_TOPIC = 1;
const int FIRST_RADIO_FORUM = 2;
const int FIRST_RADIO_USER = 3;

const int TOPIC_RADIO_ALL_FORUM = 4;
const int TOPIC_RADIO_CURRENT_FORUM = 5;

const int USER_RADIO_NAME = 6;
const int USER_RADIO_UID = 7;

class SearchOptionsState {
  final int firstRadio;
  final bool content;
  final int topicRadio;
  final int userRadio;

  const SearchOptionsState({
    this.firstRadio = FIRST_RADIO_TOPIC,
    this.content = false,
    this.topicRadio = TOPIC_RADIO_ALL_FORUM,
    this.userRadio = USER_RADIO_NAME,
  });

  factory SearchOptionsState.allForumTopic() => SearchOptionsState(
      firstRadio: FIRST_RADIO_TOPIC,
      content: false,
      topicRadio: TOPIC_RADIO_ALL_FORUM,
      userRadio: USER_RADIO_NAME);

  factory SearchOptionsState.currentForumTopic() => SearchOptionsState(
      firstRadio: FIRST_RADIO_TOPIC,
      content: false,
      topicRadio: TOPIC_RADIO_CURRENT_FORUM,
      userRadio: USER_RADIO_NAME);

  factory SearchOptionsState.forum() => SearchOptionsState(
      firstRadio: FIRST_RADIO_FORUM,
      content: false,
      topicRadio: TOPIC_RADIO_ALL_FORUM,
      userRadio: USER_RADIO_NAME);

  factory SearchOptionsState.user() => SearchOptionsState(
      firstRadio: FIRST_RADIO_USER,
      content: false,
      topicRadio: TOPIC_RADIO_ALL_FORUM,
      userRadio: USER_RADIO_NAME);

  SearchOptionsState copyWith({
    int? firstRadio,
    bool? content,
    int? topicRadio,
    int? userRadio,
  }) {
    return SearchOptionsState(
      firstRadio: firstRadio ?? this.firstRadio,
      content: content ?? this.content,
      topicRadio: topicRadio ?? this.topicRadio,
      userRadio: userRadio ?? this.userRadio,
    );
  }
}

class SearchOptionsNotifier extends Notifier<SearchOptionsState> {
  SearchOptionsNotifier(this.fid);
  final int? fid;

  @override
  SearchOptionsState build() {
    // 根据 fid 返回不同的初始状态
    if (fid != null) {
      return SearchOptionsState.currentForumTopic();
    }
    return SearchOptionsState.allForumTopic();
  }

  void checkFirstRadio(int value) {
    state = state.copyWith(firstRadio: value);
  }

  void checkTopicRadio(int value) {
    state = state.copyWith(topicRadio: value);
  }

  void checkUserRadio(int value) {
    state = state.copyWith(userRadio: value);
  }

  void checkContent(bool value) {
    state = state.copyWith(content: value);
  }
}

final searchOptionsProvider =
    NotifierProvider.family<SearchOptionsNotifier, SearchOptionsState, int?>(SearchOptionsNotifier.new);
