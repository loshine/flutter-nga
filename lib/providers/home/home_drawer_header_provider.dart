import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/data/entity/user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeDrawerHeaderNotifier extends Notifier<UserInfo?> {
  @override
  UserInfo? build() => null;

  Future<void> refresh() async {
    try {
      CacheUser? user = await Data().userRepository.getDefaultUser();
      if (user != null) {
        state = await Data().userRepository.getUserInfoByUid(user.uid);
      } else {
        state = null;
      }
    } catch (err) {
      rethrow;
    }
  }
}

final homeDrawerHeaderProvider =
    NotifierProvider<HomeDrawerHeaderNotifier, UserInfo?>(HomeDrawerHeaderNotifier.new);
