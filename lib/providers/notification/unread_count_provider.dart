import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_nga/data/entity/notification.dart';
import 'package:flutter_nga/providers/core/repository_providers.dart';
import 'package:flutter_nga/providers/home/home_drawer_header_provider.dart';

/// 「我的」页入口角标用的未读数。
///
/// - `uid`：计数所属账号；与当前登录账号不一致时不应显示
/// - `notifications`：提醒（回复 / 提及与系统通知）
/// - `messages`：短消息
typedef UnreadCounts = ({int? uid, int notifications, int messages});

extension UnreadCountsX on UnreadCounts {
  /// 总未读数，用于首页底部/侧边导航栏聚合角标
  int get total => notifications + messages;

  static const UnreadCounts none = (uid: null, notifications: 0, messages: 0);

  static UnreadCounts fromInfo(NotificationInfo info, {required int uid}) {
    return (
      uid: uid,
      notifications:
          (info.unreadReplyCount ?? 0) +
          (info.unreadSystemNotificationCount ?? 0),
      messages: info.unreadMessageCount ?? 0,
    );
  }
}

/// 未读数走网页版轮询用的 `__lib=noti&__act=if`，只返回计数，不拉提醒列表。
///
/// 计数带上所属账号 uid：页面只显示与当前账号一致的计数；请求返回时账号已经
/// 变化（登录、退出、切换）则丢弃结果，避免把上一个账号的未读数显示出来。
class UnreadCountNotifier extends Notifier<UnreadCounts> {
  @override
  UnreadCounts build() => UnreadCountsX.none;

  /// 当前账号的未读数；未登录或计数属于其他账号时为 [UnreadCountsX.none]
  UnreadCounts countsFor(int? uid) =>
      uid != null && state.uid == uid ? state : UnreadCountsX.none;

  /// 刷新未读数；角标只是提示，失败时保留旧值不打扰用户。
  Future<void> refresh() async {
    final uid = ref.read(homeDrawerHeaderProvider)?.uid;
    if (uid == null) {
      state = UnreadCountsX.none;
      return;
    }
    try {
      final info = await ref
          .read(messageRepositoryProvider)
          .getNotificationInfo();
      if (!ref.mounted || ref.read(homeDrawerHeaderProvider)?.uid != uid) {
        return;
      }
      state = UnreadCountsX.fromInfo(info, uid: uid);
    } catch (err) {
      debugPrint('刷新未读数失败: $err');
    }
  }

  /// 未登录或切换账号时清空
  void clear() => state = UnreadCountsX.none;
}

final unreadCountProvider = NotifierProvider<UnreadCountNotifier, UnreadCounts>(
  UnreadCountNotifier.new,
);
