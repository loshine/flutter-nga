import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nga/providers/settings/theme_provider.dart';
import 'package:flutter_nga/utils/route.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ThemeSelectionDialog extends ConsumerWidget {
  const ThemeSelectionDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(themeProvider);
    final notifier = ref.read(themeProvider.notifier);

    return AlertDialog(
      title: Text("选择主题模式"),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView(
          shrinkWrap: true,
          children: [
            RadioListTile(
              value: AdaptiveThemeMode.system,
              groupValue: state.mode,
              onChanged: (AdaptiveThemeMode? mode) =>
                  notifier.update(context, mode ?? AdaptiveThemeMode.light),
              title: Text("跟随系统"),
            ),
            RadioListTile(
              value: AdaptiveThemeMode.light,
              groupValue: state.mode,
              onChanged: (AdaptiveThemeMode? mode) =>
                  notifier.update(context, mode ?? AdaptiveThemeMode.light),
              title: Text("亮色主题"),
            ),
            RadioListTile(
              value: AdaptiveThemeMode.dark,
              groupValue: state.mode,
              onChanged: (AdaptiveThemeMode? mode) =>
                  notifier.update(context, mode ?? AdaptiveThemeMode.light),
              title: Text("暗色主题"),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Routes.pop(context),
          child: Text('关闭'),
        )
      ],
    );
  }
}
