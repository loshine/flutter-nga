import 'package:cupertino_ui/cupertino_ui.dart' show CupertinoAlertDialog;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:flutter_nga/providers/message/send_message_provider.dart';
import 'package:flutter_nga/providers/settings/design_style_provider.dart';
import 'package:flutter_nga/ui/page/send_message/send_message_page.dart';
import 'package:flutter_nga/utils/theme_builder.dart';

void main() {
  testWidgets('小屏打开键盘且有收信人时，表单可滚动到内容输入框', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 568);
    // 软键盘占去下半屏
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    addTearDown(tester.view.reset);

    final container = ProviderContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: SendMessagePage(mid: 0)),
      ),
    );
    await tester.pump();

    container.read(sendMessageProvider.notifier).add('收信人甲 收信人乙 收信人丙 收信人丁');
    await tester.pump();

    expect(tester.takeException(), isNull);
    final content = find.byKey(const ValueKey('send_message_content'));
    await tester.scrollUntilVisible(
      content,
      100,
      scrollable: find.byType(Scrollable).first,
    );
    expect(tester.getSize(content).height, greaterThan(100));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Apple 风格输入草稿后点击取消会弹出放弃确认弹窗', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: AppDesignStyleScope(
          style: AppDesignStyle.apple,
          nativeLiquidGlassSupported: false,
          macTitlebarInset: 0,
          child: MaterialApp(
            theme: ThemeBuilder.applyDesignStyle(
              ThemeBuilder.buildLightTheme(Colors.brown),
              isAppleStyle: true,
            ),
            home: Builder(
              builder: (context) => Scaffold(
                body: Center(
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        fullscreenDialog: true,
                        builder: (_) => const SendMessagePage(mid: 0),
                      ),
                    ),
                    child: const Text('写私信'),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('写私信'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('send_message_content')),
      '一段未发送的草稿',
    );
    await tester.pump();

    await tester.tap(find.text('取消'));
    await tester.pumpAndSettle();

    expect(find.byType(CupertinoAlertDialog), findsOneWidget);
    expect(find.text('放弃编辑？'), findsOneWidget);
  });
}
