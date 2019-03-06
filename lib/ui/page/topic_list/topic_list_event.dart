import 'dart:async';

import 'package:pull_to_refresh/pull_to_refresh.dart';

abstract class TopicListEvent {
  factory TopicListEvent.refresh(int fid, Completer<void> completer) =>
      TopicListRefreshEvent(fid: fid, completer: completer);

  factory TopicListEvent.loadMore(int fid, RefreshController controller) =>
      TopicListLoadMoreEvent(fid: fid, controller: controller);
}

class TopicListRefreshEvent implements TopicListEvent {
  final int fid;
  final Completer<void> completer;

  const TopicListRefreshEvent({this.fid, this.completer});
}

class TopicListLoadMoreEvent implements TopicListEvent {
  final int fid;
  final RefreshController controller;

  const TopicListLoadMoreEvent({this.fid, this.controller});
}
