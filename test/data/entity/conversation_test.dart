import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_nga/data/entity/conversation.dart';

void main() {
  group('Conversation', () {
    test('bit 缺失时不抛异常', () {
      final conversation = Conversation.fromJson({'mid': 1});
      expect(conversation.isMultiUser, isFalse);
      expect(conversation.isUnread, isFalse);
    });

    test('多人、未读位', () {
      final conversation = Conversation.fromJson({'mid': 1, 'bit': '3'});
      expect(conversation.isMultiUser, isTrue);
      expect(conversation.isUnread, isTrue);
    });

    test('参与者显示：发起人、最后回复人、再一位其他人，更多省略', () {
      final conversation = Conversation.fromJson({
        'from': 1,
        'from_username': 'alice',
        'last_from': 2,
        'last_from_username': 'bob',
        'all_user': '1\talice\t2\tbob\t3\tcarol\t4\tdave',
      });
      expect(conversation.users, 'alice, bob, carol, …');
    });

    test('最后回复人是发起人时不重复，系统消息显示 #SYSTEM#', () {
      expect(
        Conversation.fromJson({
          'from': 1,
          'from_username': 'alice',
          'last_from': 1,
          'last_from_username': 'alice',
        }).users,
        'alice',
      );
      expect(
        Conversation.fromJson({'from': 0, 'last_from_username': ''}).users,
        '#SYSTEM#',
      );
    });
  });
}
