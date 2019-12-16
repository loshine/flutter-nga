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

  void onRefresh(int fid, RefreshController controller) {
    onEvent(TopicListEvent.refresh(fid, controller));
  }

  void onLoadMore(int fid, RefreshController controller) {
    onEvent(TopicListEvent.loadMore(fid, controller));
  }

  @override
  Stream<TopicListState> mapEventToState(TopicListEvent event) async* {
    if (event is TopicListRefreshEvent) {
      try {
        TopicListData data =
            await Data().topicRepository.getTopicList(event.fid, 1);
        event.controller.refreshCompleted(resetFooterState: true);
        yield TopicListState(
          page: 1,
          maxPage: data.maxPage,
          enablePullUp: 1 < data.maxPage,
          list: data.topicList.values.toList(),
        );
      } catch (err) {
        event.controller.refreshFailed();
        Fluttertoast.showToast(
          msg: err.message,
          gravity: ToastGravity.CENTER,
        );
      }
    } else if (event is TopicListLoadMoreEvent) {
      try {
        TopicListData data = await Data()
            .topicRepository
            .getTopicList(event.fid, state.page + 1);
        if (state.page + 1 < data.maxPage) {
          event.controller.loadComplete();
        } else {
          event.controller.loadNoData();
        }
        yield TopicListState(
          page: state.page + 1,
          maxPage: data.maxPage,
          enablePullUp: state.page + 1 < data.maxPage,
          list: state.list..addAll(data.topicList.values),
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
