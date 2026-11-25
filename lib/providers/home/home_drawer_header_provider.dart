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
    NotifierProvider<HomeDrawerHeaderNotifier, UserInfo?>(
      HomeDrawerHeaderNotifier.new,
    );

/// 默认账号变更世代计数器：切换默认账号、登录新账号或退出账号时同步递增，
/// 用于强制重置工作区中账号隔离页面并丢弃旧账号在途响应。
class AccountSessionVersionNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void bump() => state = state + 1;
}

final accountSessionVersionProvider =
    NotifierProvider<AccountSessionVersionNotifier, int>(
      AccountSessionVersionNotifier.new,
    );
