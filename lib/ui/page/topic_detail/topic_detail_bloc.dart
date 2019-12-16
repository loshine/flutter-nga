import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/data/entity/topic_detail.dart';
import 'package:flutter_nga/ui/page/topic_detail/topic_detail_event.dart';
import 'package:flutter_nga/ui/page/topic_detail/topic_detail_state.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class TopicDetailBloc extends Bloc<TopicDetailEvent, TopicDetailState> {
  @override
  TopicDetailState get initialState => TopicDetailState.initial();

  void onRefresh(int tid, RefreshController controller) {
    onEvent(TopicDetailEvent.refresh(tid, controller));
  }

  void onLoadMore(int tid, RefreshController controller) {
    onEvent(TopicDetailEvent.loadMore(tid, controller));
  }

  @override
  Stream<TopicDetailState> mapEventToState(TopicDetailEvent event) async* {
    if (event is TopicDetailRefreshEvent) {
      try {
        TopicDetailData data =
            await Data().topicRepository.getTopicDetail(event.tid, 1);
        List<Reply> replyList = [];
        List<Reply> commentList = [];
        data.replyList.values.forEach((reply) {
          if (reply.tid == null) {
            Reply comment =
                commentList.firstWhere((comment) => comment.pid == reply.pid);
            if (comment != null) {
              reply.merge(comment);
            }
          }
          replyList.add(reply);
          commentList.addAll(reply.commentList);
        });
        event.controller.refreshCompleted(resetFooterState: true);
        yield TopicDetailState(
          page: 1,
          maxPage: data.maxPage,
          enablePullUp: 1 < data.maxPage,
          replyList: replyList,
          userList: data.userList.values.toList(),
          commentList: commentList,
          groupSet: data.groupList.values.toSet(),
          medalSet: data.medalList.values.toSet(),
        );
      } catch (err) {
        event.controller.refreshFailed();
        if (err != null) {
          Fluttertoast.showToast(
            msg: err.message,
            gravity: ToastGravity.CENTER,
          );
        }
      }
    } else if (event is TopicDetailLoadMoreEvent) {
      try {
        TopicDetailData data = await Data()
            .topicRepository
            .getTopicDetail(event.tid, state.page + 1);
        event.controller.loadComplete();
        final commentList = state.commentList;
        final replyList = state.replyList;
        data.replyList.values.forEach((reply) {
          if (reply.tid == null) {
            Reply comment =
                commentList.firstWhere((comment) => comment.pid == reply.pid);
            if (comment != null) {
              reply.merge(comment);
            }
          }
          replyList.add(reply);
          commentList.addAll(reply.commentList);
        });
        yield TopicDetailState(
          page: state.page + 1,
          maxPage: data.maxPage,
          enablePullUp: state.page + 1 < data.maxPage,
          replyList: replyList,
          userList: state.userList..addAll(data.userList.values),
          commentList: commentList,
          groupSet: state.groupSet..addAll(data.groupList.values),
          medalSet: state.medalSet..addAll(data.medalList.values),
        );
      } catch (err) {
        event.controller.loadFailed();
        Fluttertoast.showToast(
          msg: err.message,
          gravity: ToastGravity.CENTER,
        );
      }
    }
  }
}
