import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:flutter_nga/ui/page/publish/publish_page.dart';

Future<void> _openPublishPage(WidgetTester tester, {String? content}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => PublishPage(tid: 1, fid: 2, content: content),
              ),
            ),
            child: const Text('打开'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('打开'));
  await tester.pumpAndSettle();
  expect(find.byType(PublishPage), findsOneWidget);
}

Future<void> _tapBack(WidgetTester tester) async {
  await tester.tap(find.byType(BackButton));
  await tester.pumpAndSettle();
}

Finder get _contentField => find.widgetWithText(TextField, '回复内容');

void main() {
  testWidgets('未编辑时直接返回', (tester) async {
    await _openPublishPage(tester);

    await _tapBack(tester);

    expect(find.text('放弃编辑？'), findsNothing);
    expect(find.byType(PublishPage), findsNothing);
  });

  testWidgets('带入的引用内容未改动时直接返回', (tester) async {
    await _openPublishPage(tester, content: '[quote]引用[/quote]\n');

    await _tapBack(tester);

    expect(find.text('放弃编辑？'), findsNothing);
    expect(find.byType(PublishPage), findsNothing);
  });

  testWidgets('有输入时返回需确认，可继续编辑或放弃', (tester) async {
    await _openPublishPage(tester, content: '[quote]引用[/quote]\n');
    await tester.enterText(_contentField, '[quote]引用[/quote]\n新的回复');
    await tester.pump();

    await _tapBack(tester);
    expect(find.text('放弃编辑？'), findsOneWidget);

    await tester.tap(find.text('继续编辑'));
    await tester.pumpAndSettle();
    expect(find.text('放弃编辑？'), findsNothing);
    expect(find.byType(PublishPage), findsOneWidget);

    await _tapBack(tester);
    await tester.tap(find.text('放弃'));
    await tester.pumpAndSettle();
    expect(find.byType(PublishPage), findsNothing);
  });

  testWidgets('只填写标题也需要确认', (tester) async {
    await _openPublishPage(tester);
    await tester.enterText(find.widgetWithText(TextField, '标题(可选)'), '标题');
    await tester.pump();

    await _tapBack(tester);

    expect(find.text('放弃编辑？'), findsOneWidget);
  });
}
