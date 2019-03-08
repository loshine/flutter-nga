import 'dart:async';
import 'dart:collection';

import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/data/entity/topic_detail.dart';
import 'package:flutter_nga/ui/page/topic_detail/topic_detail_event.dart';
import 'package:flutter_nga/ui/page/topic_detail/topic_detail_state.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class TopicDetailBloc extends Bloc<TopicDetailEvent, TopicDetailState> {
  @override
  TopicDetailState get initialState => TopicDetailState.initial();

  @override
  Stream<TopicDetailState> mapEventToState(
      TopicDetailState currentState, TopicDetailEvent event) async* {
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
        event.completer.complete();
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
        event.completer.complete();
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
            .getTopicDetail(event.tid, currentState.page + 1);
        event.controller.sendBack(false, RefreshStatus.canRefresh);
        final commentList = currentState.commentList;
        final replyList = currentState.replyList;
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
          page: 1,
          maxPage: data.maxPage,
          enablePullUp: 1 < data.maxPage,
          replyList: replyList,
          userList: currentState.userList..addAll(data.userList.values),
          commentList: commentList,
          groupSet: currentState.groupSet..addAll(data.groupList.values),
          medalSet: currentState.medalSet..addAll(data.medalList.values),
        );
      } catch (err) {
        event.controller.sendBack(false, RefreshStatus.failed);
        Fluttertoast.showToast(
          msg: err.message,
          gravity: ToastGravity.CENTER,
        );
      }
    }
  }

  void onRefresh(int tid, Completer<void> completer) {
    dispatch(TopicDetailEvent.refresh(tid, completer));
  }

  void onLoadMore(int tid, RefreshController controller) {
    dispatch(TopicDetailEvent.loadMore(tid, controller));
  }
}
