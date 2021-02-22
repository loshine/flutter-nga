class NotificationInfo {
  final bool hasUnreadMessage;
  final int lastTime;
  final int unreadReplyCount;
  final int unreadMessageCount;
  final int unreadSystemNotificationCount;

  NotificationInfo({
    this.hasUnreadMessage,
    this.lastTime,
    this.unreadReplyCount,
    this.unreadMessageCount,
    this.unreadSystemNotificationCount,
  });

  factory NotificationInfo.fromJson(Map<String, dynamic> map) {
    return NotificationInfo(
      hasUnreadMessage: int.tryParse(map['0']) > 0,
      lastTime: int.tryParse(map['1']),
      unreadReplyCount: int.tryParse(map['2']),
      unreadMessageCount: int.tryParse(map['3']),
      unreadSystemNotificationCount: int.tryParse(map['4']),
    );
  }
}
