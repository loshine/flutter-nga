import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/data/entity/topic.dart';
import 'package:mobx/mobx.dart';

part 'topic_detail_store.g.dart';

class TopicDetailStore = _TopicDetailStore with _$TopicDetailStore;

abstract class _TopicDetailStore with Store {
  @observable
  int currentPage = 1;
  @observable
  int maxPage = 1;
  @observable
  Topic topic;

  String get subject => topic != null ? topic.subject : "";

  @action
  void setMaxPage(int maxPage) {
    this.maxPage = maxPage;
  }

  @action
  void setCurrentPage(int currentPage) {
    this.currentPage = currentPage;
  }

  @action
  void setTopic(Topic topic) {
    if (topic == null || (this.topic != null && this.topic.tid == topic.tid))
      return;
    this.topic = topic;
  }

  Future<String> addFavourite(int tid) async {
    try {
      String message = await Data().topicRepository.addFavouriteTopic(tid);
      return message;
    } catch (err) {
      rethrow;
    }
  }
}
