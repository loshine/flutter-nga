import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_nga/providers/settings/blocklist_settings_provider.dart';
import 'package:flutter_nga/ui/widget/m3_settings_group.dart';
import 'package:flutter_nga/ui/widget/readable_width.dart';
import 'package:flutter_nga/utils/hooks/easy_refresh_hooks.dart';
import 'package:flutter_nga/utils/route.dart';

import '../../widget/block_mode_selection_dialog.dart';

class BlocklistSettingsPage extends HookConsumerWidget {
  const BlocklistSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    usePostFrameEffect(() {
      ref.read(blocklistSettingsProvider.notifier).load();
    });

    final state = ref.watch(blocklistSettingsProvider);
    final notifier = ref.read(blocklistSettingsProvider.notifier);
    final mediaPadding = MediaQuery.paddingOf(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text("屏蔽设置")),
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
              title: "屏蔽开关",
              children: [
                M3SettingsSwitchTile(
                  icon: Icons.shield_outlined,
                  title: "开启客户端屏蔽功能",
                  subtitle: "默认关闭，开启后在客户端按规则过滤内容",
                  value: state.clientBlockEnabled,
                  onChanged: notifier.setClientBlockEnabled,
                ),
                M3SettingsSwitchTile(
                  icon: Icons.view_list_outlined,
                  title: "在列表页开启屏蔽功能",
                  value: state.listBlockEnabled,
                  onChanged: state.clientBlockEnabled
                      ? notifier.setListBlockEnabled
                      : null,
                ),
                M3SettingsSwitchTile(
                  icon: Icons.article_outlined,
                  title: "在详情页开启屏蔽功能",
                  value: state.detailsBlockEnabled,
                  onChanged: state.clientBlockEnabled
                      ? notifier.setDetailsBlockEnabled
                      : null,
                ),
              ],
            ),
            M3SettingsGroup(
              title: "屏蔽规则",
              children: [
                M3SettingsTile(
                  icon: Icons.tune_outlined,
                  title: "屏蔽模式",
                  subtitle: "选择被屏蔽的用户、词语在客户端内的展示方式",
                  trailing: Text(
                    state.blockMode.name,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onTap: () => showDialog(
                    context: context,
                    builder: (_) => const BlockModeSelectionDialog(),
                  ),
                ),
                M3SettingsTile(
                  icon: Icons.person_off_outlined,
                  title: "屏蔽用户",
                  subtitle: "已屏蔽 ${state.blockUserList.length} 位用户的发言",
                  onTap: () =>
                      Routes.navigateTo(context, Routes.BLOCKLIST_USERS),
                ),
                M3SettingsTile(
                  icon: Icons.text_snippet_outlined,
                  title: "屏蔽关键词",
                  subtitle: "已屏蔽 ${state.blockWordList.length} 条关键词",
                  onTap: () =>
                      Routes.navigateTo(context, Routes.BLOCKLIST_KEYWORDS),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
