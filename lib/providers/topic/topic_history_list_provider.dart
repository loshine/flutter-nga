import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/data/entity/topic_history.dart';
import 'package:flutter_nga/providers/topic/topic_history_provider.dart';
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

typedef _PendingHistoryDeletion = ({
  String dateKey,
  TopicHistory history,
  int index,
});

class TopicHistoryListNotifier extends Notifier<TopicHistoryListState> {
  final _limit = 20;
  final _formatter = DateFormat('yyyy-MM-dd');
  final _pending = <int, _PendingHistoryDeletion>{};

  bool get hasPendingDeletion => _pending.isNotEmpty;

  @override
  TopicHistoryListState build() => TopicHistoryListState.initial();

  int get _offset => state.page * 20;

  Future<TopicHistoryListState> refresh() async {
    await commitAllDeletions();
    List<TopicHistory> histories = await Data().topicRepository
        .getTopicHistories(_limit, 0);
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
    List<TopicHistory> histories = await Data().topicRepository
        .getTopicHistories(_limit, _offset);
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

  /// 先从本地列表移除，等待 [commitDeletion] 或 [undoDeletion]。
  void removeLocally(TopicHistory history) {
    final id = history.id;
    if (id == null) return;
    final map = <String, List<TopicHistory>>{};
    for (final entry in state.dateTopicHistoryMap.entries) {
      final index = entry.value.indexWhere((it) => it.id == id);
      if (index > -1) {
        _pending[id] = (dateKey: entry.key, history: history, index: index);
        if (entry.value.length > 1) {
          map[entry.key] = entry.value.where((it) => it.id != id).toList();
        }
      } else {
        map[entry.key] = entry.value;
      }
    }
    state = state.copyWith(dateTopicHistoryMap: map);
  }

  /// 撤销单条历史删除，按原日期组与位置插回。
  void undoDeletion(int id) {
    final pending = _pending.remove(id);
    if (pending == null) return;
    _restore(pending);
  }

  /// 提交单条历史删除到本地数据库；失败时插回列表并抛出错误。
  Future<void> commitDeletion(int id) async {
    final pending = _pending.remove(id);
    if (pending == null) return;
    try {
      await Data().topicRepository.deleteTopicHistoryById(id);
      if (ref.mounted) {
        ref.read(readTopicIdsProvider.notifier).reload();
      }
    } catch (_) {
      if (ref.mounted) _restore(pending);
      rethrow;
    }
  }

  /// 离开页面时立即提交全部待删历史。
  Future<Object?> commitAllDeletions() async {
    Object? firstError;
    for (final id in [..._pending.keys]) {
      try {
        await commitDeletion(id);
      } catch (err) {
        firstError ??= err;
      }
    }
    return firstError;
  }

  void _restore(_PendingHistoryDeletion pending) {
    final map = <String, List<TopicHistory>>{
      for (final entry in state.dateTopicHistoryMap.entries)
        entry.key: [...entry.value],
    };
    final list = map.putIfAbsent(pending.dateKey, () => []);
    if (!list.any((it) => it.id == pending.history.id)) {
      final index = pending.index.clamp(0, list.length);
      list.insert(index, pending.history);
    }
    state = state.copyWith(dateTopicHistoryMap: map);
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
    ref.read(readTopicIdsProvider.notifier).reload();
  }

  Future<int> clean() async {
    _pending.clear();
    final count = await Data().topicRepository.deleteAllTopicHistory();
    state = const TopicHistoryListState();
    ref.read(readTopicIdsProvider.notifier).reload();
    return count;
  }
}

final topicHistoryListProvider =
    NotifierProvider<TopicHistoryListNotifier, TopicHistoryListState>(
      TopicHistoryListNotifier.new,
    );
