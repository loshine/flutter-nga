import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_nga/ui/widget/username_text.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('uses a stable color for the same user', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              UsernameText(username: 'Alice', uid: 1),
              UsernameText(username: 'Alice', uid: 1),
              UsernameText(username: 'Bob', uid: 2),
            ],
          ),
        ),
      ),
    );

    expect(_badgeBackground(tester, 0), _badgeBackground(tester, 1));
    expect(_badgeBackground(tester, 0), isNot(_badgeBackground(tester, 2)));
  });

  testWidgets('keeps username colors readable in both brightness modes',
      (tester) async {
    for (final brightness in Brightness.values) {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(brightness: brightness),
          home: const Scaffold(
            body: UsernameText(username: '测试用户', uid: 123),
          ),
        ),
      );

      final contrast = _contrastRatio(
        _badgeBackground(tester, 0),
        _badgeForeground(tester, 0),
      );
      expect(contrast, greaterThanOrEqualTo(4.5));
    }
  });

  testWidgets('keeps the first grapheme intact and exposes the full name',
      (tester) async {
    const username = '👩‍💻Alice';
    final semantics = tester.ensureSemantics();

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: UsernameText(username: username, uid: 1)),
      ),
    );

    expect(_badgeText(tester, 0).data, '👩‍💻');
    expect(find.bySemanticsLabel(username), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('highlights the last four nickname graphemes after UID:',
      (tester) async {
    const username = 'UID:甲乙👩‍💻丁戊';
    final semantics = tester.ensureSemantics();

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: UsernameText(username: username, uid: 1)),
      ),
    );

    expect(_badgeText(tester, 0).data, '乙👩‍💻丁戊');
    expect(find.bySemanticsLabel(username), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('navigates by uid when it is available', (tester) async {
    final navigation = await _tapUsername(
      tester,
      const UsernameText(username: 'Alice', uid: 42),
    );

    expect(navigation.queryParameters, {'uid': '42'});
  });

  testWidgets('falls back to username navigation when uid is absent',
      (tester) async {
    final navigation = await _tapUsername(
      tester,
      const UsernameText(username: 'Alice Smith'),
    );

    expect(navigation.queryParameters, {'name': 'Alice Smith'});
  });

  testWidgets('does not navigate anonymous or empty usernames', (tester) async {
    var userRouteVisits = 0;
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const Scaffold(
            body: UsernameText(username: '#anony_0123456789abcdef'),
          ),
        ),
        GoRoute(
          path: '/user',
          builder: (context, state) {
            userRouteVisits++;
            return const SizedBox.shrink();
          },
        ),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.tap(find.byType(UsernameText));
    await tester.pumpAndSettle();

    expect(userRouteVisits, 0);
    expect(find.byType(InkWell), findsNothing);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: UsernameText(username: '', uid: 1)),
      ),
    );

    expect(find.byType(InkWell), findsNothing);
  });
}

Future<Uri> _tapUsername(WidgetTester tester, UsernameText username) async {
  late Uri navigation;
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => Scaffold(body: username),
      ),
      GoRoute(
        path: '/user',
        builder: (context, state) {
          navigation = state.uri;
          return const SizedBox.shrink();
        },
      ),
    ],
  );

  await tester.pumpWidget(MaterialApp.router(routerConfig: router));
  await tester.tap(find.byType(UsernameText));
  await tester.pumpAndSettle();
  return navigation;
}

Color _badgeBackground(WidgetTester tester, int index) {
  final decoration =
      _badgeContainer(tester, index).decoration! as BoxDecoration;
  return decoration.color!;
}

Color _badgeForeground(WidgetTester tester, int index) {
  return _badgeText(tester, index).style!.color!;
}

Container _badgeContainer(WidgetTester tester, int index) {
  final badges = find.descendant(
    of: find.byType(UsernameText),
    matching: find.byType(Container),
  );
  return tester.widget<Container>(badges.at(index));
}

Text _badgeText(WidgetTester tester, int index) {
  final badges = find.descendant(
    of: find.byType(UsernameText),
    matching: find.byType(Container),
  );
  final text = find.descendant(
    of: badges.at(index),
    matching: find.byType(Text),
  );
  return tester.widget<Text>(text);
}

double _contrastRatio(Color first, Color second) {
  final firstLuminance = first.computeLuminance();
  final secondLuminance = second.computeLuminance();
  final lighter = math.max(firstLuminance, secondLuminance);
  final darker = math.min(firstLuminance, secondLuminance);
  return (lighter + 0.05) / (darker + 0.05);
}
