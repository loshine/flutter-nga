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
      final message = Message.fromJson({
        'id': '1',
        'content': 'hi',
        'from': '200',
        'time': 1700000000,
      }, users);

      expect(message.from, 200);
      expect(message.user, same(users[1]));
      expect(message.content, 'hi');
    });

    test('userList 中缺少发信人时用占位用户，不抛异常', () {
      final message = Message.fromJson({
        'id': 2,
        'content': 'hello',
        'from': 999,
      }, users);

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
      expect(data.messageList.map((m) => m.user.username).toList(), [
        'alice',
        'UID:404',
        '系统',
      ]);
    });
  });

  group('参与者与位标志', () {
    test('parseMessageParticipants 解析 tab 分隔的 uid/用户名', () {
      expect(parseMessageParticipants('1\talice\t2\tbob'), const [
        MessageParticipant(1, 'alice'),
        MessageParticipant(2, 'bob'),
      ]);
      expect(parseMessageParticipants(null), isEmpty);
      expect(parseMessageParticipants('x\ty\t3'), isEmpty);
    });

    test('隐藏位与 IP（整数或点分形式）', () {
      final hidden = Message.fromJson({
        'from': 100,
        'bit': '512',
        'data': {'1': 3232235777},
      }, const []);
      expect(hidden.isHidden, isTrue);
      expect(hidden.ip, '192.168.1.1');

      // 有符号 32 位整数也按无符号处理
      final negative = Message.fromJson({
        'from': 100,
        'data': [null, -1062731519],
      }, const []);
      expect(negative.isHidden, isFalse);
      expect(negative.ip, '192.168.1.1');

      final dotted = Message.fromJson({
        'from': 100,
        'data': {'1': '10.0.0.1'},
      }, const []);
      expect(dotted.ip, '10.0.0.1');
      expect(Message.fromJson({'from': 1}, const []).ip, isNull);
    });

    test('系统消息修正主题链接写法', () {
      final message = Message.fromJson({
        'from': 0,
        'content': '[url]/read.php?tid=123][b]标题[/b][/url]',
      }, const []);
      expect(message.content, '[url=/read.php?tid=123][b]标题[/b][/url]');
    });

    test('MessageListData 读取 allUsers、隔离位，缺失时回退到首条 data[2]', () {
      final data = MessageListData.fromJson({
        'subjectBit': 32,
        'starterUid': '1',
        'allUsers': '1\talice\t2\tbob',
        'allmsgs': {
          '0': {'id': 1, 'from': 1, 'content': 'x'},
        },
      });
      expect(data.isIsolated, isTrue);
      expect(data.starterUid, 1);
      expect(data.participants, hasLength(2));

      final fallback = MessageListData.fromJson({
        'allmsgs': {
          '0': {
            'id': 1,
            'from': 1,
            'content': 'x',
            'data': {'2': '3\tcarol'},
          },
        },
      });
      expect(fallback.isIsolated, isFalse);
      expect(fallback.participants, const [MessageParticipant(3, 'carol')]);
    });
  });
}
