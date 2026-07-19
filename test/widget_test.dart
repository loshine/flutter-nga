// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_nga/utils/parser/content_parser.dart';

void main() {
  // testWidgets('Counter increments smoke test', (WidgetTester tester) async {
  //   // Build our app and trigger a frame.
  //   await tester.pumpWidget(MyApp());
  //
  //   // Verify that our counter starts at 0.
  //   expect(find.text('0'), findsOneWidget);
  //   expect(find.text('1'), findsNothing);
  //
  //   // Tap the '+' icon and trigger a frame.
  //   await tester.tap(find.byIcon(Icons.add));
  //   await tester.pump();
  //
  //   // Verify that our counter has incremented.
  //   expect(find.text('1'), findsOneWidget);
  //   expect(find.text('0'), findsNothing);
  // });

  test('Substring test', () {
    String url = "./mon_201901/23/7nQ5-1s5nK1kT1kSb9-45.png.thumb.jpg";
    expect(url.substring(0, url.length - 10),
        "./mon_201901/23/7nQ5-1s5nK1kT1kSb9-45.png");
  });

  test('RegExp test', () {
    RegExp regExp = RegExp(
        "\\[b]Reply to \\[tid=(\\d+)?]Topic\\[/tid] Post by \\[uid]([\\s\\S]*?)\\[/uid]\\[color=gray]\\(([\\s\\S]*?)\\)\\[/color] \\(([\\s\\S]*?)\\)\\[/b]");
    String content =
        "[b]Reply to [tid=16893894]Topic[/tid] Post by [uid]#anony_6b0df884c0e44bf854e195a52cbc3a0e[/uid][color=gray](0楼)[/color] (2019-04-08 14:29)[/b]  哈哈哈哈哈哈";
    expect(content.replaceAll(regExp, ""), "  哈哈哈哈哈哈");
  });

  test('Anony RegExp test', () {
    RegExp regExp = RegExp(
        "\\[pid=(\\d+)?,(\\d+)?,(\\d+)?]Reply\\[/pid] \\[b]Post by \\[uid]#anony_([0-9a-zA-Z]*)\\[/uid]\\[color=gray]\\((\\d+)?楼\\)\\[/color] \\(([\\s\\S]*?)\\):\\[/b]");
    String content =
        "[pid=445996637,23005426,1]Reply[/pid] [b]Post by [uid]#anony_7dc5258240df2301fdae75153712d174[/uid][color=gray](6楼)[/color] (2020-08-18 15:04):[/b]";
    expect(content.replaceAll(regExp, ""), "");
  });

  test('P0 parser: reference tags', () {
    final parsed = NgaContentParser.parse(
      '[uid=123]foo[/uid] [pid=445996637,23005426,1]Reply[/pid] '
      '[tid=16893894]Topic[/tid] [@ test_user ]',
    );
    expect(parsed.contains('nuke.php?func=ucp&amp;uid=123'), true);
    expect(parsed.contains('read.php?searchpost=1&amp;pid=445996637'), true);
    expect(parsed.contains('read.php?tid=16893894'), true);
    expect(parsed.contains('username=test_user'), true);
  });

  test('P0 parser: media tags', () {
    final parsed = NgaContentParser.parse(
      '[noimg]test-image.jpg[/noimg] [attach]./mon_202402/17/abc.png[/attach] '
      '[flash=audio]/audio/test.mp3[/flash] [code]a<br/>b[/code]',
      postDateTimestamp: 1708128000,
    );
    final parsedVideo = NgaContentParser.parse(
      '[noimg]test-video.mp4[/noimg]',
      postDateTimestamp: 1708128000,
    );
    expect(parsed.contains('mon_202402/17/test-image.jpg'), true);
    expect(parsed.contains("class='nga-attach'"), true);
    expect(parsed.contains('[站外音频]'), true);
    expect(parsed.contains('<pre><code>a\nb</code></pre>'), true);
    expect(parsedVideo.contains('<video controls src='), true);
  });

  test('P0 parser: custom/unknown tags fallback', () {
    final parsed = NgaContentParser.parse(
      '====== [collapse=标题]内容[/collapse] [s:1] [randomblock]x[/randomblock]',
    );
    expect(parsed.contains('<nga_hr></nga_hr>'), true);
    expect(parsed.contains("<collapse title='标题'>内容</collapse>"), true);
    expect(parsed.contains('<nga_emoticon src=') || parsed.contains('[s:1]'),
        true);
    expect(parsed.contains("class='ubb-unknown'"), true);
  });

  test('P1 parser: table span + width', () {
    final parsed = NgaContentParser.parse(
      '[table][tr][td rowspan=2 colspan=3]A[/td][td20]B[/td][/tr][/table]',
    );
    expect(parsed.contains("<td rowspan='2' colspan='3'>A</td>"), true);
    expect(parsed.contains("<td style='width:20%;'>B</td>"), true);
  });

  test('P1 parser: style tags normalization', () {
    final parsed = NgaContentParser.parse(
      '[color=#FF00AA]c[/color] [size=120%]s1[/size] [size=16]s2[/size] [font=宋体]f[/font]',
    );
    expect(parsed.contains("style='color:#FF00AA;'"), true);
    expect(parsed.contains("style='font-size:120%;'"), true);
    expect(parsed.contains("style='font-size:16px;'"), true);
    expect(parsed.contains('Times New Roman, SimSun, serif'), true);
  });

  test('P1 parser: list nested stability', () {
    final parsed = NgaContentParser.parse(
      '[list][*]a[list][*]b[/list][*]c[/list]',
    );
    expect(parsed.contains('<ul><li>a<ul><li>b</li></ul></li><li>c</li></ul>'),
        true);
  });

  test('P1 parser: album + flash media semantic', () {
    final parsed = NgaContentParser.parse(
      '[album=图集][url]https://img.nga.178.com/attachments/mon_202402/17/a.jpg[/url][/album] '
      '[flash]https://cdn.example.com/a.mp3[/flash] [flash]https://cdn.example.com/v.mp4[/flash]',
    );
    expect(parsed.contains("<album title='图集'>"), true);
    expect(parsed.contains('<img src='), true);
    expect(parsed.contains('[站外音频]'), true);
    expect(parsed.contains('[站外视频]'), true);
  });

  test('Reply quote header → nga_quote tag', () {
    final parsed = NgaContentParser.parse(
      '[pid=875718629,47217372,1]Reply[/pid] [b]Post by '
      '[uid=66738726]golcore[/uid] (2026-07-20 00:43):[/b]<br/>正文',
    );
    expect(
      parsed.contains("<nga_quote pid='875718629' uid='66738726' "
          "author='golcore' date='2026-07-20 00:43'></nga_quote>"),
      true,
    );
    expect(parsed.contains('正文'), true);
  });

  test('Quote block keeps original body inside nga_quote', () {
    final parsed = NgaContentParser.parse(
      '[quote][pid=875718629,47217372,1]Reply[/pid] [b]Post by '
      '[uid=66738726]golcore[/uid] (2026-07-20 00:43):[/b]<br/><br/>'
      '被引用的原文内容[/quote]<br/>我的回复',
    );
    expect(
      parsed.contains(
          "<nga_quote pid='875718629' uid='66738726' author='golcore' "
          "date='2026-07-20 00:43'>被引用的原文内容</nga_quote>"),
      true,
    );
    // 原文不应再落在 blockquote 外变成游离文本
    expect(parsed.contains('<blockquote>'), false);
    expect(parsed.contains('我的回复'), true);
  });

  test('Topic quote header → nga_quote tag with tid', () {
    final parsed = NgaContentParser.parse(
      '[tid=47217372]Topic[/tid] [b]Post by '
      '[uid=66738726]golcore[/uid] (2026-07-20 00:43):[/b]',
    );
    expect(parsed.contains("<nga_quote tid='47217372'"), true);
    expect(parsed.contains("pid="), false);
  });

  test('Reply-to headers → nga_quote tag', () {
    final parsedTopic = NgaContentParser.parse(
      '[b]Reply to [tid=47217372]Topic[/tid] Post by '
      '[uid=66738726]golcore[/uid] (2026-07-20 00:43)[/b]',
    );
    expect(
        parsedTopic.contains("<nga_quote tid='47217372' "
            "uid='66738726' author='golcore'"),
        true);
    final parsedPost = NgaContentParser.parse(
      '[b]Reply to [pid=875718629,47217372,1]Reply[/pid] Post by '
      '[uid=66738726]golcore[/uid] (2026-07-20 00:43)[/b]',
    );
    expect(parsedPost.contains("<nga_quote pid='875718629'"), true);
    // uid 不应以裸文本形式泄露
    expect(parsedPost.contains('Post by 66738726'), false);
  });

  test('Anonymous reply header → nga_quote without uid', () {
    final parsed = NgaContentParser.parse(
      '[pid=445996637,23005426,1]Reply[/pid] [b]Post by '
      '[uid]#anony_7dc5258240df2301fdae75153712d174[/uid]'
      '[color=gray](6楼)[/color] (2020-08-18 15:04):[/b]',
    );
    expect(parsed.contains('<nga_quote pid='), true);
    expect(parsed.contains("floor='6楼'"), true);
    expect(parsed.contains('uid='), false);
  });

  test('Reply-to expands with cached body like NGA web', () {
    final cache = NgaContentParser.buildQuoteBodyCache([
      (pid: 875718629, content: '这是被回复楼的原文内容'),
      (
        pid: 1,
        content:
            '[quote][pid=9,1,1]Reply[/pid] [b]Post by [uid=1]a[/uid] (t):[/b]\n嵌套引用[/quote]\n楼层正文',
      ),
    ]);
    // 嵌套引用应被剥掉，只保留楼层正文
    expect(cache[1], '楼层正文');
    expect(cache[875718629], '这是被回复楼的原文内容');

    final parsed = NgaContentParser.parse(
      '[b]Reply to [pid=875718629,47217372,1]Reply[/pid] Post by '
      '[uid=66738726]golcore[/uid] (2026-07-20 00:43)[/b]我的回复',
      quoteBodyByPid: cache,
    );
    expect(
      parsed.contains(
          "<nga_quote pid='875718629' uid='66738726' author='golcore' "
          "date='2026-07-20 00:43'>这是被回复楼的原文内容</nga_quote>"),
      true,
    );
    expect(parsed.contains('我的回复'), true);
  });

  test('Reply-to without cache stays header-only', () {
    final parsed = NgaContentParser.parse(
      '[b]Reply to [pid=875718629,47217372,1]Reply[/pid] Post by '
      '[uid=66738726]golcore[/uid] (2026-07-20 00:43)[/b]我的回复',
    );
    expect(parsed.contains("<nga_quote pid='875718629'"), true);
    expect(parsed.contains('这是被回复'), false);
    expect(parsed.contains('我的回复'), true);
  });
}
