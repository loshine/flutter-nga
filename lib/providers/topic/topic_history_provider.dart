import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/data/entity/topic_history.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TopicHistoryNotifier extends Notifier<void> {
  @override
  void build() {}

  void insertHistory(TopicHistory history) {
    Data().topicRepository.insertTopicHistory(history);
  }
}

final topicHistoryProvider =
    NotifierProvider<TopicHistoryNotifier, void>(TopicHistoryNotifier.new);
