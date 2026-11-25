int? _parseInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

String? _parseString(dynamic value) {
  if (value == null) return null;
  final text = value.toString();
  return text.isEmpty ? null : text;
}

class NotificationInfo {
  final bool? hasUnreadMessage;
  final int? lastTime;
  final int? unreadReplyCount;
  final int? unreadMessageCount;
  final int? unreadSystemNotificationCount;

  NotificationInfo({
    this.hasUnreadMessage,
    this.lastTime,
    this.unreadReplyCount,
    this.unreadMessageCount,
    this.unreadSystemNotificationCount,
  });

  factory NotificationInfo.fromJson(Map<String, dynamic> map) {
    return NotificationInfo(
      hasUnreadMessage: (_parseInt(map['0']) ?? 0) > 0,
      lastTime: _parseInt(map['1']),
      unreadReplyCount: _parseInt(map['2']),
      unreadMessageCount: _parseInt(map['3']),
      unreadSystemNotificationCount: _parseInt(map['4']),
    );
  }
}

/// 提醒在列表页中的分组，按类型划分（服务端的 0/1/2 分桶与类型并不一一对应，
/// 例如举报提醒在网页版中是放在消息分桶里返回的）。
enum NotificationCategory {
  reply('回复与提及'),
  message('短消息'),
  moderation('版务'),
  system('系统');

  const NotificationCategory(this.label);

  final String label;
}

/// 点击提醒后的跳转目标。
sealed class NotificationTarget {
  const NotificationTarget();
}

class TopicTarget extends NotificationTarget {
  final int tid;

  const TopicTarget(this.tid);

  @override
  bool operator ==(Object other) => other is TopicTarget && other.tid == tid;

  @override
  int get hashCode => tid.hashCode;

  @override
  String toString() => 'TopicTarget($tid)';
}

class ReplyTarget extends NotificationTarget {
  final int tid;
  final int pid;

  const ReplyTarget(this.tid, this.pid);

  @override
  bool operator ==(Object other) =>
      other is ReplyTarget && other.tid == tid && other.pid == pid;

  @override
  int get hashCode => Object.hash(tid, pid);

  @override
  String toString() => 'ReplyTarget($tid, $pid)';
}

class ConversationTarget extends NotificationTarget {
  final int mid;

  const ConversationTarget(this.mid);

  @override
  bool operator ==(Object other) =>
      other is ConversationTarget && other.mid == mid;

  @override
  int get hashCode => mid.hashCode;

  @override
  String toString() => 'ConversationTarget($mid)';
}

class ForumTarget extends NotificationTarget {
  final int fid;

  const ForumTarget(this.fid);

  @override
  bool operator ==(Object other) => other is ForumTarget && other.fid == fid;

  @override
  int get hashCode => fid.hashCode;

  @override
  String toString() => 'ForumTarget($fid)';
}

/// 「不再提示」的作用对象：pid 为 0 时表示整个主题。
typedef NoHintTarget = ({int tid, int pid});

extension NoHintTargetX on NoHintTarget {
  bool get isTopic => pid == 0;
}

/// 列表展示用的文案：`actor` 加粗显示，`detail` 作为第二行（主题标题、举报理由等）。
typedef NotificationDescription = ({
  String? actor,
  String action,
  String? detail,
});

/// NGA 提醒（`__lib=noti&__act=get_all`），字段下标与类型取自网页版
/// `js_notification.js` 的 `KEY` 定义。
class NgaNotification {
  static const TYPE_REPLY_TOPIC = 1;
  static const TYPE_REPLY_REPLY = 2;
  static const TYPE_COMMENT_TOPIC = 3;
  static const TYPE_COMMENT_REPLY = 4;
  static const TYPE_KEYWORD_WATCH_TOPIC = 5;
  static const TYPE_KEYWORD_WATCH_REPLY = 6;
  static const TYPE_MENTION_TOPIC = 7;
  static const TYPE_MENTION_REPLY = 8;
  static const TYPE_IP_CHANGE = 9;
  static const TYPE_MESSAGE_NEW = 10;
  static const TYPE_MESSAGE_REPLY = 11;
  static const TYPE_MESSAGE_ADD = 12;
  static const TYPE_REPORT_TOPIC = 13;
  static const TYPE_REPORT_REPLY = 14;
  static const TYPE_RECOMMEND_POST = 15;
  static const TYPE_KEYWORD_WATCH = 16;
  static const TYPE_UPVOTE = 17;

  /// 0 类型
  final int type;

  /// 1 来源 uid
  final int? fromUid;

  /// 2 来源用户名
  final String? fromUsername;

  /// 3 目标 uid
  final int? toUid;

