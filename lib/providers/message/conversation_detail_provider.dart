import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_nga/data/entity/message.dart';
import 'package:flutter_nga/providers/core/repository_providers.dart';

class ConversationDetailState {
  final int page;
  final bool enablePullUp;
  final List<Message> list;
  final List<MessageParticipant> participants;

  /// 对话发起人 uid。
  final int? starterUid;

  /// 当前登录账号 uid。
  final int? currentUid;

  /// 参与者的回复互相不可见。
  final bool isIsolated;

  const ConversationDetailState({
    this.page = 1,
    this.enablePullUp = false,
    this.list = const [],
    this.participants = const [],
    this.starterUid,
    this.currentUid,
    this.isIsolated = false,
  });

  /// 发起人可以把其他参与者移出对话。
  bool get isStarter =>
      currentUid != null && currentUid != 0 && currentUid == starterUid;

  bool canRemove(MessageParticipant participant) =>
      isStarter && participant.uid != currentUid;

  ConversationDetailState copyWith({
    int? page,
    bool? enablePullUp,
    List<Message>? list,
    List<MessageParticipant>? participants,
    int? starterUid,
    int? currentUid,
    bool? isIsolated,
  }) {
    return ConversationDetailState(
      page: page ?? this.page,
      enablePullUp: enablePullUp ?? this.enablePullUp,
      list: list ?? this.list,
      participants: participants ?? this.participants,
      starterUid: starterUid ?? this.starterUid,
      currentUid: currentUid ?? this.currentUid,
      isIsolated: isIsolated ?? this.isIsolated,
    );
  }
}

/// 以 mid 分桶，避免切换对话时串用上一个对话的内容。
class ConversationDetailNotifier extends Notifier<ConversationDetailState> {
  ConversationDetailNotifier(this.mid);

  final int mid;

  @override
  ConversationDetailState build() => const ConversationDetailState();

  Future<ConversationDetailState> refresh() async {
    final repository = ref.read(messageRepositoryProvider);
    final data = await repository.getMessageList(mid, 1);
    final user = await ref.read(userRepositoryProvider).getDefaultUser();
    state = ConversationDetailState(
      page: 1,
      enablePullUp: data.hasNext,
      list: data.messageList.toList(),
      participants: data.participants,
      starterUid: data.starterUid,
      currentUid: int.tryParse(user?.uid ?? ''),
      isIsolated: data.isIsolated,
    );
    return state;
  }

  Future<ConversationDetailState> loadMore() async {
    final repository = ref.read(messageRepositoryProvider);
    final data = await repository.getMessageList(mid, state.page + 1);
    state = state.copyWith(
      page: state.page + 1,
      enablePullUp: data.hasNext,
      list: [...state.list, ...data.messageList],
      participants: data.participants.isEmpty ? null : data.participants,
    );
    return state;
  }

  /// 邀请用户加入对话，成功后刷新参与者。
  Future<String?> invite(List<String> users) async {
    final message = await ref
        .read(messageRepositoryProvider)
        .inviteToConversation(mid, users);
    await refresh();
    return message;
  }

  /// 把参与者移出对话（发起人可用）。
  Future<String?> remove(MessageParticipant participant) async {
    final message = await ref
        .read(messageRepositoryProvider)
        .leaveConversation(mid, participant.uid);
    state = state.copyWith(
      participants: state.participants
          .where((p) => p.uid != participant.uid)
          .toList(),
    );
    return message;
  }

  /// 自己退出对话。
  Future<String?> leave() async {
    final uid =
        state.currentUid ??
        int.tryParse(
          (await ref.read(userRepositoryProvider).getDefaultUser())?.uid ?? '',
        );
    if (uid == null) throw StateError('未登录');
    return ref.read(messageRepositoryProvider).leaveConversation(mid, uid);
  }
}

final conversationDetailProvider =
    NotifierProvider.family<
      ConversationDetailNotifier,
      ConversationDetailState,
      int
    >(ConversationDetailNotifier.new);
