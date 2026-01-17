import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeIndexNotifier extends StateNotifier<int> {
  HomeIndexNotifier() : super(0);

  void setIndex(int index) {
    state = index;
  }
}

final homeIndexProvider = StateNotifierProvider<HomeIndexNotifier, int>((ref) {
  return HomeIndexNotifier();
});
