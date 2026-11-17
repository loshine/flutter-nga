import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_nga/data/entity/notification.dart';
import 'package:flutter_nga/providers/core/repository_providers.dart';

class NotificationListState {
  /// 按时间倒序排列的全部提醒。
  final List<NgaNotification> notifications;
  final int unread;

  const NotificationListState({this.notifications = const [], this.unread = 0});

  /// 按 [NotificationCategory] 声明顺序分组，空分组不返回，组内保持时间倒序。
  List<MapEntry<NotificationCategory, List<NgaNotification>>> get sections {
    final grouped = <NotificationCategory, List<NgaNotification>>{};
    for (final notification in notifications) {
      grouped.putIfAbsent(notification.category, () => []).add(notification);
    }
    return [
      for (final category in NotificationCategory.values)
        if (grouped[category] != null) MapEntry(category, grouped[category]!),
    ];
  }

  NotificationListState copyWith({
    List<NgaNotification>? notifications,
    int? unread,
  }) {
    return NotificationListState(
      notifications: notifications ?? this.notifications,
      unread: unread ?? this.unread,
    );
  }
}

class NotificationListNotifier extends Notifier<NotificationListState> {
  @override
  NotificationListState build() => const NotificationListState();

  Future<NotificationListState> refresh() async {
    final repository = ref.read(messageRepositoryProvider);
    final data = await repository.getNotificationList();
    state = NotificationListState(
      notifications: data.notifications,
      unread: data.unread ?? 0,
    );
    return state;
  }

  /// 清空服务端信箱并清空本地列表。
  Future<void> clear() async {
    await ref.read(messageRepositoryProvider).clearNotifications();
    state = const NotificationListState();
  }

  /// 不再提示该主题 / 回复的回复或评论。
  Future<void> setNoHint(NoHintTarget target) async {
    await ref
        .read(messageRepositoryProvider)
        .setNotificationNoHint(target.tid, target.pid);
  }
}

final notificationListProvider =
    NotifierProvider<NotificationListNotifier, NotificationListState>(
      NotificationListNotifier.new,
    );