  /// 4 目标用户名
  final String? toUsername;

  /// 5 文本，一般是主题标题
  final String? text;

  /// 6 关联 id：主题 tid；短消息为 mid；类型 16 为 fid
  final int aboutId;

  /// 7 关联 id 2：一般是触发提醒的回复 pid
  final int aboutId2;

  /// 8 关联 id 3：一般是被回复 / 评论 / 评价的「你的回复」pid
  final int aboutId3;

  /// 9 时间（秒）
  final int time;

  /// 10 关联 id 4：回复所在页数
  final int aboutId4;

  /// 11 文本 2：举报理由
  final String? text2;

  /// 13 文本 3：举报分类
  final String? text3;

  const NgaNotification({
    required this.type,
    this.fromUid,
    this.fromUsername,
    this.toUid,
    this.toUsername,
    this.text,
    this.aboutId = 0,
    this.aboutId2 = 0,
    this.aboutId3 = 0,
    this.time = 0,
    this.aboutId4 = 0,
    this.text2,
    this.text3,
  });

  factory NgaNotification.fromJson(Map map) {
    return NgaNotification(
      type: _parseInt(map['0']) ?? 0,
      fromUid: _parseInt(map['1']),
      fromUsername: _parseString(map['2']),
      toUid: _parseInt(map['3']),
      toUsername: _parseString(map['4']),
      text: _parseString(map['5']),
      aboutId: _parseInt(map['6']) ?? 0,
      aboutId2: _parseInt(map['7']) ?? 0,
      aboutId3: _parseInt(map['8']) ?? 0,
      time: _parseInt(map['9']) ?? 0,
      aboutId4: _parseInt(map['10']) ?? 0,
      text2: _parseString(map['11']),
      text3: _parseString(map['13']),
    );
  }

  bool get hasActor => fromUid != null && fromUid! > 0;

  NotificationCategory get category {
    switch (type) {
      case TYPE_REPLY_TOPIC:
      case TYPE_REPLY_REPLY:
      case TYPE_COMMENT_TOPIC:
      case TYPE_COMMENT_REPLY:
      case TYPE_MENTION_TOPIC:
      case TYPE_MENTION_REPLY:
      case TYPE_RECOMMEND_POST:
      case TYPE_UPVOTE:
        return NotificationCategory.reply;
      case TYPE_MESSAGE_NEW:
      case TYPE_MESSAGE_REPLY:
      case TYPE_MESSAGE_ADD:
        return NotificationCategory.message;
      case TYPE_KEYWORD_WATCH_TOPIC:
      case TYPE_KEYWORD_WATCH_REPLY:
      case TYPE_KEYWORD_WATCH:
      case TYPE_REPORT_TOPIC:
      case TYPE_REPORT_REPLY:
        return NotificationCategory.moderation;
      default:
        return NotificationCategory.system;
    }
  }

  NotificationDescription describe() {
    final actor = hasActor ? (fromUsername ?? 'UID:$fromUid') : null;
    final subject = text;
    return switch (type) {
      TYPE_REPLY_TOPIC => (actor: actor, action: '回复了你的主题', detail: subject),
      TYPE_REPLY_REPLY => (
        actor: actor,
        action: '回复了你在主题中的回复',
        detail: subject,
      ),
      TYPE_COMMENT_TOPIC => (actor: actor, action: '评论了你的主题', detail: subject),
      TYPE_COMMENT_REPLY => (
        actor: actor,
        action: '评论了你在主题中的回复',
        detail: subject,
      ),
      TYPE_MENTION_TOPIC => (actor: actor, action: '在主题中提到了你', detail: subject),
      TYPE_MENTION_REPLY => (
        actor: actor,
        action: '在主题中的回复中提到了你',
        detail: subject,
      ),
      TYPE_RECOMMEND_POST => (
        actor: actor,
        action: aboutId2 != 0 ? '评价了你在主题中的回复并使用了道具' : '评价了你在主题中的发言并使用了道具',
        detail: subject,
      ),
      TYPE_UPVOTE => (
        actor: null,
        action: aboutId2 != 0 ? '你在主题中的回复获得了支持或反对' : '你的主题获得了支持或反对',
        detail: subject,
      ),
      TYPE_MESSAGE_NEW => (actor: actor, action: '发起了新的对话', detail: subject),
      TYPE_MESSAGE_REPLY => (actor: actor, action: '回复了对话', detail: subject),
      TYPE_MESSAGE_ADD => (actor: actor, action: '邀请了新用户加入对话', detail: subject),
      TYPE_KEYWORD_WATCH_TOPIC => (
        actor: actor,
        action: '发布的主题触发了关键词监视',
        detail: subject,
      ),
      TYPE_KEYWORD_WATCH_REPLY => (
        actor: actor,
        action: '在主题中的回复触发了关键词监视',
        detail: subject,
      ),
      TYPE_KEYWORD_WATCH => (
        actor: null,
        action: 'FID:$aboutId 中的发帖触发了关键词监视',
        detail: null,
      ),
      TYPE_REPORT_TOPIC => (
        actor: actor,
        action: '举报了主题',
        detail: _reportDetail(),
      ),
      TYPE_REPORT_REPLY => (
        actor: actor,
        action: '举报了主题中的回复',
        detail: _reportDetail(),
      ),
      TYPE_IP_CHANGE => (
        actor: null,
        action: '你的账号可能记录到新的 IP',
        detail: '可在网页版「访问记录」中查看详细信息',
      ),
      _ => (actor: actor, action: '未知提醒（类型 $type）', detail: subject),
    };
  }

