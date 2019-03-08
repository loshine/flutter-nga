import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/data/entity/topic.dart';
import 'package:flutter_nga/ui/page/topic_list/topic_list_event.dart';
import 'package:flutter_nga/ui/page/topic_list/topic_list_state.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class TopicListBloc extends Bloc<TopicListEvent, TopicListState> {
  @override
  TopicListState get initialState => TopicListState.initial();

  @override
  Stream<TopicListState> mapEventToState(
      TopicListState currentState, TopicListEvent event) async* {
    if (event is TopicListRefreshEvent) {
      try {
        TopicListData data =
            await Data().topicRepository.getTopicList(event.fid, 1);
        event.completer.complete();
        yield TopicListState(
          page: 1,
          maxPage: data.maxPage,
          enablePullUp: 1 < data.maxPage,
          list: data.topicList.values.toList(),
        );
      } catch (err) {
        event.completer.complete();
        Fluttertoast.showToast(
          msg: err.message,
          gravity: ToastGravity.CENTER,
        );
      }
    } else if (event is TopicListLoadMoreEvent) {
      try {
        TopicListData data = await Data()
            .topicRepository
            .getTopicList(event.fid, currentState.page + 1);
        event.controller.sendBack(
            false,
            currentState.page + 1 < data.maxPage
                ? RefreshStatus.canRefresh
                : RefreshStatus.noMore);
        yield TopicListState(
          page: currentState.page + 1,
          maxPage: data.maxPage,
          enablePullUp: currentState.page + 1 < data.maxPage,
          list: currentState.list..addAll(data.topicList.values),
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

  void onRefresh(int fid, Completer<void> completer) {
    dispatch(TopicListEvent.refresh(fid, completer));
  }

  void onLoadMore(int fid, RefreshController controller) {
    dispatch(TopicListEvent.loadMore(fid, controller));
  }
}
