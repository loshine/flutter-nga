import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_nga/data/entity/message.dart';
import 'package:flutter_nga/providers/core/repository_providers.dart';

/// 短消息屏蔽列表：被屏蔽的用户无法与你对话。
class MessageBlockListNotifier extends Notifier<List<MessageParticipant>> {
  @override
  List<MessageParticipant> build() => const [];

  Future<List<MessageParticipant>> refresh() async {
    state = await ref.read(messageRepositoryProvider).getMessageBlockList();
    return state;
  }

  Future<String?> add(List<String> users) async {
    final message = await ref
        .read(messageRepositoryProvider)
        .addMessageBlock(users);
    await refresh();
    return message;
  }

  Future<String?> remove(MessageParticipant user) async {
    final message = await ref
        .read(messageRepositoryProvider)
        .removeMessageBlock(user.uid);
    state = state.where((e) => e.uid != user.uid).toList();
    return message;
  }
}

final messageBlockListProvider =
    NotifierProvider<MessageBlockListNotifier, List<MessageParticipant>>(
      MessageBlockListNotifier.new,
    );
