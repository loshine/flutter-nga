import 'package:flutter_nga/data/entity/topic.dart';
import 'package:flutter_nga/providers/core/repository_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TopicDetailKey {
  const TopicDetailKey({required this.tid});

  final int tid;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is TopicDetailKey && tid == other.tid;

  @override
  int get hashCode => tid.hashCode;
}

class TopicDetailState {
  final int currentPage;
  final int maxPage;
  final int maxFloor;
  final Topic? topic;

  const TopicDetailState({
    this.currentPage = 1,
    this.maxPage = 1,
    this.maxFloor = 1,
    this.topic,
  });

  String? get subject => topic?.subject;

  TopicDetailState copyWith({
    int? currentPage,
    int? maxPage,
    int? maxFloor,
    Topic? topic,
  }) {
    return TopicDetailState(
      currentPage: currentPage ?? this.currentPage,
      maxPage: maxPage ?? this.maxPage,
      maxFloor: maxFloor ?? this.maxFloor,
      topic: topic ?? this.topic,
    );
  }
}

class TopicDetailNotifier extends Notifier<TopicDetailState> {
  TopicDetailNotifier(this.key);

  final TopicDetailKey key;

  @override
  TopicDetailState build() => const TopicDetailState();

  void updateMetadata({
    required int maxPage,
    required int maxFloor,
    required Topic? topic,
  }) {
    final safeMaxPage = maxPage < 1 ? 1 : maxPage;
    var safeCurrentPage = state.currentPage;
    if (safeCurrentPage < 1) {
      safeCurrentPage = 1;
    } else if (safeCurrentPage > safeMaxPage) {
      safeCurrentPage = safeMaxPage;
    }
    state = state.copyWith(
      maxPage: safeMaxPage,
      maxFloor: maxFloor,
      currentPage: safeCurrentPage,
      topic: topic,
    );
  }

  void setCurrentPage(int currentPage) {
    final maxPage = state.maxPage < 1 ? 1 : state.maxPage;
    var safeCurrentPage = currentPage < 1 ? 1 : currentPage;
    if (safeCurrentPage > maxPage) {
      safeCurrentPage = maxPage;
    }
    state = state.copyWith(currentPage: safeCurrentPage);
  }

  Future<String?> addFavourite(int? tid) async {
    try {
      final repository = ref.read(topicRepositoryProvider);
      String? message = await repository.addFavouriteTopic(tid);
      return message;
    } catch (err) {
      rethrow;
    }
  }
}

final topicDetailProvider = NotifierProvider.autoDispose
    .family<TopicDetailNotifier, TopicDetailState, TopicDetailKey>(
        TopicDetailNotifier.new);
