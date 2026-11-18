import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_nga/providers/core/repository_providers.dart';

class SendMessageState {
  final List<String> contacts;

  /// 新对话：参与者只能看到自己的回复。
  final bool isolate;

  const SendMessageState({this.contacts = const [], this.isolate = false});

  SendMessageState copyWith({List<String>? contacts, bool? isolate}) {
    return SendMessageState(
      contacts: contacts ?? this.contacts,
      isolate: isolate ?? this.isolate,
    );
  }
}

class SendMessageNotifier extends Notifier<SendMessageState> {
  @override
  SendMessageState build() => const SendMessageState();

  /// 添加收信人，支持一次输入多个（空格或逗号分隔），重复的忽略。
  void add(String input) {
    final added = splitMessageUsers(input);
    if (added.isEmpty) return;
    state = state.copyWith(contacts: {...state.contacts, ...added}.toList());
  }

  void remove(String contact) {
    final newContacts = List<String>.from(state.contacts)
      ..removeWhere((element) => element == contact);
    state = state.copyWith(contacts: newContacts);
  }

  void setIsolate(bool value) {
    state = state.copyWith(isolate: value);
  }

  void clear() {
    state = const SendMessageState();
  }

  /// 发送失败时抛出异常，由页面提示。
  Future<void> send(int? mid, String subject, String content) {
    return ref
        .read(messageRepositoryProvider)
        .sendMessage(
          mid,
          state.contacts,
          subject,
          content,
          isolate: state.isolate,
        );
  }
}

/// 拆分用户输入的多个 UID / 用户名（空格、英文或中文逗号分隔）。
List<String> splitMessageUsers(String input) => input
    .split(RegExp(r'[\s,，]+'))
    .map((e) => e.trim())
    .where((e) => e.isNotEmpty)
    .toList();

final sendMessageProvider =
    NotifierProvider<SendMessageNotifier, SendMessageState>(
      SendMessageNotifier.new,
    );
