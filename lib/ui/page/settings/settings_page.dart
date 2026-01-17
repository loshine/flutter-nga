import 'package:flutter/material.dart';
import 'package:flutter_nga/providers/settings/theme_provider.dart';
import 'package:flutter_nga/ui/widget/theme_selection_dialog.dart';
import 'package:flutter_nga/utils/route.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SettingsPage extends ConsumerStatefulWidget {
  @override
  ConsumerState<SettingsPage> createState() => _SettingsState();
}

class _SettingsState extends ConsumerState<SettingsPage> {
  @override
  void initState() {
    super.initState();
    // Refresh theme on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(themeProvider.notifier).refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(title: Text("设置")),
      body: ListView(
        shrinkWrap: true,
        children: [
          ListTile(
            title: Text("账号管理"),
            subtitle: Text("管理您的账号"),
            onTap: () => Routes.navigateTo(context, Routes.ACCOUNT_MANAGEMENT),
          ),
          ListTile(
            title: Text("主题模式"),
            subtitle: Text("当前主题模式: ${themeState.modeName}"),
            onTap: _showThemeSelectionDialog,
          ),
          ListTile(
            title: Text("界面设置"),
            subtitle: Text("设置文字大小等界面元素"),
            onTap: () => Routes.navigateTo(context, Routes.INTERFACE_SETTINGS),
          ),
          ListTile(
            title: Text("屏蔽设置"),
            subtitle: Text("屏蔽用户、关键词等选项"),
            onTap: () => Routes.navigateTo(context, Routes.BLOCKLIST_SETTINGS),
          ),
        ],
      ),
    );
  }

  void _showThemeSelectionDialog() {
    showDialog(
      context: context,
      builder: (_) => ThemeSelectionDialog(),
    );
  }
}
