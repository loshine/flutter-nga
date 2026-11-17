import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:flutter_nga/ui/widget/nga_html_extensions.dart';
import 'package:flutter_nga/utils/linkroute/link_route.dart';
import 'package:flutter_nga/utils/parser/content_parser.dart';
import 'package:flutter_nga/utils/parser/nga_crypt.dart';

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
    expect(parsed, contains("<div style='text-align:left;'>左</div>"));
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

  group('second batch', () {
    test('---title--- becomes h5, existing === / ------ / ====== kept', () {
      expect(NgaContentParser.parse('---小标题---<br/>正文'), '<h5>小标题</h5><br/>正文');
      expect(
        NgaContentParser.parse('前文<br/>----- 标题 -----<br/>后文'),
        '前文<br/><h5>标题</h5><br/>后文',
      );
      // 标题为空即细分隔，与原先 6 个以上 - 的输出相同
      expect(
        NgaContentParser.parse('a<br/>------<br/>b'),
        'a<br/><h5></h5><br/>b',
      );
      expect(NgaContentParser.parse('a ------ b'), 'a <h5></h5> b');
      // 不独占一行、不能跨行的不处理
      expect(NgaContentParser.parse('a ---x--- b'), 'a ---x--- b');
      expect(NgaContentParser.parse('---a<br/>b---'), '---a<br/>b---');
      expect(NgaContentParser.parse('===标题==='), '<h3>标题</h3>');
      expect(NgaContentParser.parse('a======b'), 'a<br/><hr/>b');
    });

    test('img with parameter renders as normal image', () {
      final parsed = NgaContentParser.parse(
        '[img0]https://a.com/x.png[/img] [img-50]https://a.com/y.png[/img] '
        '[IMG100]./mon_202611/17/z.jpg[/IMG]',
      );
      expect(parsed, contains("<img src='https://a.com/x.png' />"));
      expect(parsed, contains("<img src='https://a.com/y.png' />"));
      expect(
        parsed,
        contains(
          "<img src='https://img.nga.cn/attachments/mon_202611/17/z.jpg' />",
        ),
      );
      expect(parsed, isNot(contains('[img')));
    });

    test('crypt becomes a password block carrying the cipher', () {
      // 由网页版算法（JS escape + RC4）独立生成的密文
      const cipher = 'h%9D%12%0BK%13^{~|=(:~';
      final parsed = NgaContentParser.parse('前[crypt]$cipher[/crypt]后');
      expect(
        parsed,
        "前<nga_crypt data='${NgaCrypt.toHex(cipher)}'></nga_crypt>后",
      );
      expect(NgaCrypt.fromHex(NgaCrypt.toHex(cipher)), cipher);
      // 楼层参数一并带上，解密后按同样参数解析
      expect(
        NgaContentParser.parse(
          '[crypt]$cipher[/crypt]',
          authorId: 1,
          tid: 2,
          pid: 3,
          postDateTimestamp: 1763337600,
        ),
        "<nga_crypt data='${NgaCrypt.toHex(cipher)}' author='1' tid='2' "
        "pid='3' date='1763337600'></nga_crypt>",
      );
      expect(
        NgaContentParser.parse('[crypt]<b>[/crypt]'),
        '<nga_crypt></nga_crypt>',
      );
    });

    test('crypt decrypts like the web version', () {
      expect(NgaCrypt.decrypt('123456', 'h%9D%12%0BK%13^{~|=(:~'), 'hello 世界');
      expect(
        NgaCrypt.decrypt(
          '密码pw',
          '])})`(}=(!;,(,=!%D2E%0D=?{?^}#|%A7%83y%98y%ED%EC%81P',
        ),
        '隐藏内容[b]粗体[/b] abc!',
      );
      expect(
        NgaCrypt.decrypt('wrong', 'h%9D%12%0BK%13^{~|=(:~'),
        isNot('hello 世界'),
      );
      expect(NgaCrypt.decrypt('', 'abc'), isNull);
      expect(NgaCrypt.decrypt('pw', 'a<b'), isNull);
      const plain = '多行\n[url]https://a.com[/url] 😀';
      expect(NgaCrypt.decrypt('k', NgaCrypt.encrypt('k', plain)), plain);
    });

    test('headline merges into one block with links and hltxt', () {
      final parsed = NgaContentParser.parse(
        '正文<br/>[headline][img]https://a.com/1.jpg[/img]'
        '[url=https://a.com/p]标题一[/url][/headline]<br/>'
        '[headline][tid=123]标题二[/tid][/headline]'
        '[HEADLINE][hltxt]纯文字[/hltxt][/HEADLINE]后文',
      );
      expect(
        parsed,
        startsWith(
          "正文<nga_headline><div><img src='https://a.com/1.jpg' />"
          "<a href='https://a.com/p'>标题一</a></div>",
        ),
      );
      expect(parsed, contains("read.php?tid=123'>标题二</a></div>"));
      expect(parsed, endsWith('<div><b>纯文字</b></div></nga_headline>后文'));
      expect(parsed, isNot(contains('[headline')));
      expect(parsed, isNot(contains('hltxt')));
    });

    test('lessernuke at the start folds the whole post', () {
      expect(
        NgaContentParser.parse('[lessernuke]违规内容[/lessernuke]'),
        "<collapse title='用户因此帖中的发言被处罚'>违规内容</collapse>",
      );
      expect(
        NgaContentParser.parse('<br/>[lessernuke2][b]x[/b][/lessernuke2] '),
        "<collapse title='用户在主题中被处罚'><b>x</b></collapse>",
      );
      expect(
        NgaContentParser.parse('[LESSERNUKE3]y'),
        "<collapse title='被锁定账号发布的内容无法查看'>y</collapse>",
      );
      // 不在开头的标签直接去掉
      expect(NgaContentParser.parse('a[lessernuke]b[/lessernuke]'), 'ab');
      expect(
        NgaContentParser.extractQuoteSnippet('[lessernuke]被引用[/lessernuke]'),
        '被引用',
      );
    });

    test('iframe degrades to a link', () {
      final parsed = NgaContentParser.parse(
        '[iframe=300,500]http://a.com/page?x=1[/iframe] '
        '[iframe]https://b.com[/iframe] [iframe]javascript:x[/iframe]',
      );
      expect(
        parsed,
        contains(
          "<a href='https://a.com/page?x=1'>[网页] http://a.com/page?x=1</a>",
        ),
      );
      expect(
        parsed,
        contains("<a href='https://b.com'>[网页] https://b.com</a>"),
      );
      expect(parsed, endsWith(' javascript:x'));
      expect(parsed, isNot(contains('[iframe')));
    });

    test('l / r become aligned blocks and swallow adjacent line breaks', () {
      expect(
        NgaContentParser.parse('前文<br/>[l]左<br/>[/l]<br/>[r]右[/r]<br/>后文'),
        "前文<div style='text-align:left;'>左</div>"
        "<div style='text-align:right;'>右</div>后文",
      );
      // 同名嵌套由内到外配对
      expect(
        NgaContentParser.parse('[r]外[r]内[/r]尾[/r]'),
        "<div style='text-align:right;'>外"
        "<div style='text-align:right;'>内</div>尾</div>",
      );
      // 带参数的保留原文（与网页版一致），未闭合的不处理
      expect(NgaContentParser.parse('[l=50]x[/l]'), '[l=50]x[/l]');
      expect(NgaContentParser.parse('a<br/>[l]x'), 'a<br/>[l]x');
    });

    test('upup is bold', () {
      expect(
        NgaContentParser.parse('[upup]顶[/upup] [UPUP]x[/UPUP]'),
        '<b>顶</b> <b>x</b>',
      );
    });
  });

  testWidgets('headline renders as a block with a clickable link', (
    tester,
  ) async {
    final parsed = NgaContentParser.parse(
      '[headline][url=https://a.com/p]头条标题[/url][/headline]正文',
    );
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: NgaHtml(parsed))));

    expect(tester.takeException(), isNull);
    expect(find.text('头条'), findsOneWidget);
    expect(find.byIcon(Icons.newspaper), findsOneWidget);
    expect(find.textContaining('头条标题', findRichText: true), findsOneWidget);
    expect(find.textContaining('正文', findRichText: true), findsOneWidget);
  });

  testWidgets('crypt block decrypts with the right password', (tester) async {
    final cipher = NgaCrypt.encrypt('pw', '[b]秘密[/b]内容');
    final parsed = NgaContentParser.parse('前文[crypt]$cipher[/crypt]');
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: SingleChildScrollView(child: NgaHtml(parsed))),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('输入正确的密码以浏览加密的内容'), findsOneWidget);
    expect(find.textContaining('秘密', findRichText: true), findsNothing);

    await tester.enterText(find.byType(TextField), 'pw');
    await tester.tap(find.text('确认'));
    await tester.pump();

    expect(find.textContaining('秘密', findRichText: true), findsOneWidget);
    expect(find.text('重新输入密码'), findsOneWidget);

    await tester.tap(find.text('重新输入密码'));
    await tester.pump();
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('decrypted content keeps the post date for noimg', (
    tester,
  ) async {
    final cipher = NgaCrypt.encrypt('pw', '[noimg]abc.jpg[/noimg]');
    // 2025-11-17 08:00（北京时间）
    final parsed = NgaContentParser.parse(
      '[crypt]$cipher[/crypt]',
      postDateTimestamp: 1763337600,
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: SingleChildScrollView(child: NgaHtml(parsed))),
      ),
    );

    await tester.enterText(find.byType(TextField), 'pw');
    await tester.tap(find.text('确认'));
    await tester.pump();

    final images = tester.widgetList<Image>(find.byType(Image));
    expect(
      images.map((image) => image.image.toString()),
      contains(contains('attachments/mon_202511/17/abc.jpg')),
    );
  });

  testWidgets('lessernuke renders as collapse', (tester) async {
    final parsed = NgaContentParser.parse('[lessernuke]违规内容[/lessernuke]');
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: NgaHtml(parsed))));

    expect(tester.takeException(), isNull);
    expect(find.text('点击展开:用户因此帖中的发言被处罚'), findsOneWidget);
  });
}
