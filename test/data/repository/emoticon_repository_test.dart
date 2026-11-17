import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_nga/data/repository/expression_repository.dart';

void main() {
  final groups = EmoticonDataRepository().getEmoticonGroups();
  final emoticons = [for (final group in groups) ...group.expressionList];

  test('groups follow NGA web order, including NG娘', () {
    expect(groups.map((g) => g.name), [
      '默认',
      'AC娘',
      '新AC娘',
      'NG娘',
      '潘斯特',
      '外域三人组',
      '企鹅',
    ]);
    expect(groups.every((g) => g.expressionList.isNotEmpty), isTrue);
  });

  test('every code is a well-formed, unique [s:...] tag', () {
    final codePattern = RegExp(r'^\[s:([a-z0-9]+:)?[^\[\]:]+\]$');
    for (final emoticon in emoticons) {
      expect(emoticon.content, matches(codePattern));
    }
    final codes = emoticons.map((e) => e.content).toList();
    expect(codes.toSet(), hasLength(codes.length));
  });

  test('images load from the nga.cn image host', () {
    for (final emoticon in emoticons) {
      expect(emoticon.url, startsWith(emoticonImageBase));
      expect(emoticon.url, isNot(contains('178.com')));
    }
  });

  test('maps codes to the official image files', () {
    final urlByCode = {for (final e in emoticons) e.content: e.url};
    expect(urlByCode['[s:1]'], '${emoticonImageBase}smile.gif');
    expect(urlByCode['[s:ac:blink]'], '${emoticonImageBase}ac0.png');
    expect(urlByCode['[s:a2:jojo立2]'], '${emoticonImageBase}a2_38.png');
    expect(urlByCode['[s:ng:吃瓜]'], '${emoticonImageBase}ng_17.png');
    expect(urlByCode['[s:pst:脸红]'], '${emoticonImageBase}pt54.png');
    expect(urlByCode['[s:pst:脸红2]'], '${emoticonImageBase}pt55.png');
    expect(urlByCode['[s:pg:转身]'], '${emoticonImageBase}pg15.png');
  });

  test('sizes and alignment match NGA web', () {
    for (final group in groups) {
      final classic = group.name == '默认';
      for (final emoticon in group.expressionList) {
        expect(emoticon.height, classic ? 19 : 60, reason: emoticon.content);
        expect(emoticon.descent, classic ? 4 : 12, reason: emoticon.content);
      }
    }
  });
}
