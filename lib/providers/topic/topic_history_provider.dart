import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/data/entity/topic_history.dart';
import 'package:flutter_nga/providers/core/repository_providers.dart';

class TopicHistoryNotifier extends Notifier<void> {
  @override
  void build() {}

  void insertHistory(TopicHistory history) {
    Data().topicRepository.insertTopicHistory(history);
    ref.read(readTopicIdsProvider.notifier).markRead(history.tid);
  }
}

final topicHistoryProvider = NotifierProvider<TopicHistoryNotifier, void>(
  TopicHistoryNotifier.new,
);

/// 浏览过的帖子 tid 集合，帖子列表据此把已读标题显示为弱色。
///
/// 首次使用时从浏览历史整体读取一次，之后打开帖子时增量加入；
/// 列表项用集合做 O(1) 判断，不逐条查询数据库。
class ReadTopicIdsNotifier extends Notifier<Set<int>> {
  @override
  Set<int> build() {
    Future.microtask(reload);
    return const {};
  }

  /// 重新从浏览历史读取（删除、清空历史后调用）
  Future<void> reload() async {
    try {
      final ids = await ref.read(topicRepositoryProvider).getHistoryTopicIds();
      if (ref.mounted) state = ids;
    } catch (err) {
      debugPrint('读取已读帖子失败: $err');
    }
  }

  void markRead(int tid) {
    if (state.contains(tid)) return;
    state = {...state, tid};
  }
}

final readTopicIdsProvider = NotifierProvider<ReadTopicIdsNotifier, Set<int>>(
  ReadTopicIdsNotifier.new,
);
