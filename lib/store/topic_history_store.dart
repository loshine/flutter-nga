import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/data/entity/topic_history.dart';
import 'package:mobx/mobx.dart';

part 'topic_history_store.g.dart';

class TopicHistoryStore = _TopicHistoryStore with _$TopicHistoryStore;

abstract class _TopicHistoryStore with Store {
  @action
  void insertHistory(TopicHistory history) {
    Data().topicRepository.insertTopicHistory(history);
  }
}
