import 'package:flutter_nga/data/entity/topic.dart';
import 'package:flutter_nga/providers/core/repository_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  String? get subject => topic?.subject ?? "";

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
  @override
  TopicDetailState build() => const TopicDetailState();

  void setMaxPage(int maxPage) {
    var safeMaxPage = maxPage < 1 ? 1 : maxPage;
    var safeCurrentPage = state.currentPage;
    if (safeCurrentPage < 1) {
      safeCurrentPage = 1;
    } else if (safeCurrentPage > safeMaxPage) {
      safeCurrentPage = safeMaxPage;
    }
    state = state.copyWith(
      maxPage: safeMaxPage,
      currentPage: safeCurrentPage,
    );
  }

  void setMaxFloor(int maxFloor) {
    state = state.copyWith(maxFloor: maxFloor);
  }

  void setCurrentPage(int currentPage) {
    final maxPage = state.maxPage < 1 ? 1 : state.maxPage;
    var safeCurrentPage = currentPage < 1 ? 1 : currentPage;
    if (safeCurrentPage > maxPage) {
      safeCurrentPage = maxPage;
    }
    state = state.copyWith(currentPage: safeCurrentPage);
  }

  void setTopic(Topic? topic) {
    if (topic == null || (state.topic != null && state.topic!.tid == topic.tid)) {
      return;
    }
    state = state.copyWith(topic: topic);
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

final topicDetailProvider =
    NotifierProvider<TopicDetailNotifier, TopicDetailState>(TopicDetailNotifier.new);
