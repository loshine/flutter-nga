import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:flutter_nga/utils/hooks/scroll_to_top.dart';

void main() {
  group('DoubleTapDetector', () {
    test('two taps within the interval count as a double tap', () {
      var now = DateTime(2026);
      final detector = DoubleTapDetector(clock: () => now);
      expect(detector.tap(), isFalse);
      now = now.add(const Duration(milliseconds: 300));
      expect(detector.tap(), isTrue);
      // 第三次点击重新计数
      now = now.add(const Duration(milliseconds: 100));
      expect(detector.tap(), isFalse);
    });

    test('slow taps and resets do not trigger', () {
      var now = DateTime(2026);
      final detector = DoubleTapDetector(clock: () => now);
      detector.tap();
      now = now.add(const Duration(seconds: 1));
      expect(detector.tap(), isFalse);
      detector.reset();
      now = now.add(const Duration(milliseconds: 100));
      expect(detector.tap(), isFalse);
    });
  });

  testWidgets('signal scrolls the list back to the top', (tester) async {
    final signal = ScrollToTopSignal();
    addTearDown(signal.dispose);
    late ScrollController controller;

    await tester.pumpWidget(
      MaterialApp(
        home: HookBuilder(
          builder: (context) {
            controller = useScrollToTopController(signal);
            return ListView.builder(
              controller: controller,
              itemCount: 500,
              itemBuilder: (_, i) => SizedBox(height: 50, child: Text('$i')),
            );
          },
        ),
      ),
    );

    controller.jumpTo(10000);
    await tester.pump();
    expect(controller.offset, 10000);

    signal.fire();
    await tester.pumpAndSettle();
    expect(controller.offset, 0);
  });
}
