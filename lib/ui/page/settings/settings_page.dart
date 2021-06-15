import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_nga/store/settings/display_mode_store.dart';
import 'package:flutter_nga/store/settings/theme_store.dart';
import 'package:flutter_nga/ui/widget/theme_selection_dialog.dart';
import 'package:flutter_nga/utils/dimen.dart';
import 'package:flutter_nga/utils/route.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<SettingsPage> {
  ThemeStore _themeStore = ThemeStore();
  DisplayModeStore _displayModeStore = DisplayModeStore();

  @override
  void initState() {
    _themeStore.refresh();
    _displayModeStore.refresh();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("设置")),
      body: ListView(
        physics: BouncingScrollPhysics(),
        shrinkWrap: true,
        children: [
          ListTile(
            title: Text("账号管理"),
            subtitle: Text(
              "管理您的账号",
              style: TextStyle(fontSize: Dimen.body),
            ),
            onTap: () => Routes.navigateTo(context, Routes.ACCOUNT_MANAGEMENT),
          ),
          ListTile(
            title: Text("外观"),
            subtitle: Observer(
              builder: (context) => Text(
                "当前外观风格: ${_themeStore.modeName}",
                style: TextStyle(fontSize: Dimen.body),
              ),
            ),
            onTap: showThemeSelectionDialog,
          ),
          // ListTile(
          //   title: Text("显示模式"),
          //   subtitle: Observer(
          //     builder: (context) =>
          //         Text("当前显示模式: ${_displayModeStore.modeName}"),
          //   ),
          //   onTap: () => Routes.navigateTo(context, Routes.ACCOUNT_MANAGEMENT),
          // ),
        ],
      ),
    );
  }

  showThemeSelectionDialog() {
    showDialog(
      context: context,
      builder: (_) => ThemeSelectionDialog(themeStore: _themeStore),
    );
  }
}
