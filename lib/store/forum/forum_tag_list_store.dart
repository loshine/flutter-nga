import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/data/entity/topic_tag.dart';
import 'package:mobx/mobx.dart';

part 'forum_tag_list_store.g.dart';

class ForumTagListStore = _ForumTagListStore with _$ForumTagListStore;

abstract class _ForumTagListStore with Store {
  @observable
  List<TopicTag> tagList = [];

  @action
  void setList(List<TopicTag> list) {
    tagList = list;
  }

  @action
  Future<List<TopicTag>?> load(int fid) async {
    try {
      tagList = await Data().topicRepository.getTopicTagList(fid);
      return tagList;
    } catch (err) {
      rethrow;
    }
  }
}
