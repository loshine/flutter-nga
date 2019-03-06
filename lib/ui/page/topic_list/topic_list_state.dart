import 'package:flutter_nga/data/entity/topic.dart';

class TopicListState {
  final int page;
  final int maxPage;
  final bool enablePullUp;
  final List<Topic> list;

  const TopicListState({
    this.page,
    this.maxPage,
    this.enablePullUp,
    this.list,
  });

  factory TopicListState.initial() => TopicListState(
        page: 1,
        maxPage: 1,
        enablePullUp: false,
        list: [],
      );
}
