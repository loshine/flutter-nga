import 'package:flutter/foundation.dart';
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

  testWidgets(
    'native LiquidGlassSurface updates PlatformView key when brightness or tint changes',
    (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);

      Widget buildApp({required Brightness brightness, Color? tintColor}) {
        return AppDesignStyleScope(
          style: AppDesignStyle.apple,
          nativeLiquidGlassSupported: true,
          macTitlebarInset: 0,
          child: MaterialApp(
            theme: ThemeData(brightness: brightness),
            home: Scaffold(
              body: LiquidGlassSurface(
                tintColor: tintColor,
                child: const Text('原生玻璃'),
              ),
            ),
          ),
        );
      }

      await tester.pumpWidget(buildApp(brightness: Brightness.light));
      final lightView = tester.widget<AppKitView>(find.byType(AppKitView));
      expect((lightView.creationParams as Map)['isDark'], isFalse);

      await tester.pumpWidget(buildApp(brightness: Brightness.dark));
      await tester.pumpAndSettle();
      final darkView = tester.widget<AppKitView>(find.byType(AppKitView));
      expect((darkView.creationParams as Map)['isDark'], isTrue);
      expect(darkView.key, isNot(equals(lightView.key)));

      await tester.pumpWidget(
        buildApp(brightness: Brightness.dark, tintColor: Colors.blue),
      );
      await tester.pumpAndSettle();
      final tintedView = tester.widget<AppKitView>(find.byType(AppKitView));
      expect(tintedView.key, isNot(equals(darkView.key)));
    },
  );
}
