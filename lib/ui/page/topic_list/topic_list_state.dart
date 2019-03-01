import 'package:flutter_nga/data/entity/topic.dart';

class TopicListState {
  final int page;
  final bool enablePullUp;
  final bool fabVisible;
  final List<Topic> list;

  const TopicListState(
      {this.page, this.enablePullUp, this.fabVisible, this.list});

  factory TopicListState.initial() =>
      TopicListState(page: 1, enablePullUp: false, fabVisible: true, list: []);
}
