import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/data/entity/topic_history.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TopicHistoryNotifier extends StateNotifier<void> {
  TopicHistoryNotifier() : super(null);

  void insertHistory(TopicHistory history) {
    Data().topicRepository.insertTopicHistory(history);
  }
}

final topicHistoryProvider =
    StateNotifierProvider<TopicHistoryNotifier, void>((ref) {
  return TopicHistoryNotifier();
});
