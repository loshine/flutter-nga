import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/data/entity/user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeDrawerHeaderNotifier extends Notifier<UserInfo?> {
  int _requestSeq = 0;

  @override
  UserInfo? build() => null;

  /// 账号切换或退出时同步清空旧页头并作废所有在途请求。
  void clear() {
    _requestSeq++;
    state = null;
  }

  Future<void> refresh() async {
    final seq = ++_requestSeq;
    final user = await Data().userRepository.getDefaultUser();
    if (!ref.mounted || seq != _requestSeq) return;
    if (user == null) {
      state = null;
      return;
    }
    final info = await Data().userRepository.getUserInfoByUid(user.uid);
    if (!ref.mounted || seq != _requestSeq) return;
    state = info;
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
