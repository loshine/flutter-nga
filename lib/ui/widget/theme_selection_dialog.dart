import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_nga/store/settings/theme_store.dart';
import 'package:flutter_nga/utils/route.dart';

class ThemeSelectionDialog extends StatefulWidget {
  final ThemeStore themeStore;

  const ThemeSelectionDialog({Key? key, required this.themeStore})
      : super(key: key);

  @override
  _ThemeSelectionDialogState createState() => _ThemeSelectionDialogState();
}

class _ThemeSelectionDialogState extends State<ThemeSelectionDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("选择外观风格"),
      content: SizedBox(
        width: double.maxFinite,
        // height: double.minPositive,
        child: Observer(
          builder: (_) {
            return ListView(
              shrinkWrap: true,
              children: [
                RadioListTile(
                  value: AdaptiveThemeMode.system,
                  groupValue: widget.themeStore.mode,
                  onChanged: _onChanged,
                  title: Text("跟随系统"),
                ),
                RadioListTile(
                  value: AdaptiveThemeMode.light,
                  groupValue: widget.themeStore.mode,
                  onChanged: _onChanged,
                  title: Text("亮色模式"),
                ),
                RadioListTile(
                  value: AdaptiveThemeMode.dark,
                  groupValue: widget.themeStore.mode,
                  onChanged: _onChanged,
                  title: Text("暗色模式"),
                ),
              ],
            );
          },
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

  _onChanged(AdaptiveThemeMode? adaptiveThemeMode) {
    widget.themeStore
        .update(context, adaptiveThemeMode ?? AdaptiveThemeMode.light);
  }
}
