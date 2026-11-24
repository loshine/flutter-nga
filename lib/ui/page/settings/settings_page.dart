import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_nga/providers/settings/base_url_settings_provider.dart';
import 'package:flutter_nga/providers/settings/theme_provider.dart';
import 'package:flutter_nga/providers/settings/user_agent_settings_provider.dart';
import 'package:flutter_nga/ui/widget/base_url_selection_dialog.dart';
import 'package:flutter_nga/ui/widget/m3_settings_group.dart';
import 'package:flutter_nga/ui/widget/readable_width.dart';
import 'package:flutter_nga/ui/widget/theme_selection_dialog.dart';
import 'package:flutter_nga/ui/widget/user_agent_selection_dialog.dart';
import 'package:flutter_nga/utils/hooks/easy_refresh_hooks.dart';
import 'package:flutter_nga/utils/route.dart';

class SettingsPage extends HookConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    usePostFrameEffect(() {
      ref.read(themeProvider.notifier).refresh();
      ref.read(baseUrlSettingsProvider.notifier).init();
      ref.read(userAgentSettingsProvider.notifier).init();
    });

    final themeState = ref.watch(themeProvider);
    final baseUrlState = ref.watch(baseUrlSettingsProvider);
    final userAgentState = ref.watch(userAgentSettingsProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final mediaPadding = MediaQuery.paddingOf(context);

    return Scaffold(
      appBar: AppBar(title: const Text("设置")),
      body: ReadableListPadding(
        padding: EdgeInsets.fromLTRB(
          mediaPadding.left,
          8,
          mediaPadding.right,
          16 + mediaPadding.bottom,
        ),
        builder: (context, padding) => ListView(
          padding: padding,
          children: [
            M3SettingsGroup(
              title: "账户",
              children: [
                M3SettingsTile(
                  icon: Icons.person_outline,
                  title: "账号管理",
                  subtitle: "管理您的账号",
                  onTap: () =>
                      Routes.navigateTo(context, Routes.ACCOUNT_MANAGEMENT),
                ),
              ],
            ),
            M3SettingsGroup(
              title: "网络",
              children: [
                M3SettingsTile(
                  icon: Icons.dns_outlined,
                  title: "服务器设置",
                  subtitle: "当前: ${baseUrlState.currentConfig.name}",
                  onTap: () => BaseUrlSelectionDialog.show(context),
                ),
                M3SettingsTile(
                  icon: Icons.devices_outlined,
                  title: "User-Agent 设置",
                  subtitle: "当前: ${userAgentState.currentConfig.name}",
                  onTap: () => UserAgentSelectionDialog.show(context),
                ),
              ],
            ),
            M3SettingsGroup(
              title: "外观",
              children: [
                M3SettingsTile(
                  icon: Icons.palette_outlined,
                  title: "主题与配色",
                  subtitle:
                      "${themeState.modeName} · ${themeState.colorDisplayName}",
                  trailing: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: themeState.effectiveSeedColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: colorScheme.outlineVariant,
                        width: 1.5,
                      ),
                    ),
                  ),
                  onTap: () => ThemeSelectionDialog.show(context),
                ),
                M3SettingsTile(
                  icon: Icons.text_fields,
                  title: "界面设置",
                  subtitle: "文字大小、行间距等阅读排版",
                  onTap: () =>
                      Routes.navigateTo(context, Routes.INTERFACE_SETTINGS),
                ),
              ],
            ),
            M3SettingsGroup(
              title: "内容",
              children: [
                M3SettingsTile(
                  icon: Icons.block_outlined,
                  title: "屏蔽设置",
                  subtitle: "屏蔽用户、关键词",
                  onTap: () =>
                      Routes.navigateTo(context, Routes.BLOCKLIST_SETTINGS),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
