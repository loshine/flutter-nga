import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_nga/data/repository/expression_repository.dart';
import 'package:flutter_nga/utils/parser/content_parser.dart';

void main() {
  final lookup = EmoticonLookup(EmoticonDataRepository().getEmoticonGroups());

  String srcOf(String html) =>
      RegExp(r"src='[^']*/smile/([^']+)'").firstMatch(html)?.group(1) ?? '';

  test('default group accepts [s:37] and [s::37] like NGA web', () {
    expect(srcOf(lookup.replace('[s:37]')), '17.gif');
    expect(srcOf(lookup.replace('没什么[s::37]')), '17.gif');
  });

  test('named groups resolve by code and name', () {
    expect(srcOf(lookup.replace('[s:ac:blink]')), 'ac0.png');
    expect(srcOf(lookup.replace('[s:a2:goodjob]')), 'a2_02.png');
    expect(lookup.replace('[s:pg:严肃]'), contains("height='60' descent='12'"));
    expect(lookup.replace('[s:1]'), contains("height='19' descent='4'"));
  });

  test('replaces every occurrence in mixed text', () {
    final html = lookup.replace('a[s:1]b[s:ac:blink]c[s:1]');
    expect(RegExp('<nga_emoticon').allMatches(html), hasLength(3));
    expect(html, startsWith('a<nga_emoticon'));
  });

  test('unknown codes stay as plain text', () {
    for (final text in [
      '[s:ac:不存在]',
      '[s:zz:1]',
      '[s:999]',
      '[s:]',
      '[s:ac]',
    ]) {
      expect(lookup.replace(text), text);
    }
  });
}
