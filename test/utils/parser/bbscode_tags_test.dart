import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:flutter_nga/ui/widget/nga_html_extensions.dart';
import 'package:flutter_nga/utils/linkroute/link_route.dart';
import 'package:flutter_nga/utils/parser/content_parser.dart';

/// 对齐网页版 js_bbscode_core.js 的标签支持。
void main() {
  setUp(NgaContentParser.clearCache);

  group('table', () {
    test('options on table / tr / td are parsed', () {
      final parsed = NgaContentParser.parse(
        '[table noborder][tr th][td colspan2 width50]表头[/td][/tr]'
        '[tr][td rowspan=3]A[/td][td 20]B[/td][/tr][/table]',
      );
      expect(parsed, contains("<table class='noborder'><tbody>"));
      expect(parsed, contains("<tr class='th'>"));
      expect(parsed, contains("<td style='width:50%;' colspan='2'>表头</td>"));
      expect(parsed, contains("<td rowspan='3'>A</td>"));
      expect(parsed, contains("<td style='width:20%;'>B</td>"));
      expect(parsed, isNot(contains('[table')));
      expect(parsed, isNot(contains('[tr')));
    });

    test('unclosed and stray tags still produce balanced html', () {
      final parsed = NgaContentParser.parse(
        '[table][td]A[td]B[/tr][/td][/table]后文',
      );
      expect(
        parsed,
        "<div><table><tbody><tr><td>A</td><td>B</td></tr>"
        '</tbody></table><br/><br/></div>后文',
      );

      final unclosed = NgaContentParser.parse('[table][tr][td]A');
      expect(
        unclosed,
        endsWith('<td>A</td></tr></tbody></table><br/><br/></div>'),
      );
    });

    test('tr / td outside a table and look-alike tags are left alone', () {
      final parsed = NgaContentParser.parse('[td]x[/td] [trick]');
      expect(parsed, isNot(contains('<td>')));
      expect(parsed, contains('[trick]'));
    });

    test('table end keeps two line breaks after a following br', () {
      final parsed = NgaContentParser.parse(
        '[table][tr][td]A[/td][/tr][/table]<br/>后文',
      );
      expect(parsed, contains('</table><br/><br/></div>'));
    });
  });

  test('fid / stid become forum links', () {
    final parsed = NgaContentParser.parse(
      '[fid=7]艾泽拉斯议事厅[/fid] [stid=123]合集名[/stid] '
      '[fid]7[/fid] [STID]5[/STID] [fid=]abc[/fid] '
      '[fid=-7]网事杂谈[/fid] [fid]-7[/fid]',
    );
    expect(parsed, contains("thread.php?fid=7'>艾泽拉斯议事厅</a>"));
    expect(parsed, contains("thread.php?stid=123'>合集名</a>"));
    expect(parsed, contains("thread.php?fid=7'>版面7</a>"));
    expect(parsed, contains("thread.php?stid=5'>合集5</a>"));
    expect(parsed, contains('[fid=]abc[/fid]'));
    expect(parsed, contains("thread.php?fid=-7'>网事杂谈</a>"));
    expect(parsed, contains("thread.php?fid=-7'>版面-7</a>"));
  });

  test('sup / sub map to html tags', () {
    final parsed = NgaContentParser.parse('x[sup]2[/sup] H[sub]2[/sub]O');
    expect(parsed, 'x<sup>2</sup> H<sub>2</sub>O');
  });

  test('code with language renders as a code block', () {
    final parsed = NgaContentParser.parse('[code=js]var a = 1;[/code]');
    expect(parsed, '<pre><code>var a = 1;</code></pre>');
  });

  test('media behaves like flash, attachments use the attachment host', () {
    final parsed = NgaContentParser.parse(
      '[media]https://example.com/a.mp4[/media] '
      '[media=audio]https://example.com/b[/media] '
      '[flash=video]./mon_202611/17/abc.mp4[/flash]',
    );
    expect(parsed, contains("href='https://example.com/a.mp4'>[站外视频]</a>"));
    expect(parsed, contains("href='https://example.com/b'>[站外音频]</a>"));
    expect(
      parsed,
      contains(
        "href='https://img.nga.cn/attachments/mon_202611/17/abc.mp4'>[视频]</a>",
      ),
    );
    expect(parsed, isNot(contains('[media')));
  });

  test('tag names are case insensitive', () {
    final parsed = NgaContentParser.parse(
      '[B]粗[/B] [I]斜[/I] [DEL]删[/DEL] [URL]https://a.com[/URL] '
      '[IMG]https://a.com/x.png[/IMG] [CODE]c[/CODE] [QUOTE]q[/QUOTE] '
      '[COLLAPSE=t]内容[/COLLAPSE] [ALIGN=center]中[/ALIGN] [L]左[/L]',
    );
    expect(parsed, contains('<b>粗</b>'));
    expect(parsed, contains('<i>斜</i>'));
    expect(parsed, contains('<del>删</del>'));
    expect(parsed, contains("<a href='https://a.com'>https://a.com</a>"));
    expect(parsed, contains("<img src='https://a.com/x.png' />"));
    expect(parsed, contains('<pre><code>c</code></pre>'));
    expect(parsed, contains('<blockquote>q</blockquote>'));
    expect(parsed, contains("<collapse title='t'>内容</collapse>"));
    expect(parsed, contains("<div style='text-align:center;'>中</div>"));
    expect(parsed, contains("<p style='text-align:left'>左</p>"));
    expect(parsed, isNot(contains('ubb-unknown')));
  });

  test('color with bg prefix becomes a colored block', () {
    final parsed = NgaContentParser.parse(
      '[color=bgred]红底[/color] [color=BGRoyalBlue]蓝底[/color] '
      '[color=bgfoo]未知[/color]',
    );
    expect(
      parsed,
      contains("<span style='background-color:red;color:white;'>红底</span>"),
    );
    expect(
      parsed,
      contains(
        "<span style='background-color:royalblue;color:white;'>蓝底</span>",
      ),
    );
    expect(parsed, contains("<span style='color:bgfoo;'>未知</span>"));
  });

  test('forum link route matches fid and stid', () {
    final regExp = RegExp(ForumLinkRoute().matchRegExp());
    final fid = regExp.firstMatch('https://bbs.nga.cn/thread.php?fid=7');
    final stid = regExp.firstMatch('/thread.php?stid=123&page=2');
    expect(fid?.group(1), 'fid');
    expect(fid?.group(2), '7');
    expect(regExp.firstMatch('/thread.php?fid=-7')?.group(2), '-7');
    expect(stid?.group(1), 'stid');
    expect(stid?.group(2), '123');
    expect(regExp.hasMatch('/read.php?tid=7'), false);
  });

  testWidgets('noborder table and header row render', (tester) async {
    final parsed = NgaContentParser.parse(
      '[table noborder][tr th][td]表头[/td][/tr][tr][td]内容[/td][/tr][/table]',
    );
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: NgaHtml(parsed))));

    expect(tester.takeException(), isNull);
    expect(find.textContaining('表头', findRichText: true), findsOneWidget);
    expect(find.textContaining('内容', findRichText: true), findsOneWidget);
    final header = tester.widget<RichText>(
      find.textContaining('表头', findRichText: true),
    );
    final headerWeights = <FontWeight?>[];
    header.text.visitChildren((span) {
      if (span is TextSpan && (span.text?.contains('表头') ?? false)) {
        headerWeights.add(span.style?.fontWeight);
      }
      return true;
    });
    expect(headerWeights, contains(FontWeight.bold));
  });
}
