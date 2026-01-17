import 'package:dio/dio.dart';
import 'package:flutter_nga/providers/core/repository_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SendMessageState {
  final List<String> contacts;

  const SendMessageState({
    this.contacts = const [],
  });

  SendMessageState copyWith({
    List<String>? contacts,
  }) {
    return SendMessageState(
      contacts: contacts ?? this.contacts,
    );
  }
}

class SendMessageNotifier extends Notifier<SendMessageState> {
  @override
  SendMessageState build() => const SendMessageState();

  void add(String contact) {
    final newContacts = List<String>.from(state.contacts)..add(contact);
    state = state.copyWith(contacts: newContacts);
  }

  void remove(String contact) {
    final newContacts = List<String>.from(state.contacts)
      ..removeWhere((element) => element == contact);
    state = state.copyWith(contacts: newContacts);
  }

  void clear() {
    state = const SendMessageState();
  }

  Future<void> send(int? mid, String subject, String content) async {
    try {
      final repository = ref.read(messageRepositoryProvider);
      return await repository.sendMessage(
          mid, state.contacts, subject, content);
    } catch (err) {
      if (err is DioException) {
        Fluttertoast.showToast(msg: err.message ?? '');
      } else {
        Fluttertoast.showToast(msg: err.toString());
      }
    }
  }
}

final sendMessageProvider =
    NotifierProvider<SendMessageNotifier, SendMessageState>(SendMessageNotifier.new);
