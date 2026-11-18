import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_nga/ui/widget/dash.dart';

List<Color?> _dashColors(WidgetTester tester) => tester
    .widgetList<DecoratedBox>(
      find.descendant(
        of: find.byType(Dash),
        matching: find.byType(DecoratedBox),
      ),
    )
    .map((box) => (box.decoration as BoxDecoration).color)
    .toSet()
    .toList();

void main() {
  for (final brightness in Brightness.values) {
    testWidgets('dash defaults to outlineVariant in $brightness mode', (
      tester,
    ) async {
      final theme = ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.brown,
          brightness: brightness,
        ),
      );
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: const Scaffold(body: Dash(length: 100)),
        ),
      );

      expect(_dashColors(tester), [theme.colorScheme.outlineVariant]);
    });
  }

  testWidgets('explicit dash color wins over theme', (tester) async {
    const color = Color(0xFF123456);
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Dash(length: 100, dashColor: color)),
      ),
    );

    expect(_dashColors(tester), [color]);
  });
}
