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
}
