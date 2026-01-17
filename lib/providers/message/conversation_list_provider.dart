import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/data/entity/conversation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConversationListState {
  final int page;
  final bool enablePullUp;
  final List<Conversation> list;
  final bool isLoading;

  const ConversationListState({
    this.page = 1,
    this.enablePullUp = false,
    this.list = const [],
    this.isLoading = false,
  });

  ConversationListState copyWith({
    int? page,
    bool? enablePullUp,
    List<Conversation>? list,
    bool? isLoading,
  }) {
    return ConversationListState(
      page: page ?? this.page,
      enablePullUp: enablePullUp ?? this.enablePullUp,
      list: list ?? this.list,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  factory ConversationListState.initial() => const ConversationListState();
}

class ConversationListNotifier extends StateNotifier<ConversationListState> {
  ConversationListNotifier() : super(ConversationListState.initial());

  Future<ConversationListState> refresh() async {
    state = state.copyWith(isLoading: true);
    try {
      ConversationListData data =
          await Data().messageRepository.getConversationList(1);
      state = ConversationListState(
        page: 1,
        enablePullUp: data.hasNext,
        list: data.conversationList.toList(),
        isLoading: false,
      );
      return state;
    } catch (err) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  Future<ConversationListState> loadMore() async {
    if (state.isLoading) return state;
    state = state.copyWith(isLoading: true);
    try {
      ConversationListData data =
          await Data().messageRepository.getConversationList(state.page + 1);
      state = ConversationListState(
        page: state.page + 1,
        enablePullUp: data.hasNext,
        list: [...state.list, ...data.conversationList],
        isLoading: false,
      );
      return state;
    } catch (err) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }
}

final conversationListProvider =
    StateNotifierProvider<ConversationListNotifier, ConversationListState>(
        (ref) {
  return ConversationListNotifier();
});
