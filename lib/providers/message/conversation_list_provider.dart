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

class ConversationListNotifier extends Notifier<ConversationListState> {
  @override
  ConversationListState build() => ConversationListState.initial();

  Future<ConversationListState> refresh() async {
    state = state.copyWith(isLoading: true);
    try {
      ConversationListData data = await Data().messageRepository
          .getConversationList(1);
      final result = ConversationListState(
        page: 1,
        enablePullUp: data.hasNext,
        list: data.conversationList.toList(),
        isLoading: false,
      );
      if (ref.mounted) state = result;
      return result;
    } catch (err) {
      if (ref.mounted) state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  Future<ConversationListState> loadMore() async {
    if (state.isLoading) return state;
    final current = state;
    state = current.copyWith(isLoading: true);
    try {
      ConversationListData data = await Data().messageRepository
          .getConversationList(current.page + 1);
      final result = ConversationListState(
        page: current.page + 1,
        enablePullUp: data.hasNext,
        list: [...current.list, ...data.conversationList],
        isLoading: false,
      );
      if (ref.mounted) state = result;
      return result;
    } catch (err) {
      if (ref.mounted) state = state.copyWith(isLoading: false);
      rethrow;
    }
  }
}

/// 离开页面即释放，避免切换账号后显示上一个账号的对话列表。
final conversationListProvider =
    NotifierProvider.autoDispose<
      ConversationListNotifier,
      ConversationListState
    >(ConversationListNotifier.new);
