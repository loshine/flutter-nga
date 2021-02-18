import 'package:flutter/cupertino.dart';
import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/data/entity/topic_detail.dart';
import 'package:mobx/mobx.dart';

part 'topic_detail_store.g.dart';

class TopicDetailStore = _TopicDetailStore with _$TopicDetailStore;

abstract class _TopicDetailStore with Store {
  @observable
  int currentPage = 1;
  @observable
  int maxPage = 1;

  List<Reply> commentList = [];

  @action
  void setMaxPage(int maxPage) {
    this.maxPage = maxPage;
  }

  @action
  void setCurrentPage(int currentPage) {
    this.currentPage = currentPage;
  }

  void mergeCommentList(List<Reply> commentList) {
    commentList.forEach((comment) {
      if (this
              .commentList
              .indexWhere((existComment) => existComment.pid == comment.pid) <
          0) {
        this.commentList.add(comment);
      }
    });
  }

  Future<String> addFavourite(int tid) async {
    try {
      String message = await Data().topicRepository.addFavouriteTopic(tid);
      return message;
    } catch (err) {
      rethrow;
    }
  }
}
