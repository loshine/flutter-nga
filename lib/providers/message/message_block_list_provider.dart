import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_nga/data/entity/message.dart';
import 'package:flutter_nga/providers/core/repository_providers.dart';

/// 短消息屏蔽列表：被屏蔽的用户无法与你对话。
///
/// 离开页面即释放（autoDispose），切换账号后重新进入不会显示上一个账号的列表。
class MessageBlockListNotifier extends Notifier<List<MessageParticipant>> {
  @override
  List<MessageParticipant> build() => const [];

  Future<List<MessageParticipant>> refresh() async {
    final users = await ref
        .read(messageRepositoryProvider)
        .getMessageBlockList();
    if (ref.mounted) state = users;
    return users;
  }

  Future<String?> add(List<String> users) async {
    final message = await ref
        .read(messageRepositoryProvider)
        .addMessageBlock(users);
    if (ref.mounted) await refresh();
    return message;
  }

  Future<String?> remove(MessageParticipant user) async {
    final message = await ref
        .read(messageRepositoryProvider)
        .removeMessageBlock(user.uid);
    if (ref.mounted) state = state.where((e) => e.uid != user.uid).toList();
    return message;
  }
}

final messageBlockListProvider =
    NotifierProvider.autoDispose<
      MessageBlockListNotifier,
      List<MessageParticipant>
    >(MessageBlockListNotifier.new);
