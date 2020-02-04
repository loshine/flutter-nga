import 'package:mobx/mobx.dart';

part 'search_options_store.g.dart';

class SearchOptionsStore = _SearchOptionsStore with _$SearchOptionsStore;

abstract class _SearchOptionsStore with Store {
  @observable
  SearchStoreData state = SearchStoreData.allForumTopic();

  @action
  void checkFirstRadio(int value) {
    state =
        SearchStoreData(value, state.content, state.topicRadio, state.userRadio);
  }

  @action
  void checkTopicRadio(int value) {
    state =
        SearchStoreData(state.firstRadio, state.content, value, state.userRadio);
  }

  @action
  void checkUserRadio(int value) {
    state =
        SearchStoreData(state.firstRadio, state.content, state.topicRadio, value);
  }

  @action
  void checkContent(bool value) {
    state =
        SearchStoreData(state.firstRadio, value, state.topicRadio, state.userRadio);
  }
}

class SearchStoreData {
  static const int FIRST_RADIO_TOPIC = 1;
  static const int FIRST_RADIO_FORUM = 2;
  static const int FIRST_RADIO_USER = 3;

  static const int TOPIC_RADIO_ALL_FORUM = 4;
  static const int TOPIC_RADIO_CURRENT_FORUM = 5;

  static const int USER_RADIO_NAME = 6;
  static const int USER_RADIO_UID = 7;

  final int firstRadio;
  final bool content;
  final int topicRadio;
  final int userRadio;

  const SearchStoreData(
      this.firstRadio, this.content, this.topicRadio, this.userRadio);

  factory SearchStoreData.allForumTopic() => SearchStoreData(
      FIRST_RADIO_TOPIC, false, TOPIC_RADIO_ALL_FORUM, USER_RADIO_NAME);

  factory SearchStoreData.currentForumTopic() => SearchStoreData(
      FIRST_RADIO_TOPIC, false, TOPIC_RADIO_CURRENT_FORUM, USER_RADIO_NAME);

  factory SearchStoreData.forum() => SearchStoreData(
      FIRST_RADIO_FORUM, false, TOPIC_RADIO_ALL_FORUM, USER_RADIO_NAME);

  factory SearchStoreData.user() => SearchStoreData(
      FIRST_RADIO_USER, false, TOPIC_RADIO_ALL_FORUM, USER_RADIO_NAME);
}
