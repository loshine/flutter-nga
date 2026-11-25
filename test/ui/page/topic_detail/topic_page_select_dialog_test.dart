import 'package:cupertino_ui/cupertino_ui.dart'
    show CupertinoSlider, CupertinoSlidingSegmentedControl;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:flutter_nga/providers/settings/design_style_provider.dart';
import 'package:flutter_nga/ui/page/topic_detail/topic_page_select_dialog.dart';
import 'package:flutter_nga/utils/theme_builder.dart';

void main() {
  testWidgets('单页帖子安全渲染且禁用滑块', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeBuilder.buildLightTheme(Colors.brown),
        home: const Scaffold(
          body: TopicPageSelectDialog(currentPage: 1, maxPage: 1, maxFloor: 1),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    final slider = tester.widget<Slider>(find.byType(Slider));
    expect(slider.onChanged, isNull);
  });

  testWidgets('支持数字直输、步进按钮与楼层模式切换', (tester) async {
    (bool, int)? result;
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeBuilder.buildLightTheme(Colors.brown),
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: FilledButton(
                onPressed: () => TopicPageSelectDialog.show(
                  context,
                  currentPage: 2,
                  maxPage: 100,
                  maxFloor: 2000,
                  pageSelectedCallback: (isPage, target) {
                    result = (isPage, target);
                  },
                ),
                child: const Text('跳转'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('跳转'));
    await tester.pumpAndSettle();

    // 切换到楼层模式
    await tester.tap(find.text('楼层'));
    await tester.pumpAndSettle();

    // 直接输入高楼层并步进 +1
    await tester.enterText(
      find.byKey(const ValueKey('page_jump_input')),
      '1280',
    );
    await tester.pump();
    await tester.tap(find.byTooltip('增加'));
    await tester.pump();

    await tester.tap(find.text('确认'));
    await tester.pumpAndSettle();

    expect(result, (false, 1281));
  });

  testWidgets('Apple 风格使用 CupertinoSlider 与 CupertinoSlidingSegmentedControl', (
    tester,
  ) async {
    await tester.pumpWidget(
      AppDesignStyleScope(
        style: AppDesignStyle.apple,
        nativeLiquidGlassSupported: false,
        macTitlebarInset: 0,
        child: MaterialApp(
          theme: ThemeBuilder.applyDesignStyle(
            ThemeBuilder.buildLightTheme(Colors.brown),
            isAppleStyle: true,
          ),
          home: const Scaffold(
            body: TopicPageSelectDialog(
              currentPage: 2,
              maxPage: 20,
              maxFloor: 400,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(CupertinoSlider), findsOneWidget);
    expect(find.byType(CupertinoSlidingSegmentedControl<bool>), findsOneWidget);
  });
}
