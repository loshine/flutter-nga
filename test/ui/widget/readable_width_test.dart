import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_nga/ui/widget/dash.dart';
import 'package:flutter_nga/ui/widget/readable_width.dart';

Future<void> _setSurface(WidgetTester tester, Size size) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));
}

void main() {
  group('readableListPadding', () {
    test('keeps base padding when viewport is not wider than max width', () {
      const base = EdgeInsets.fromLTRB(1, 2, 3, 4);
      expect(readableListPadding(400, base: base), base);
      expect(readableListPadding(kReadableMaxWidth, base: base), base);
    });

    test('adds half of the overflow to each side', () {
      expect(
        readableListPadding(1240, base: const EdgeInsets.fromLTRB(8, 2, 8, 4)),
        const EdgeInsets.fromLTRB(208, 2, 208, 4),
      );
      expect(
        readableListPadding(700, maxWidth: 600),
        const EdgeInsets.symmetric(horizontal: 50),
      );
    });
  });

  group('ReadableWidth', () {
    for (final (width, expected) in [(400.0, 400.0), (1200.0, 840.0)]) {
      testWidgets('constrains content to $expected on a $width wide screen', (
        tester,
      ) async {
        await _setSurface(tester, Size(width, 800));
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: ReadableWidth(
                child: SizedBox(key: Key('content'), width: double.infinity),
              ),
            ),
          ),
        );

        final rect = tester.getRect(find.byKey(const Key('content')));
        expect(rect.width, expected);
        expect(rect.center.dx, width / 2);
      });
    }

    testWidgets('honours a custom max width', (tester) async {
      await _setSurface(tester, const Size(1200, 800));
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ReadableWidth(
              maxWidth: 720,
              child: SizedBox(key: Key('content'), width: double.infinity),
            ),
          ),
        ),
      );

      expect(tester.getSize(find.byKey(const Key('content'))).width, 720);
    });
  });

  group('ReadableListPadding', () {
    Widget buildList({
      EdgeInsets? padding,
      EdgeInsets mediaPadding = EdgeInsets.zero,
    }) {
      return MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(
            size: const Size(1200, 800),
            padding: mediaPadding,
          ),
          child: Scaffold(
            body: ReadableListPadding(
              padding: padding,
              builder: (context, padding) => ListView.separated(
                key: const Key('list'),
                padding: padding,
                itemCount: 3,
                separatorBuilder: (_, _) =>
                    const Divider(key: Key('divider'), height: 1),
                itemBuilder: (_, index) =>
                    SizedBox(key: Key('item$index'), height: 40),
              ),
            ),
          ),
        ),
      );
    }

    testWidgets(
      'scroll view stays full width while items and dividers shrink',
      (tester) async {
        await _setSurface(tester, const Size(1200, 800));
        await tester.pumpWidget(buildList());

        expect(tester.getSize(find.byKey(const Key('list'))).width, 1200);
        final item = tester.getRect(find.byKey(const Key('item0')));
        expect(item.width, kReadableMaxWidth);
        expect(item.left, (1200 - kReadableMaxWidth) / 2);
        final divider = tester.getRect(find.byKey(const Key('divider')).first);
        expect(divider.left, item.left);
        expect(divider.width, item.width);
      },
    );

    testWidgets('dragging outside the narrowed content still scrolls', (
      tester,
    ) async {
      await _setSurface(tester, const Size(1200, 800));
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReadableListPadding(
              builder: (context, padding) => ListView.builder(
                padding: padding,
                itemCount: 50,
                itemBuilder: (_, index) =>
                    SizedBox(key: Key('item$index'), height: 40),
              ),
            ),
          ),
        ),
      );

      await tester.dragFrom(const Offset(20, 600), const Offset(0, -400));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('item0')), findsNothing);
    });

    testWidgets('keeps the vertical safe area when no padding is given', (
      tester,
    ) async {
      await _setSurface(tester, const Size(1200, 800));
      await tester.pumpWidget(
        buildList(mediaPadding: const EdgeInsets.fromLTRB(30, 0, 30, 24)),
      );

      final list = tester.widget<ListView>(find.byKey(const Key('list')));
      expect(list.padding, const EdgeInsets.fromLTRB(180, 0, 180, 24));
    });

    testWidgets('adds the readable inset on top of an explicit padding', (
      tester,
    ) async {
      await _setSurface(tester, const Size(1200, 800));
      await tester.pumpWidget(
        buildList(padding: const EdgeInsets.fromLTRB(0, 8, 0, 8)),
      );

      final list = tester.widget<ListView>(find.byKey(const Key('list')));
      expect(list.padding, const EdgeInsets.fromLTRB(180, 8, 180, 8));
    });
  });

  testWidgets('dash without length fills the narrowed width', (tester) async {
    await _setSurface(tester, const Size(1200, 800));
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ReadableWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Dash()],
            ),
          ),
        ),
      ),
    );

    expect(tester.getSize(find.byType(Dash)).width, kReadableMaxWidth);
    expect(tester.takeException(), isNull);
  });
}
