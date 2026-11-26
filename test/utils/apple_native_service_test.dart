import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_nga/utils/apple_native_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  tearDown(() {
    messenger.setMockMethodCallHandler(AppleNativeService.channel, null);
    AppleNativeService.resetForTesting();
    debugDefaultTargetPlatformOverride = null;
  });

  test('isLiquidGlassSupported returns false without channel call on non-Apple platforms', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    var invoked = false;
    messenger.setMockMethodCallHandler(AppleNativeService.channel, (
      call,
    ) async {
      invoked = true;
      return true;
    });

    expect(await AppleNativeService.isLiquidGlassSupported(), isFalse);
    expect(invoked, isFalse);
  });

  test('isLiquidGlassSupported queries native channel once and caches result on Apple platforms', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
    var calls = 0;
    messenger.setMockMethodCallHandler(AppleNativeService.channel, (
      call,
    ) async {
      if (call.method == 'isLiquidGlassSupported') {
        calls++;
        return true;
      }
      return null;
    });

    expect(await AppleNativeService.isLiquidGlassSupported(), isTrue);
    expect(await AppleNativeService.isLiquidGlassSupported(), isTrue);
    expect(calls, 1);
  });

  test('setMacWindowStyle sends appleStyle flag and falls back to 72.0 / 0.0 when native returns null', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
    final recordedArgs = <Object?>[];
    double? mockResult = 78.0;

    messenger.setMockMethodCallHandler(AppleNativeService.channel, (
      call,
    ) async {
      if (call.method == 'setWindowStyle') {
        recordedArgs.add(call.arguments);
        return mockResult;
      }
      return null;
    });

    expect(await AppleNativeService.setMacWindowStyle(appleStyle: true), 78.0);
    expect(recordedArgs.last, {'appleStyle': true});

    mockResult = null;
    expect(await AppleNativeService.setMacWindowStyle(appleStyle: true), 72.0);
    expect(await AppleNativeService.setMacWindowStyle(appleStyle: false), 0.0);
  });

  test(
    'forwards native traffic light inset and menu navigate callbacks on macOS',
    () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      final insets = <double>[];
      final routes = <String>[];

      AppleNativeService.setTrafficLightInsetListener(insets.add);
      AppleNativeService.setMenuNavigateListener(routes.add);

      const codec = StandardMethodCodec();
      await messenger.handlePlatformMessage(
        AppleNativeService.channel.name,
        codec.encodeMethodCall(
          const MethodCall('onTrafficLightInsetChanged', 74.5),
        ),
        (_) {},
      );
      await messenger.handlePlatformMessage(
        AppleNativeService.channel.name,
        codec.encodeMethodCall(const MethodCall('onMenuNavigate', '/search')),
        (_) {},
      );

      expect(insets, [74.5]);
      expect(routes, ['/search']);
    },
  );
}
