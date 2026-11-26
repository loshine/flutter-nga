import 'package:cupertino_ui/cupertino_ui.dart'
    show
        CupertinoAlertDialog,
        CupertinoSlider,
        CupertinoSlidingSegmentedControl,
        CupertinoSwitch;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:flutter_nga/providers/settings/design_style_provider.dart';
import 'package:flutter_nga/ui/widget/adaptive/adaptive_controls.dart';
import 'package:flutter_nga/ui/widget/m3_dialog.dart';
import 'package:flutter_nga/ui/widget/m3_settings_group.dart';

Widget _wrapWithStyle(AppDesignStyle style, Widget child) {
  return AppDesignStyleScope(
    style: style,
    nativeLiquidGlassSupported: false,
    macTitlebarInset: 0,
    child: MaterialApp(home: Scaffold(body: child)),
  );
}

void main() {
  testWidgets('AppSwitch and AppSlider switch between Material and Cupertino', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrapWithStyle(
        AppDesignStyle.material,
        Column(
          children: [
            AppSwitch(value: true, onChanged: (_) {}),
            AppSlider(value: 1.5, min: 1, max: 2, onChanged: (_) {}),
          ],
        ),
      ),
    );
    expect(find.byType(Switch), findsOneWidget);
    expect(find.byType(Slider), findsOneWidget);
    expect(find.byType(CupertinoSwitch), findsNothing);
    expect(find.byType(CupertinoSlider), findsNothing);

    await tester.pumpWidget(
      _wrapWithStyle(
        AppDesignStyle.apple,
        Column(
          children: [
            AppSwitch(value: true, onChanged: (_) {}),
            AppSlider(value: 1.5, min: 1, max: 2, onChanged: (_) {}),
          ],
        ),
      ),
    );
    expect(find.byType(CupertinoSwitch), findsOneWidget);
    expect(find.byType(CupertinoSlider), findsOneWidget);
    expect(find.byType(Switch), findsNothing);
    expect(find.byType(Slider), findsNothing);
  });

  testWidgets('AppSegmentedControl switches widget implementation by style', (
    tester,
  ) async {
    const segments = [
      AppSegment(value: 0, label: 'A'),
      AppSegment(value: 1, label: 'B'),
    ];
    await tester.pumpWidget(
      _wrapWithStyle(
        AppDesignStyle.material,
        AppSegmentedControl<int>(
          segments: segments,
          selected: 0,
          onChanged: (_) {},
        ),
      ),
    );
    expect(find.byType(SegmentedButton<int>), findsOneWidget);

    await tester.pumpWidget(
      _wrapWithStyle(
        AppDesignStyle.apple,
        AppSegmentedControl<int>(
          segments: segments,
          selected: 0,
          onChanged: (_) {},
        ),
      ),
    );
    expect(find.byType(CupertinoSlidingSegmentedControl<int>), findsOneWidget);
  });

  testWidgets('M3ConfirmDialog renders CupertinoAlertDialog in Apple style', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrapWithStyle(
        AppDesignStyle.apple,
        const M3ConfirmDialog(
          title: '确认退出',
          content: '是否退出当前账号？',
          destructive: true,
        ),
      ),
    );
    expect(find.byType(CupertinoAlertDialog), findsOneWidget);
    expect(find.text('确认退出'), findsOneWidget);
  });

  testWidgets('M3SettingsSwitchTile uses CupertinoSwitch in Apple style', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrapWithStyle(
        AppDesignStyle.apple,
        M3SettingsGroup(
          title: '开关组',
          children: [
            M3SettingsSwitchTile(
              icon: Icons.block,
              title: '开启屏蔽',
              value: true,
              onChanged: (_) {},
            ),
          ],
        ),
      ),
    );
    expect(find.byType(CupertinoSwitch), findsOneWidget);
  });
}
