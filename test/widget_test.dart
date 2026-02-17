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
}
