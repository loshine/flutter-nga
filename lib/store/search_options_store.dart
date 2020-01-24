import 'package:mobx/mobx.dart';

part 'search_options_store.g.dart';

class SearchOptionsStore = _SearchOptionsStore with _$SearchOptionsStore;

abstract class _SearchOptionsStore with Store {
  @observable
  SearchState state = SearchState.allForumTopic();

  @action
  void checkFirstRadio(int value) {
    state =
        SearchState(value, state.content, state.topicRadio, state.userRadio);
  }

  @action
  void checkTopicRadio(int value) {
    state =
        SearchState(state.firstRadio, state.content, value, state.userRadio);
  }

  @action
  void checkUserRadio(int value) {
    state =
        SearchState(state.firstRadio, state.content, state.topicRadio, value);
  }

  @action
  void checkContent(bool value) {
    state =
        SearchState(state.firstRadio, value, state.topicRadio, state.userRadio);
  }
}

class SearchState {
  static final int FIRST_RADIO_TOPIC = 1;
  static final int FIRST_RADIO_FORUM = 2;
  static final int FIRST_RADIO_USER = 3;

  static final int TOPIC_RADIO_ALL_FORUM = 4;
  static final int TOPIC_RADIO_CURRENT_FORUM = 5;

  static final int USER_RADIO_NAME = 6;
  static final int USER_RADIO_UID = 7;

  final int firstRadio;
  final bool content;
  final int topicRadio;
  final int userRadio;

  const SearchState(
      this.firstRadio, this.content, this.topicRadio, this.userRadio);

  factory SearchState.allForumTopic() => SearchState(
      FIRST_RADIO_TOPIC, false, TOPIC_RADIO_ALL_FORUM, USER_RADIO_NAME);

  factory SearchState.currentForumTopic() => SearchState(
      FIRST_RADIO_TOPIC, false, TOPIC_RADIO_CURRENT_FORUM, USER_RADIO_NAME);

  factory SearchState.forum() => SearchState(
      FIRST_RADIO_FORUM, false, TOPIC_RADIO_ALL_FORUM, USER_RADIO_NAME);

  factory SearchState.user() => SearchState(
      FIRST_RADIO_USER, false, TOPIC_RADIO_ALL_FORUM, USER_RADIO_NAME);
}
