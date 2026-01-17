import 'package:flutter_nga/data/entity/message.dart';
import 'package:flutter_nga/providers/core/repository_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConversationDetailState {
  final int page;
  final bool enablePullUp;
  final List<Message> list;

  const ConversationDetailState({
    this.page = 1,
    this.enablePullUp = false,
    this.list = const [],
  });

  factory ConversationDetailState.initial() => const ConversationDetailState(
        page: 1,
        enablePullUp: false,
        list: [],
      );

  ConversationDetailState copyWith({
    int? page,
    bool? enablePullUp,
    List<Message>? list,
  }) {
    return ConversationDetailState(
      page: page ?? this.page,
      enablePullUp: enablePullUp ?? this.enablePullUp,
      list: list ?? this.list,
    );
  }
}

class ConversationDetailNotifier extends StateNotifier<ConversationDetailState> {
  final Ref ref;

  ConversationDetailNotifier(this.ref) : super(ConversationDetailState.initial());

  Future<ConversationDetailState> refresh(int? mid) async {
    try {
      final repository = ref.read(messageRepositoryProvider);
      MessageListData data = await repository.getMessageList(mid, 1);
      state = ConversationDetailState(
        page: 1,
        enablePullUp: data.hasNext,
        list: data.messageList.toList(),
      );
      return state;
    } catch (err) {
      rethrow;
    }
  }

  Future<ConversationDetailState> loadMore(int? mid) async {
    try {
      final repository = ref.read(messageRepositoryProvider);
      MessageListData data =
          await repository.getMessageList(mid, state.page + 1);
      final newList = List<Message>.from(state.list)..addAll(data.messageList);
      state = ConversationDetailState(
        page: state.page + 1,
        enablePullUp: data.hasNext,
        list: newList,
      );
      return state;
    } catch (err) {
      rethrow;
    }
  }
}

final conversationDetailProvider =
    StateNotifierProvider<ConversationDetailNotifier, ConversationDetailState>(
        (ref) {
  return ConversationDetailNotifier(ref);
});
