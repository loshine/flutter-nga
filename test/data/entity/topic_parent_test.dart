import 'package:flutter_nga/data/entity/topic.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TopicParent.parse', () {
    test('returns null for null or empty string', () {
      expect(TopicParent.parse(null), isNull);
      expect(TopicParent.parse(''), isNull);
    });

    test('uses string value as name', () {
      expect(TopicParent.parse('版面名')?.name, '版面名');
    });

    test('reads name from map key 2', () {
      expect(TopicParent.parse({'2': '父版'})?.name, '父版');
    });
  });
}
