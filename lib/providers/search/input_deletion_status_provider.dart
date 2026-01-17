import 'package:flutter_riverpod/flutter_riverpod.dart';

class InputDeletionStatusNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void setVisible(bool val) {
    state = val;
  }
}

final inputDeletionStatusProvider =
    NotifierProvider<InputDeletionStatusNotifier, bool>(InputDeletionStatusNotifier.new);
