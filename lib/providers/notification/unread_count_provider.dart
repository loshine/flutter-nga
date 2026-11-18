import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_nga/data/entity/notification.dart';
import 'package:flutter_nga/providers/core/repository_providers.dart';
import 'package:flutter_nga/providers/home/home_drawer_header_provider.dart';

/// 「我的」页入口角标用的未读数。
class UnreadCounts {
  const UnreadCounts({this.uid, this.notifications = 0, this.messages = 0});

  /// 计数所属账号；与当前登录账号不一致时不应显示
  final int? uid;

  /// 提醒：回复 / 提及与系统通知
  final int notifications;

  /// 短消息
  final int messages;

  static const none = UnreadCounts();

  factory UnreadCounts.fromInfo(NotificationInfo info, {required int uid}) {
    return UnreadCounts(
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
  UnreadCounts build() => UnreadCounts.none;

  /// 当前账号的未读数；未登录或计数属于其他账号时为 [UnreadCounts.none]
  UnreadCounts countsFor(int? uid) =>
      uid != null && state.uid == uid ? state : UnreadCounts.none;

  /// 刷新未读数；角标只是提示，失败时保留旧值不打扰用户。
  Future<void> refresh() async {
    final uid = ref.read(homeDrawerHeaderProvider)?.uid;
    if (uid == null) {
      state = UnreadCounts.none;
      return;
    }
    try {
      final info = await ref
          .read(messageRepositoryProvider)
          .getNotificationInfo();
      if (!ref.mounted || ref.read(homeDrawerHeaderProvider)?.uid != uid) {
        return;
      }
      state = UnreadCounts.fromInfo(info, uid: uid);
    } catch (err) {
      debugPrint('刷新未读数失败: $err');
    }
  }

  /// 未登录或切换账号时清空
  void clear() => state = UnreadCounts.none;
}

final unreadCountProvider = NotifierProvider<UnreadCountNotifier, UnreadCounts>(
  UnreadCountNotifier.new,
);
