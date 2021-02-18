import 'package:flutter_nga/data/data.dart';
import 'package:mobx/mobx.dart';

part 'topic_detail_store.g.dart';

class TopicDetailStore = _TopicDetailStore with _$TopicDetailStore;

abstract class _TopicDetailStore with Store {
  @observable
  int currentPage = 1;
  @observable
  int maxPage = 1;

  @action
  void setMaxPage(int maxPage) {
    this.maxPage = maxPage;
  }

  @action
  void setCurrentPage(int currentPage) {
    this.currentPage = currentPage;
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
