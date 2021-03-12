import 'package:flutter_nga/data/entity/user.dart';

class Message {
  final int? id;
  final String? subject;
  final String? content;
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
    return Message(
      map['id'],
      map['subject'],
      map['content'],
      map['from'],
      map['time'],
      userList.firstWhere((e) => e.uid == map['from'], orElse: null),
      map['data'],
    );
  }
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
    Map userMap = map['userInfo'];
    List<User> userList = userMap.entries
        .where((e) => int.tryParse(e.key) != null)
        .map((e) => User.fromJson(e.value))
        .toList();
    List<Message> messageList = map.entries
        .where((e) => int.tryParse(e.key) != null)
        .map((e) => Message.fromJson(e.value, userList))
        .toList();
    return MessageListData(
      map['length'],
      nextPage is int ? nextPage : null,
      map['currentPage'],
      map['subjectBit'],
      map['starterUid'],
      messageList,
      userList,
    );
  }
}
