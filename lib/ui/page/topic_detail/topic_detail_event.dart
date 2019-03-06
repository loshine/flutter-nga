import 'dart:async';

import 'package:pull_to_refresh/pull_to_refresh.dart';

abstract class TopicDetailEvent {
  factory TopicDetailEvent.refresh(int tid, Completer<void> completer) =>
      TopicDetailRefreshEvent(tid: tid, completer: completer);

  factory TopicDetailEvent.loadMore(int tid, RefreshController controller) =>
      TopicDetailLoadMoreEvent(tid: tid, controller: controller);
}

class TopicDetailRefreshEvent implements TopicDetailEvent {
  final int tid;
  final Completer<void> completer;

  const TopicDetailRefreshEvent({this.tid, this.completer});
}

class TopicDetailLoadMoreEvent implements TopicDetailEvent {
  final int tid;
  final RefreshController controller;

  const TopicDetailLoadMoreEvent({this.tid, this.controller});
}
