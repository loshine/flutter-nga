import 'package:flutter_nga/utils/json_cast.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('asJsonMap', () {
    test('returns Map<String, dynamic> as-is', () {
      final source = <String, dynamic>{'tid': 1};
      expect(asJsonMap(source, 'Topic.tid'), same(source));
    });

    test('converts a generic Map', () {
      final result = asJsonMap({'tid': 1}, 'Topic');
      expect(result['tid'], 1);
    });

    test('throws with field path when value is a String', () {
      expect(
        () => asJsonMap('', 'TopicListData.__T'),
        throwsA(isA<FormatException>().having(
          (error) => error.message,
          'message',
          contains('TopicListData.__T'),
        )),
      );
    });

    test('asJsonMapOrNull returns null for null', () {
      expect(asJsonMapOrNull(null, 'UserInfo.reputation'), isNull);
    });
  });
}
