import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_nga/data/entity/notification.dart';
import 'package:flutter_nga/providers/core/repository_providers.dart';

/// 「我的」页入口角标用的未读数。
class UnreadCounts {
  const UnreadCounts({this.notifications = 0, this.messages = 0});

  /// 提醒：回复 / 提及与系统通知
  final int notifications;

  /// 短消息
  final int messages;

  static const none = UnreadCounts();

  factory UnreadCounts.fromInfo(NotificationInfo info) {
    return UnreadCounts(
      notifications:
          (info.unreadReplyCount ?? 0) +
          (info.unreadSystemNotificationCount ?? 0),
      messages: info.unreadMessageCount ?? 0,
    );
  }
}

/// 未读数走网页版轮询用的 `__lib=noti&__act=if`，只返回计数，不拉提醒列表。
class UnreadCountNotifier extends Notifier<UnreadCounts> {
  @override
  UnreadCounts build() => UnreadCounts.none;

  /// 刷新未读数；角标只是提示，失败时保留旧值不打扰用户。
  Future<void> refresh() async {
    try {
      final info = await ref
          .read(messageRepositoryProvider)
          .getNotificationInfo();
      if (ref.mounted) state = UnreadCounts.fromInfo(info);
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
