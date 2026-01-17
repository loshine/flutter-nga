import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeIndexNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void setIndex(int index) {
    state = index;
  }
}

final homeIndexProvider = NotifierProvider<HomeIndexNotifier, int>(HomeIndexNotifier.new);
