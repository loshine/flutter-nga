import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_nga/data/entity/message.dart';
import 'package:flutter_nga/data/entity/user.dart';

void main() {
  group('Message.fromJson', () {
    final users = [
      User(uid: 100, username: 'alice'),
      User(uid: 200, username: 'bob'),
    ];

    test('能找到发信人时使用 userList 中的用户', () {
      final message = Message.fromJson(
        {'id': '1', 'content': 'hi', 'from': '200', 'time': 1700000000},
        users,
      );

      expect(message.from, 200);
      expect(message.user, same(users[1]));
      expect(message.content, 'hi');
    });

    test('userList 中缺少发信人时用占位用户，不抛异常', () {
      final message = Message.fromJson(
        {'id': 2, 'content': 'hello', 'from': 999},
        users,
      );

      expect(message.user.uid, 999);
      expect(message.user.username, 'UID:999');
    });

    test('发信人为 0 或缺失时显示为系统', () {
      final fromZero = Message.fromJson({'content': 'x', 'from': 0}, users);
      final noFrom = Message.fromJson({'content': 'y'}, const []);

      expect(fromZero.user.username, '系统');
      expect(noFrom.from, isNull);
      expect(noFrom.user.username, '系统');
    });

    test('content 为 null 时回退为空字符串', () {
      final message = Message.fromJson({'from': 100}, users);

      expect(message.content, '');
      expect(message.user, same(users[0]));
    });
  });

  group('MessageListData.fromJson', () {
    test('部分消息的发信人缺失时整页仍能解析', () {
      final data = MessageListData.fromJson({
        'currentPage': 1,
        'userInfo': {
          '100': {'uid': 100, 'username': 'alice'},
        },
        'allmsgs': {
          '0': {'id': 1, 'content': 'from alice', 'from': 100},
          '1': {'id': 2, 'content': 'from unknown', 'from': 404},
          '2': {'id': 3, 'content': 'from system', 'from': 0},
        },
      });

      expect(data.messageList, hasLength(3));
      expect(
        data.messageList.map((m) => m.user.username).toList(),
        ['alice', 'UID:404', '系统'],
      );
    });
  });
}
