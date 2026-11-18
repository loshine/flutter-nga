import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter_nga/data/entity/user.dart';

int? _parseInt(dynamic value) {
  if (value is int) {
    return value;
  }
  if (value is String) {
    return int.tryParse(value);
  }
  if (value is num) {
    return value.toInt();
  }
  return null;
}

/// 对话参与者。
class MessageParticipant {
  final int uid;
  final String username;

  const MessageParticipant(this.uid, this.username);

  @override
  bool operator ==(Object other) =>
      other is MessageParticipant &&
      other.uid == uid &&
      other.username == username;

  @override
  int get hashCode => Object.hash(uid, username);

  @override
  String toString() => 'MessageParticipant($uid, $username)';
}

/// 解析网页版以 `\t` 分隔的 `uid\tusername\tuid\tusername…` 参与者串
/// （对话列表的 `all_user`、消息详情的 `allUsers`）。
List<MessageParticipant> parseMessageParticipants(dynamic value) {
  if (value == null) return const [];
  final parts = value.toString().split('\t');
  final result = <MessageParticipant>[];
  for (var i = 0; i + 1 < parts.length; i += 2) {
    final uid = int.tryParse(parts[i].trim());
    if (uid == null) continue;
    result.add(MessageParticipant(uid, parts[i + 1]));
  }
  return result;
}

/// 网页版 `_long2ip`：IP 可能以无符号 32 位整数返回。
String? _long2ip(dynamic value) {
  if (value == null) return null;
  if (value is String && value.contains('.')) return value;
  final ip = _parseInt(value);
  if (ip == null || ip == 0) return null;
  final unsigned = ip & 0xFFFFFFFF;
  return [
    unsigned >> 24 & 0xFF,
    unsigned >> 16 & 0xFF,
    unsigned >> 8 & 0xFF,
    unsigned & 0xFF,
  ].join('.');
}

/// 消息 `data` 字段可能是数组，也可能是以下标为 key 的对象。
dynamic _dataAt(dynamic data, int index) {
  if (data is List) return index < data.length ? data[index] : null;
  if (data is Map) return data['$index'] ?? data[index];
  return null;
}

class Message {
  /// 消息被隐藏（网页版显示 [隐藏]）。
  static const BIT_HIDDEN = 512;

  final int? id;
  final String? subject;
  final String content;
  final int? from;
  final int? time;
  final User user;
  final dynamic data;
  final int bit;

  Message(
    this.id,
    this.subject,
    this.content,
    this.from,
    this.time,
    this.user,
    this.data, {
    this.bit = 0,
  });

  bool get isHidden => bit & BIT_HIDDEN != 0;

  /// 发送者 IP（`data[1]`），部分账号或旧消息没有。
  String? get ip => _long2ip(_dataAt(data, 1));

  factory Message.fromJson(Map map, List<User> userList) {
    final from = _parseInt(map['from']);
    var content = map['content']?.toString() ?? '';
    if (from == null || from == 0) {
      // 网页版同款修正：系统消息里的主题链接写成了 [url]/read.php?tid=1][b]
      content = content.replaceAllMapped(
        RegExp(r'\[url\]/read\.php\?tid=(\d+)\]\[b\]'),
        (m) => '[url=/read.php?tid=${m[1]}][b]',
      );
    }
    return Message(
      _parseInt(map['id']),
      map['subject']?.toString(),
      content,
      from,
      _parseInt(map['time']),
      // userInfo 里可能缺少发信人（系统消息、已注销用户等），此时用占位用户，
      // 避免 firstWhere 抛 StateError 导致整页消息解析失败。
      userList.firstWhereOrNull((e) => e.uid == from) ?? placeholderUser(from),
      map['data'],
      bit: _parseInt(map['bit']) ?? 0,
    );
  }

  /// [userList] 中找不到发信人时使用的占位用户。
  @visibleForTesting
  static User placeholderUser(int? uid) =>
      User(uid: uid, username: uid == null || uid == 0 ? '系统' : 'UID:$uid');
}

class MessageListData {
  /// `subjectBit` 中表示「对话参与者的回复互相不可见」的位。
  static const SUBJECT_BIT_ISOLATED = 32;

  final int? length;
  final int? nextPage;
  final int? currentPage;
  final int? subjectBit;
  final int? starterUid;
  final List<Message> messageList;
  final List<User> userList;

  /// 参与对话的用户。
  final List<MessageParticipant> participants;

  bool get hasNext => nextPage != null;

  bool get isIsolated => (subjectBit ?? 0) & SUBJECT_BIT_ISOLATED != 0;

  MessageListData(
    this.length,
    this.nextPage,
    this.currentPage,
    this.subjectBit,
    this.starterUid,
    this.messageList,
    this.userList, {
    this.participants = const [],
  });

  // final String allUsers;

  factory MessageListData.fromJson(Map map) {
    dynamic nextPage = map['nextPage'];
    Map userMap = map['userInfo'] ?? {};
    List<User> userList = userMap.entries
        .where((e) => int.tryParse(e.key) != null)
        .map((e) => User.fromJson(e.value))
        .toList();
    // 消息数据在 allmsgs 字段中
    Map allMsgsMap = map['allmsgs'] ?? {};
    List<Message> messageList = allMsgsMap.entries
        .where((e) => int.tryParse(e.key) != null)
        .map((e) => Message.fromJson(e.value, userList))
        .toList();
    // 与网页版一致：顶层没有 allUsers 时取第一条消息的 data[2]
    var participants = parseMessageParticipants(map['allUsers']);
    if (participants.isEmpty) {
      final first = allMsgsMap['0'] ?? allMsgsMap[0];
      if (first is Map) {
        participants = parseMessageParticipants(_dataAt(first['data'], 2));
      }
    }
    return MessageListData(
      _parseInt(map['length']),
      _parseInt(nextPage),
      _parseInt(map['currentPage']),
      _parseInt(map['subjectBit']),
      _parseInt(map['starterUid']),
      messageList,
      userList,
      participants: participants,
    );
  }
}
