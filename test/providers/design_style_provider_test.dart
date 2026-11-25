import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:flutter_nga/data/core/app_preferences.dart';
import 'package:flutter_nga/providers/settings/design_style_provider.dart';
import 'package:flutter_nga/utils/apple_native_service.dart';

import '../test_utils/preferences.dart';

void main() {
  setUp(() {
    AppleNativeService.resetForTesting();
  });

  tearDown(() {
    AppleNativeService.resetForTesting();
  });

  test(
    'auto preference resolves apple on iOS/macOS and material elsewhere',
    () {
      const state = DesignStyleState(preference: DesignStylePreference.auto);
      expect(state.resolveFor(TargetPlatform.iOS), AppDesignStyle.apple);
      expect(state.resolveFor(TargetPlatform.macOS), AppDesignStyle.apple);
      expect(state.resolveFor(TargetPlatform.android), AppDesignStyle.material);
      expect(state.resolveFor(TargetPlatform.windows), AppDesignStyle.material);
      expect(state.resolveFor(TargetPlatform.linux), AppDesignStyle.material);
    },
  );

  test('explicit preference overrides platform default', () {
    const forcedMaterial = DesignStyleState(
      preference: DesignStylePreference.material,
    );
    expect(
      forcedMaterial.resolveFor(TargetPlatform.iOS),
      AppDesignStyle.material,
    );
    expect(
      forcedMaterial.resolveFor(TargetPlatform.macOS),
      AppDesignStyle.material,
    );

    const forcedApple = DesignStyleState(
      preference: DesignStylePreference.apple,
    );
    expect(
      forcedApple.resolveFor(TargetPlatform.android),
      AppDesignStyle.apple,
    );
    expect(
      forcedApple.resolveFor(TargetPlatform.windows),
      AppDesignStyle.apple,
    );
  });

  test('DesignStyleNotifier loads and persists preference', () async {
    setUpTestPreferences(
      current: {
        PrefsKeys.designStyle: DesignStylePreference.apple.storageValue,
      },
    );
    AppleNativeService.debugOverrideLiquidGlassSupported = true;

    final loaded = await DesignStyleNotifier.loadSaved();
    expect(loaded.preference, DesignStylePreference.apple);
    expect(loaded.nativeLiquidGlassSupported, isTrue);

    final container = ProviderContainer(
      overrides: [
        designStyleProvider.overrideWith(() => DesignStyleNotifier(loaded)),
      ],
    );
    addTearDown(container.dispose);

    await container
        .read(designStyleProvider.notifier)
        .setPreference(DesignStylePreference.material);
    expect(
      container.read(designStyleProvider).preference,
      DesignStylePreference.material,
    );

    final prefs = await AppPreferences.instance();
    expect(
      prefs.getString(PrefsKeys.designStyle),
      DesignStylePreference.material.storageValue,
    );
  });

  testWidgets('AppDesignStyleScope propagates style and capabilities', (
    tester,
  ) async {
    late AppDesignStyle resolved;
    late bool liquidGlass;
    late double inset;

    await tester.pumpWidget(
      AppDesignStyleScope(
        style: AppDesignStyle.apple,
        nativeLiquidGlassSupported: true,
        macTitlebarInset: 28,
        child: MaterialApp(
          home: Builder(
            builder: (context) {
              resolved = context.designStyle;
              liquidGlass = context.supportsNativeLiquidGlass;
              inset = context.macTitlebarInset;
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );

    expect(resolved, AppDesignStyle.apple);
    expect(liquidGlass, isTrue);
    expect(inset, 28);
  });
}
