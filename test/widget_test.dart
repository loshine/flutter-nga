// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_nga/my_app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp());

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('1'), findsOneWidget);
    expect(find.text('0'), findsNothing);
  });

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
}
