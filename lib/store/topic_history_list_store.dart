import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/data/entity/topic_history.dart';
import 'package:intl/intl.dart';
import 'package:mobx/mobx.dart';

part 'topic_history_list_store.g.dart';

class TopicHistoryListStore = _TopicHistoryListStore
    with _$TopicHistoryListStore;

abstract class _TopicHistoryListStore with Store {
  @observable
  TopicHistoryListStoreData state = TopicHistoryListStoreData.initial();

  final _limit = 20;
  final _formatter = DateFormat('yyyy-MM-dd');

  int get _offset => state.page * 20;

  @action
  Future<TopicHistoryListStoreData> refresh() async {
    List<TopicHistory> histories =
        await Data().topicRepository.getTopicHistories(_limit, 0);
    Map<String, List<TopicHistory>> map = Map();
    histories.forEach((history) {
      final date = DateTime.fromMillisecondsSinceEpoch(history.time);
      String dateString = _formatter.format(date);
      if (!map.containsKey(dateString)) {
        map[dateString] = [];
      }
      map[dateString].add(history);
    });
    state = TopicHistoryListStoreData(
      page: 1,
      enablePullUp: histories.length == _limit,
      dateTopicHistoryMap: map,
    );
    return state;
  }

  @action
  Future<TopicHistoryListStoreData> loadMore() async {
    List<TopicHistory> histories =
        await Data().topicRepository.getTopicHistories(_limit, _offset);
    Map<String, List<TopicHistory>> map = state.dateTopicHistoryMap;
    histories.forEach((history) {
      final date = DateTime.fromMicrosecondsSinceEpoch(history.time);
      String dateString = _formatter.format(date);
      if (!map.containsKey(dateString)) {
        map[dateString] = [];
      }
      map[dateString].add(history);
    });
    state = TopicHistoryListStoreData(
      page: state.page + 1,
      enablePullUp: histories.length == _limit,
      dateTopicHistoryMap: map,
    );
    return state;
  }
}

class TopicHistoryListStoreData {
  final int page;
  final bool enablePullUp;
  final Map<String, List<TopicHistory>> dateTopicHistoryMap;

  /// 列表需要的数据
  List<dynamic> get list {
    final _list = [];
    dateTopicHistoryMap.forEach((k, v) {
      _list.add(k);
      _list.addAll(v);
    });
    return _list;
  }

  const TopicHistoryListStoreData({
    this.page,
    this.enablePullUp,
    this.dateTopicHistoryMap,
  });

  factory TopicHistoryListStoreData.initial() => TopicHistoryListStoreData(
        page: 1,
        enablePullUp: false,
        dateTopicHistoryMap: Map(),
      );
}
