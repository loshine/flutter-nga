import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:flutter_nga/utils/motion.dart';

void main() {
  testWidgets('Motion.resolveDuration 遵循系统减弱动画设置', (tester) async {
    late Duration normalDuration;
    late Duration reducedDuration;

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(disableAnimations: false),
        child: Builder(
          builder: (context) {
            normalDuration = Motion.resolveDuration(
              context,
              Motion.durationMedium2,
            );
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: Builder(
          builder: (context) {
            reducedDuration = Motion.resolveDuration(
              context,
              Motion.durationMedium2,
            );
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(normalDuration, Motion.durationMedium2);
    expect(reducedDuration, Duration.zero);
  });
}
