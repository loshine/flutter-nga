import 'package:flutter/material.dart';
import 'package:flutter_nga/providers/settings/blocklist_settings_provider.dart';
import 'package:flutter_nga/utils/code_utils.dart' as code_utils;
import 'package:flutter_nga/utils/app_toast.dart';
import 'package:flutter_nga/utils/hooks/easy_refresh_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'blocklist_edit_dialog.dart';

class BlocklistUsersPage extends HookConsumerWidget {
  const BlocklistUsersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    usePostFrameEffect(() {
      ref.read(blocklistSettingsProvider.notifier).load();
    });

    final state = ref.watch(blocklistSettingsProvider);
    final notifier = ref.read(blocklistSettingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text("屏蔽用户"),
        actions: [
          IconButton(
            onPressed: () => _deleteAll(notifier),
            icon: Icon(
              Icons.delete_forever,
              color: Colors.white,
            ),
            tooltip: "删除所有屏蔽用户",
          ),
        ],
      ),
      body: ListView(
        children: state.blockUserList
            .map((e) => ListTile(
                  title: Text(code_utils.unescapeHtml(e)),
                  trailing: Icon(Icons.delete),
                  onTap: () => _delete(notifier, e),
                ))
            .toList(),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: "添加屏蔽用户",
        onPressed: () => _showAddDialog(context, notifier),
        child: Icon(Icons.add),
      ),
    );
  }

  Future<void> _deleteAll(BlocklistSettingsNotifier notifier) async {
    try {
      AppToast.success(await notifier.deleteAllUsers());
    } catch (e) {
      AppToast.error(e.toString());
    }
  }

  Future<void> _delete(
    BlocklistSettingsNotifier notifier,
    String user,
  ) async {
    try {
      AppToast.success(await notifier.deleteUser(user));
    } catch (e) {
      AppToast.error(e.toString());
    }
  }

  Future<void> _add(
    BlocklistSettingsNotifier notifier,
    String user,
  ) async {
    try {
      AppToast.success(await notifier.addUser(user));
    } catch (e) {
      AppToast.error(e.toString());
    }
  }

  void _showAddDialog(
    BuildContext context,
    BlocklistSettingsNotifier notifier,
  ) {
    showDialog(
        context: context,
        builder: (_) {
          return BlocklistEditDialog(
            title: "添加屏蔽用户",
            inputHint: "UID 或 用户名",
            callback: (user) => _add(notifier, user),
          );
        });
  }
}
