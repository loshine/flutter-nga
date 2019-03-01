class TopicListEvent {
  final int fid;
  final int page;

  const TopicListEvent({this.fid, this.page});

  factory TopicListEvent.refresh(int fid) => TopicListEvent(fid: fid, page: 1);

  factory TopicListEvent.loadMore({fid, page}) =>
      TopicListEvent(fid: fid, page: page);
}
