import 'package:flutter_nga/data/entity/notification.dart';
import 'package:flutter_nga/providers/core/repository_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationListState {
  final List<ReplyNotification> replyNotificationList;
  final List<MessageNotification> messageNotificationList;
  final List<SystemNotification> systemNotificationList;
  final int unread;

  const NotificationListState({
    this.replyNotificationList = const [],
    this.messageNotificationList = const [],
    this.systemNotificationList = const [],
    this.unread = 0,
  });

  factory NotificationListState.initial() => const NotificationListState(
        replyNotificationList: [],
        messageNotificationList: [],
        systemNotificationList: [],
        unread: 0,
      );

  int get count =>
      3 +
      replyNotificationList.length +
      messageNotificationList.length +
      systemNotificationList.length;

  NotificationListState copyWith({
    List<ReplyNotification>? replyNotificationList,
    List<MessageNotification>? messageNotificationList,
    List<SystemNotification>? systemNotificationList,
    int? unread,
  }) {
    return NotificationListState(
      replyNotificationList:
          replyNotificationList ?? this.replyNotificationList,
      messageNotificationList:
          messageNotificationList ?? this.messageNotificationList,
      systemNotificationList:
          systemNotificationList ?? this.systemNotificationList,
      unread: unread ?? this.unread,
    );
  }
}

class NotificationListNotifier extends Notifier<NotificationListState> {
  @override
  NotificationListState build() => NotificationListState.initial();

  Future<NotificationListState> refresh() async {
    try {
      final repository = ref.read(messageRepositoryProvider);
      final data = await repository.getNotificationList();
      state = NotificationListState(
        replyNotificationList: data.replyNotificationList ?? [],
        messageNotificationList: data.messageNotificationList ?? [],
        systemNotificationList: data.systemNotificationList ?? [],
        unread: data.unread ?? 0,
      );
      return state;
    } catch (err) {
      rethrow;
    }
  }
}

final notificationListProvider =
    NotifierProvider<NotificationListNotifier, NotificationListState>(
        NotificationListNotifier.new);
