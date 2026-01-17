import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/data/entity/topic_history.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class TopicHistoryListState {
  final int page;
  final bool enablePullUp;
  final Map<String, List<TopicHistory>> dateTopicHistoryMap;

  List<dynamic> get list {
    final result = <dynamic>[];
    dateTopicHistoryMap.forEach((k, v) {
      result.add(k);
      result.addAll(v);
    });
    return result;
  }

  const TopicHistoryListState({
    this.page = 1,
    this.enablePullUp = false,
    this.dateTopicHistoryMap = const {},
  });

  TopicHistoryListState copyWith({
    int? page,
    bool? enablePullUp,
    Map<String, List<TopicHistory>>? dateTopicHistoryMap,
  }) {
    return TopicHistoryListState(
      page: page ?? this.page,
      enablePullUp: enablePullUp ?? this.enablePullUp,
      dateTopicHistoryMap: dateTopicHistoryMap ?? this.dateTopicHistoryMap,
    );
  }

  factory TopicHistoryListState.initial() => TopicHistoryListState(
        page: 1,
        enablePullUp: false,
        dateTopicHistoryMap: {},
      );
}

class TopicHistoryListNotifier extends Notifier<TopicHistoryListState> {
  final _limit = 20;
  final _formatter = DateFormat('yyyy-MM-dd');

  @override
  TopicHistoryListState build() => TopicHistoryListState.initial();

  int get _offset => state.page * 20;

  Future<TopicHistoryListState> refresh() async {
    List<TopicHistory> histories =
        await Data().topicRepository.getTopicHistories(_limit, 0);
    Map<String, List<TopicHistory>> map = {};
    for (var history in histories) {
      final date = DateTime.fromMillisecondsSinceEpoch(history.time!);
      String dateString = _formatter.format(date);
      if (!map.containsKey(dateString)) {
        map[dateString] = [];
      }
      map[dateString]!.add(history);
    }
    state = TopicHistoryListState(
      page: 1,
      enablePullUp: histories.length == _limit,
      dateTopicHistoryMap: map,
    );
    return state;
  }

  Future<TopicHistoryListState> loadMore() async {
    List<TopicHistory> histories =
        await Data().topicRepository.getTopicHistories(_limit, _offset);
    Map<String, List<TopicHistory>> map = Map.from(state.dateTopicHistoryMap);
    for (var history in histories) {
      final date = DateTime.fromMicrosecondsSinceEpoch(history.time!);
      String dateString = _formatter.format(date);
      if (!map.containsKey(dateString)) {
        map[dateString] = [];
      }
      map[dateString]!.add(history);
    }
    state = TopicHistoryListState(
      page: state.page + 1,
      enablePullUp: histories.length == _limit,
      dateTopicHistoryMap: map,
    );
    return state;
  }

  Future<void> delete(int id) async {
    await Data().topicRepository.deleteTopicHistoryById(id);
    Map<String, List<TopicHistory>> map = {};
    state.dateTopicHistoryMap.forEach((k, v) {
      int index = v.indexWhere((it) => it.id == id);
      if (index > -1) {
        if (v.length > 1) {
          map[k] = v.where((it) => it.id != id).toList();
        }
      } else {
        map[k] = v;
      }
    });
    state = state.copyWith(dateTopicHistoryMap: map);
  }

  Future<int> clean() {
    return Data().topicRepository.deleteAllTopicHistory();
  }
}

final topicHistoryListProvider =
    NotifierProvider<TopicHistoryListNotifier, TopicHistoryListState>(
        TopicHistoryListNotifier.new);
