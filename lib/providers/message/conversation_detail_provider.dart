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

/// 以 mid 分桶，避免切换对话时串用上一个对话的内容；离开页面即释放，
/// 切换账号后不会显示上一个账号的缓存。
class ConversationDetailNotifier extends Notifier<ConversationDetailState> {
  ConversationDetailNotifier(this.mid);

  final int mid;

  @override
  ConversationDetailState build() => const ConversationDetailState();

  Future<ConversationDetailState> refresh() async {
    final repository = ref.read(messageRepositoryProvider);
    final userRepository = ref.read(userRepositoryProvider);
    final data = await repository.getMessageList(mid, 1);
    final user = await userRepository.getDefaultUser();
    final result = ConversationDetailState(
      page: 1,
      enablePullUp: data.hasNext,
      list: data.messageList.toList(),
      participants: data.participants,
      starterUid: data.starterUid,
      currentUid: int.tryParse(user?.uid ?? ''),
      isIsolated: data.isIsolated,
    );
    if (ref.mounted) state = result;
    return result;
  }

  Future<ConversationDetailState> loadMore() async {
    final repository = ref.read(messageRepositoryProvider);
    final current = state;
    final data = await repository.getMessageList(mid, current.page + 1);
    final result = current.copyWith(
      page: current.page + 1,
      enablePullUp: data.hasNext,
      list: [...current.list, ...data.messageList],
      participants: data.participants.isEmpty ? null : data.participants,
    );
    if (ref.mounted) state = result;
    return result;
  }

  /// 邀请用户加入对话，成功后刷新参与者。
  Future<String?> invite(List<String> users) async {
    final message = await ref
        .read(messageRepositoryProvider)
        .inviteToConversation(mid, users);
    if (ref.mounted) await refresh();
    return message;
  }

  /// 把参与者移出对话（发起人可用）。
  Future<String?> remove(MessageParticipant participant) async {
    final message = await ref
        .read(messageRepositoryProvider)
        .leaveConversation(mid, participant.uid);
    if (!ref.mounted) return message;
    state = state.copyWith(
      participants: state.participants
          .where((p) => p.uid != participant.uid)
          .toList(),
    );
    return message;
  }

  /// 自己退出对话。
  Future<String?> leave() async {
    final messageRepository = ref.read(messageRepositoryProvider);
    final userRepository = ref.read(userRepositoryProvider);
    final uid =
        state.currentUid ??
        int.tryParse((await userRepository.getDefaultUser())?.uid ?? '');
    if (uid == null) throw StateError('未登录');
    return messageRepository.leaveConversation(mid, uid);
  }
}

final conversationDetailProvider = NotifierProvider.autoDispose
    .family<ConversationDetailNotifier, ConversationDetailState, int>(
      ConversationDetailNotifier.new,
    );
