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

class Message {
  final int? id;
  final String? subject;
  final String content;
  final int? from;
  final int? time;
  final User user;
  final dynamic data;

  Message(
    this.id,
    this.subject,
    this.content,
    this.from,
    this.time,
    this.user,
    this.data,
  );

  factory Message.fromJson(Map map, List<User> userList) {
    final from = _parseInt(map['from']);
    return Message(
      _parseInt(map['id']),
      map['subject']?.toString(),
      map['content']?.toString() ?? '',
      from,
      _parseInt(map['time']),
      // userInfo 里可能缺少发信人（系统消息、已注销用户等），此时用占位用户，
      // 避免 firstWhere 抛 StateError 导致整页消息解析失败。
      userList.firstWhereOrNull((e) => e.uid == from) ?? placeholderUser(from),
      map['data'],
    );
  }

  /// [userList] 中找不到发信人时使用的占位用户。
  @visibleForTesting
  static User placeholderUser(int? uid) => User(
        uid: uid,
        username: uid == null || uid == 0 ? '系统' : 'UID:$uid',
      );
}

class MessageListData {
  final int? length;
  final int? nextPage;
  final int? currentPage;
  final int? subjectBit;
  final int? starterUid;
  final List<Message> messageList;
  final List<User> userList;

  bool get hasNext => nextPage != null;

  MessageListData(
    this.length,
    this.nextPage,
    this.currentPage,
    this.subjectBit,
    this.starterUid,
    this.messageList,
    this.userList,
  );

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
    return MessageListData(
      _parseInt(map['length']),
      _parseInt(nextPage),
      _parseInt(map['currentPage']),
      _parseInt(map['subjectBit']),
      _parseInt(map['starterUid']),
      messageList,
      userList,
    );
  }
}
