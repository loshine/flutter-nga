import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_nga/utils/haptics.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late List<Object?> haptics;

  setUp(() {
    haptics = [];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'HapticFeedback.vibrate') {
            haptics.add(call.arguments);
          }
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  test('reaction success uses a light impact', () async {
    await AppHaptics.reactionSucceeded();
    expect(haptics, ['HapticFeedbackType.lightImpact']);
  });

  test('dismiss updates only fire when the threshold state changes', () async {
    DismissUpdateDetails details(bool reached, bool previousReached) =>
        DismissUpdateDetails(
          direction: DismissDirection.endToStart,
          reached: reached,
          previousReached: previousReached,
          progress: 0.5,
        );

    AppHaptics.onDismissUpdate(details(false, false));
    AppHaptics.onDismissUpdate(details(true, true));
    expect(haptics, isEmpty);

    AppHaptics.onDismissUpdate(details(true, false));
    AppHaptics.onDismissUpdate(details(false, true));
    await Future<void>.delayed(Duration.zero);
    expect(haptics, [
      'HapticFeedbackType.selectionClick',
      'HapticFeedbackType.selectionClick',
    ]);
  });
}
