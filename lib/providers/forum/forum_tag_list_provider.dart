import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/data/entity/topic_tag.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ForumTagListNotifier extends Notifier<List<TopicTag>> {
  @override
  List<TopicTag> build() => [];

  void setList(List<TopicTag> list) {
    state = list;
  }

  Future<List<TopicTag>> load(int fid) async {
    try {
      state = await Data().topicRepository.getTopicTagList(fid);
      return state;
    } catch (err) {
      rethrow;
    }
  }
}

final forumTagListProvider =
    NotifierProvider<ForumTagListNotifier, List<TopicTag>>(ForumTagListNotifier.new);
