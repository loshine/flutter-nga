import 'package:flutter/material.dart';
import 'package:flutter_nga/providers/settings/blocklist_settings_provider.dart';
import 'package:flutter_nga/utils/code_utils.dart' as code_utils;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'blocklist_edit_dialog.dart';

class BlocklistUsersPage extends ConsumerStatefulWidget {
  @override
  ConsumerState<BlocklistUsersPage> createState() => _BlocklistUsersPageState();
}

class _BlocklistUsersPageState extends ConsumerState<BlocklistUsersPage> {
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
        onPressed: () => _showAddDialog(notifier),
        child: Icon(Icons.add),
      ),
    );
  }

  void _deleteAll(BlocklistSettingsNotifier notifier) {
    notifier
        .deleteAllUsers()
        .then((value) => Fluttertoast.showToast(msg: value))
        .catchError((e) {
      Fluttertoast.showToast(msg: e.toString());
      return false;
    });
  }

  void _delete(BlocklistSettingsNotifier notifier, String user) {
    notifier
        .deleteUser(user)
        .then((value) => Fluttertoast.showToast(msg: value))
        .catchError((e) {
      Fluttertoast.showToast(msg: e.toString());
      return false;
    });
  }

  void _add(BlocklistSettingsNotifier notifier, String user) {
    notifier
        .addUser(user)
        .then((value) => Fluttertoast.showToast(msg: value))
        .catchError((e) {
      Fluttertoast.showToast(msg: e.toString());
      return false;
    });
  }

  void _showAddDialog(BlocklistSettingsNotifier notifier) {
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
