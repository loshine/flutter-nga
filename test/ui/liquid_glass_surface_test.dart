import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:flutter_nga/providers/settings/design_style_provider.dart';
import 'package:flutter_nga/ui/widget/adaptive/liquid_glass_surface.dart';

void main() {
  testWidgets(
    'LiquidGlassSurface falls back to BackdropFilter when native glass is unavailable',
    (tester) async {
      await tester.pumpWidget(
        AppDesignStyleScope(
          style: AppDesignStyle.apple,
          nativeLiquidGlassSupported: false,
          macTitlebarInset: 0,
          child: const MaterialApp(
            home: Scaffold(body: LiquidGlassSurface(child: Text('玻璃卡片'))),
          ),
        ),
      );

      expect(find.byType(BackdropFilter), findsOneWidget);
      expect(find.text('玻璃卡片'), findsOneWidget);
    },
  );

  testWidgets(
    'LiquidGlassSurface uses opaque surface in high contrast accessibility mode',
    (tester) async {
      await tester.pumpWidget(
        AppDesignStyleScope(
          style: AppDesignStyle.apple,
          nativeLiquidGlassSupported: true,
          macTitlebarInset: 0,
          child: const MediaQuery(
            data: MediaQueryData(highContrast: true),
            child: MaterialApp(
              home: Scaffold(body: LiquidGlassSurface(child: Text('高对比度'))),
            ),
          ),
        ),
      );

      expect(find.byType(BackdropFilter), findsNothing);
      expect(find.text('高对比度'), findsOneWidget);
    },
  );
}
