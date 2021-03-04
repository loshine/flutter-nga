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

class NotificationInfoListData {
  final List<ReplyNotification> replyNotificationList;
  final List<MessageNotification> messageNotificationList;
  final List<SystemNotification> systemNotificationList;
  final int unread;

  NotificationInfoListData({
    this.replyNotificationList,
    this.messageNotificationList,
    this.systemNotificationList,
    this.unread,
  });

  factory NotificationInfoListData.fromJson(Map<String, dynamic> map) {
    final replyNotificationList = <ReplyNotification>[];
    if (map['0'] != null) {
      (map['0'] as List<dynamic>).forEach((element) {
        replyNotificationList.add(ReplyNotification.fromJson(element));
      });
    }
    final messageNotificationList = <MessageNotification>[];
    if (map['1'] != null) {
      (map['1'] as List<dynamic>).forEach((element) {
        messageNotificationList.add(MessageNotification.fromJson(element));
      });
    }
    final systemNotificationList = <SystemNotification>[];
    if (map['2'] != null) {
      (map['2'] as List<dynamic>).forEach((element) {
        systemNotificationList.add(SystemNotification.fromJson(element));
      });
    }
    return NotificationInfoListData(
      replyNotificationList: replyNotificationList,
      messageNotificationList: messageNotificationList,
      systemNotificationList: systemNotificationList,
      unread: map['unread'],
    );
  }
}

abstract class NgaNotification {
  int getType();

  int getSourceUid();

  String getSourceUsername();

  int getTime();
}

class ReplyNotification implements NgaNotification {
  /// 回复主题
  static const TYPE_REPLY_TOPIC = 1;

  /// 回复回复
  static const TYPE_REPLY_REPLY = 2;

  /// 评论主题
  static const TYPE_COMMENT_TOPIC = 3;

  /// 评论回复
  static const TYPE_COMMENT_REPLY = 4;

  /// 在主题中被 @
  static const TYPE_AT_IN_TOPIC = 7;

  /// 在回复中被 @
  static const TYPE_AT_IN_REPLY = 8;

  /// 主题或回复被评价并使用道具(对主题时回复id为0)
  static const TYPE_RATED = 15;

  /// 0
  final int type;

  /// 1 来源 uid
  final int sourceUid;

  /// 2 来源 username
  final String sourceUsername;

  /// 3 目标 uid
  final int targetUid;

  /// 4 目标 username
  final String targetUsername;

  /// 5 相关主题标题
  final String topicSubject;

  /// 6 相关id1  类别是1 2 3 4 7 8 15时是主题tid
  final int tid;

  /// 7 相关 id2 类别是1 2 4 8 时是回复pid
  final int pid;

  /// 8 相关 id3 类别是2 4 15时是被回复或评论或评价 的 回复pid
  final int targetReplyPid;

  /// 9 时间
  final int time;

  /// 10 类别是1 2 4 8时是回复所在的页数
  final int page;

  ReplyNotification({
    this.type,
    this.sourceUid,
    this.sourceUsername,
    this.targetUid,
    this.targetUsername,
    this.topicSubject,
    this.tid,
    this.pid,
    this.targetReplyPid,
    this.time,
    this.page,
  });

  factory ReplyNotification.fromJson(Map<String, dynamic> map) {
    return ReplyNotification(
      type: map['0'],
      sourceUid: map['1'],
      sourceUsername: map['2'],
      targetUid: map['3'],
      targetUsername: map['4'],
      topicSubject: map['5'],
      tid: map['6'],
      pid: map['7'],
      targetReplyPid: map['8'],
      time: map['9'],
      page: map['10'],
    );
  }

  @override
  int getSourceUid() => sourceUid;

  @override
  String getSourceUsername() => sourceUsername;

  @override
  int getTime() => time;

  @override
  int getType() => type;
}

class MessageNotification implements NgaNotification {
  /// 新短消息
  static const TYPE_NEW = 10;

  /// 短消息回复
  static const TYPE_REPLY = 11;

  /// 被加入到多人消息中
  static const TYPE_ADDED_MULTI = 12;

  /// 0 类型
  final int type;

  /// 1 来源 uid
  final int sourceUid;

  /// 2 来源 username
  final String sourceUsername;

  /// 6 mid
  final int mid;

  /// 9 时间
  final int time;

  MessageNotification({
    this.type,
    this.sourceUid,
    this.sourceUsername,
    this.mid,
    this.time,
  });

  factory MessageNotification.fromJson(Map<String, dynamic> map) {
    return MessageNotification(
      type: map['0'],
      sourceUid: map['1'],
      sourceUsername: map['2'],
      mid: map['6'],
      time: map['9'],
    );
  }

  @override
  int getSourceUid() => sourceUid;

  @override
  String getSourceUsername() => sourceUsername;

  @override
  int getTime() => time;

  @override
  int getType() => type;
}

class SystemNotification implements NgaNotification {
  /// 主题关键词触发，版主功能
  static const TYPE_TOPIC_KEYWORD = 5;

  /// 回复关键词触发，版主功能
  static const TYPE_REPLY_KEYWORD = 6;

  /// ip 变化
  static const TYPE_IP_CHANGED = 9;

  /// 举报主题, 版主功能
  static const TYPE_REPORT_TOPIC = 13;

  /// 举报回复, 版主功能
  static const TYPE_REPORT_REPLY = 14;

  /// 关键词监视, 版主功能
  static const TYPE_SELF_KEYWORD = 16;

  /// 0
  final int type;

  /// 1 来源 uid
  final int sourceUid;

  /// 2 来源 username
  final String sourceUsername;

  /// 5 相关主题标题
  final String topicSubject;

  /// 6 相关id1  类别是1 2 3 4 7 8 15时是主题tid
  final int tid;

  /// 7 相关 id2 类别是1 2 4 8 时是回复pid
  final int pid;

  /// 9 时间
  final int time;

  /// 10 类别是1 2 4 8时是回复所在的页数
  final int page;

  SystemNotification({
    this.type,
    this.sourceUid,
    this.sourceUsername,
    this.topicSubject,
    this.tid,
    this.pid,
    this.time,
    this.page,
  });

  factory SystemNotification.fromJson(Map<String, dynamic> map) {
    return SystemNotification(
      type: map['0'],
      sourceUid: map['1'],
      sourceUsername: map['2'],
      topicSubject: map['5'],
      tid: map['6'],
      pid: map['7'],
      time: map['9'],
      page: map['10'],
    );
  }

  @override
  int getSourceUid() => sourceUid;

  @override
  String getSourceUsername() => sourceUsername;

  @override
  int getTime() => time;

  @override
  int getType() => type;

  @override
  String toString() {
    return 'SystemNotification{type: $type, sourceUid: $sourceUid, sourceUsername: $sourceUsername, topicSubject: $topicSubject, tid: $tid, pid: $pid, time: $time, page: $page}';
  }
}
