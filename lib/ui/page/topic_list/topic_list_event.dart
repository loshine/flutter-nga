import 'package:pull_to_refresh/pull_to_refresh.dart';

abstract class TopicListEvent {
  factory TopicListEvent.refresh(int fid, RefreshController controller) =>
      TopicListRefreshEvent(fid: fid, controller: controller);

  factory TopicListEvent.loadMore(int fid, RefreshController controller) =>
      TopicListLoadMoreEvent(fid: fid, controller: controller);
}

class TopicListRefreshEvent implements TopicListEvent {
  final int fid;
  final RefreshController controller;

  const TopicListRefreshEvent({this.fid, this.controller});
}

class TopicListLoadMoreEvent implements TopicListEvent {
  final int fid;
  final RefreshController controller;

  const TopicListLoadMoreEvent({this.fid, this.controller});
}
