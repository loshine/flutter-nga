import 'package:cupertino_ui/cupertino_ui.dart' show CupertinoButton;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:flutter_nga/providers/settings/design_style_provider.dart';
import 'package:flutter_nga/ui/widget/adaptive/app_scaffold.dart';

void main() {
  testWidgets(
    'AppScaffold shows FloatingActionButton in Material and top-bar action in Apple',
    (tester) async {
      var tapped = 0;

      Widget buildApp(AppDesignStyle style) => AppDesignStyleScope(
        style: style,
        nativeLiquidGlassSupported: false,
        macTitlebarInset: 0,
        child: MaterialApp(
          home: AppScaffold(
            title: const Text('测试页'),
            body: const Center(child: Text('内容')),
            primaryAction: AppPrimaryAction(
              tooltip: '发送',
              icon: const Icon(Icons.send),
              appleLabel: '发送',
              onPressed: () => tapped++,
            ),
          ),
        ),
      );

      await tester.pumpWidget(buildApp(AppDesignStyle.material));
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byType(AppTopBar), findsNothing);
      await tester.tap(find.byType(FloatingActionButton));
      expect(tapped, 1);

      await tester.pumpWidget(buildApp(AppDesignStyle.apple));
      await tester.pumpAndSettle();
      expect(find.byType(FloatingActionButton), findsNothing);
      expect(find.byType(AppTopBar), findsOneWidget);
      expect(find.byType(CupertinoButton), findsOneWidget);
      await tester.tap(find.text('发送'));
      expect(tapped, 2);
    },
  );
}
