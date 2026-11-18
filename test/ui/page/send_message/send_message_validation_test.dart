import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_nga/providers/message/send_message_provider.dart';
import 'package:flutter_nga/ui/page/send_message/send_message_page.dart';

void main() {
  test('splitMessageUsers 支持空格、英文和中文逗号', () {
    expect(splitMessageUsers(' a, b，c  d ,,'), ['a', 'b', 'c', 'd']);
    expect(splitMessageUsers('  '), isEmpty);
  });

  group('validateMessage', () {
    String? check({
      bool isNew = true,
      String subject = '标题',
      String content = '内容',
      List<String> contacts = const ['a'],
    }) => validateMessage(
      isNew: isNew,
      subject: subject,
      content: content,
      contacts: contacts,
    );

    test('新对话需要标题、收信人和内容', () {
      expect(check(), isNull);
      expect(check(subject: '  '), '标题过短');
      expect(check(subject: 'x' * 66), '标题过长');
      expect(check(contacts: const []), '未填写收信人');
      expect(check(content: ' '), '内容过短');
      expect(check(content: 'x' * 20001), '内容过长');
    });

    test('回复只校验内容', () {
      expect(check(isNew: false, subject: '', contacts: const []), isNull);
      expect(check(isNew: false, content: ''), '内容过短');
    });
  });
}
