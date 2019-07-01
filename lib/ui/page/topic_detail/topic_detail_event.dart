import 'package:pull_to_refresh/pull_to_refresh.dart';

abstract class TopicDetailEvent {
  factory TopicDetailEvent.refresh(int tid, RefreshController controller) =>
      TopicDetailRefreshEvent(tid: tid, controller: controller);

  factory TopicDetailEvent.loadMore(int tid, RefreshController controller) =>
      TopicDetailLoadMoreEvent(tid: tid, controller: controller);
}

class TopicDetailRefreshEvent implements TopicDetailEvent {
  final int tid;
  final RefreshController controller;

  const TopicDetailRefreshEvent({this.tid, this.controller});
}

class TopicDetailLoadMoreEvent implements TopicDetailEvent {
  final int tid;
  final RefreshController controller;

  const TopicDetailLoadMoreEvent({this.tid, this.controller});
}
