import 'package:flutter_riverpod/flutter_riverpod.dart';

class InputDeletionStatusNotifier extends StateNotifier<bool> {
  InputDeletionStatusNotifier() : super(false);

  void setVisible(bool val) {
    state = val;
  }
}

final inputDeletionStatusProvider =
    StateNotifierProvider<InputDeletionStatusNotifier, bool>((ref) {
  return InputDeletionStatusNotifier();
});
