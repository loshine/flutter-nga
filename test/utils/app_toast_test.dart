import 'package:flutter/material.dart';
import 'package:flutter_nga/utils/app_toast.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toastification/toastification.dart';

void main() {
  Future<void> cleanUp(WidgetTester tester) async {
    toastification.dismissAll(delayForAnimation: false);
    await tester.pump(const Duration(milliseconds: 700));
    toastification.managers.clear();
    await tester.pumpWidget(const SizedBox.shrink());
  }

  Widget buildApp() {
    return const ToastificationWrapper(
      child: MaterialApp(
        home: Scaffold(),
      ),
    );
  }

  testWidgets('shows all semantic toast types without context', (tester) async {
    await tester.pumpWidget(buildApp());

    try {
      AppToast.success('成功消息');
      AppToast.error('错误消息');
      AppToast.warning('警告消息');
      AppToast.info('信息消息');
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('成功消息'), findsOneWidget);
      expect(find.text('错误消息'), findsOneWidget);
      expect(find.text('警告消息'), findsOneWidget);
      expect(find.text('信息消息'), findsOneWidget);
    } finally {
      await cleanUp(tester);
    }
  });

  test('uses top center on mobile platforms', () {
    expect(
      AppToast.alignmentForPlatform(TargetPlatform.android),
      Alignment.topCenter,
    );
    expect(
      AppToast.alignmentForPlatform(TargetPlatform.iOS),
      Alignment.topCenter,
    );
  });

  test('uses top right on desktop platforms', () {
    for (final platform in [
      TargetPlatform.macOS,
      TargetPlatform.windows,
      TargetPlatform.linux,
    ]) {
      expect(
        AppToast.alignmentForPlatform(platform),
        Alignment.topRight,
      );
    }
  });

  testWidgets('uses a fallback for null error messages', (tester) async {
    await tester.pumpWidget(buildApp());

    try {
      AppToast.error(null);
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('操作失败'), findsOneWidget);
    } finally {
      await cleanUp(tester);
    }
  });
}
