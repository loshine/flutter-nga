import 'package:flutter/material.dart';
import 'package:flutter_nga/providers/settings/blocklist_settings_provider.dart';
import 'package:flutter_nga/utils/route.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../widget/block_mode_selection_dialog.dart';

class BlocklistSettingsPage extends ConsumerStatefulWidget {
  @override
  ConsumerState<BlocklistSettingsPage> createState() =>
      _BlocklistSettingsState();
}

class _BlocklistSettingsState extends ConsumerState<BlocklistSettingsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(blocklistSettingsProvider.notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(blocklistSettingsProvider);
    final notifier = ref.read(blocklistSettingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text("屏蔽设置")),
      body: ListView(
        shrinkWrap: true,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 12),
            child: SwitchListTile(
              value: state.clientBlockEnabled,
              onChanged: (v) => notifier.setClientBlockEnabled(v),
              title: Text("开启客户端屏蔽功能"),
              subtitle: Text("默认不开启客户端屏蔽功能，开启后会有少许性能下降"),
            ),
          ),
          SwitchListTile(
            value: state.listBlockEnabled,
            onChanged: state.clientBlockEnabled
                ? (v) => notifier.setListBlockEnabled(v)
                : null,
            title: Text("在列表页开启屏蔽功能"),
          ),
          ListTile(
            title: Text("屏蔽模式"),
            subtitle: Text("选择被屏蔽的用户、词语在客户端内的展示方式"),
            trailing: Text("${state.blockMode.name}"),
            onTap: _showBlockModeSelectionDialog,
          ),
          ListTile(
            title: Text("屏蔽用户"),
            subtitle: Text("已屏蔽 ${state.blockUserList.length} 位用户的发言"),
            onTap: () => Routes.navigateTo(context, Routes.BLOCKLIST_USERS),
          ),
          ListTile(
            title: Text("屏蔽关键词"),
            subtitle: Text("已屏蔽 ${state.blockWordList.length} 条关键词"),
            onTap: () => Routes.navigateTo(context, Routes.BLOCKLIST_KEYWORDS),
          ),
        ],
      ),
    );
  }

  void _showBlockModeSelectionDialog() {
    showDialog(
      context: context,
      builder: (_) => BlockModeSelectionDialog(),
    );
  }
}