  String? _reportDetail() {
    final buffer = StringBuffer();
    if (text3 != null) buffer.write('[$text3] ');
    if (text != null) buffer.write(text);
    if (text2 != null) {
      if (buffer.isNotEmpty) buffer.write('\n');
      buffer.write('理由：$text2');
    }
    return buffer.isEmpty ? null : buffer.toString();
  }

  /// 点击后的跳转目标，与网页版提醒中的主链接一致。
  NotificationTarget? get target {
    switch (type) {
      case TYPE_REPLY_TOPIC:
      case TYPE_REPLY_REPLY:
      case TYPE_MENTION_REPLY:
      case TYPE_KEYWORD_WATCH_REPLY:
      case TYPE_REPORT_REPLY:
      case TYPE_RECOMMEND_POST:
      case TYPE_UPVOTE:
        if (aboutId2 != 0) return ReplyTarget(aboutId, aboutId2);
        return aboutId != 0 ? TopicTarget(aboutId) : null;
      case TYPE_COMMENT_REPLY:
        // 评论挂在被评论的回复下，网页版链接到 aboutId3
        if (aboutId3 != 0) return ReplyTarget(aboutId, aboutId3);
        return aboutId != 0 ? TopicTarget(aboutId) : null;
      case TYPE_COMMENT_TOPIC:
      case TYPE_MENTION_TOPIC:
      case TYPE_KEYWORD_WATCH_TOPIC:
      case TYPE_REPORT_TOPIC:
        return aboutId != 0 ? TopicTarget(aboutId) : null;
      case TYPE_MESSAGE_NEW:
      case TYPE_MESSAGE_REPLY:
      case TYPE_MESSAGE_ADD:
        return aboutId != 0 ? ConversationTarget(aboutId) : null;
      case TYPE_KEYWORD_WATCH:
        return aboutId != 0 ? ForumTarget(aboutId) : null;
      default:
        return null;
    }
  }

  /// 主题 tid（有主题关联时），用于长按菜单中的「进入主题」。
  int? get topicId {
    switch (category) {
      case NotificationCategory.reply:
      case NotificationCategory.moderation:
        if (type == TYPE_KEYWORD_WATCH) return null;
        return aboutId != 0 ? aboutId : null;
      default:
        return null;
    }
  }

  /// 「不再提示此主题 / 回复的回复或评论」的对象，对应网页版的 `_TNO` / `_RNO`。
  NoHintTarget? get noHintTarget {
    if (aboutId == 0) return null;
    switch (type) {
      case TYPE_REPLY_TOPIC:
      case TYPE_COMMENT_TOPIC:
        return (tid: aboutId, pid: 0);
      case TYPE_REPLY_REPLY:
      case TYPE_COMMENT_REPLY:
      case TYPE_RECOMMEND_POST:
        return aboutId3 != 0 ? (tid: aboutId, pid: aboutId3) : null;
      case TYPE_UPVOTE:
        return (tid: aboutId, pid: aboutId2);
      default:
        return null;
    }
  }
}

class NotificationInfoListData {
  /// 按时间倒序排列的全部提醒。
  final List<NgaNotification> notifications;
  final int? unread;

  const NotificationInfoListData({this.notifications = const [], this.unread});

  factory NotificationInfoListData.fromJson(Map<String, dynamic> map) {
    final notifications = <NgaNotification>[];
    for (final key in const ['0', '1', '2']) {
      final list = map[key];
      if (list is! List) continue;
      for (final element in list) {
        if (element is Map) {
          notifications.add(NgaNotification.fromJson(element));
        }
      }
    }
    notifications.sort((a, b) => b.time.compareTo(a.time));
    return NotificationInfoListData(
      notifications: notifications,
      unread: _parseInt(map['unread']),
    );
  }
}
