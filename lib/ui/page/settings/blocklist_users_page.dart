import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_nga/store/settings/blocklist_settings_store.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:flutter_nga/utils/code_utils.dart' as codeUtils;

import 'blocklist_edit_dialog.dart';

class BlocklistUsersPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _BlocklistUsersPageState();
  }
}

class _BlocklistUsersPageState extends State<BlocklistUsersPage> {
  late BlocklistSettingsStore store;

  @override
  void initState() {
    store = Provider.of<BlocklistSettingsStore>(context, listen: false);
    store.load().then((value) => null);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("屏蔽用户"),
        actions: [
          IconButton(
            onPressed: _deleteAll,
            icon: Icon(
              Icons.delete_forever,
              color: Colors.white,
            ),
            tooltip: "删除所有屏蔽用户",
          ),
        ],
      ),
      body: Observer(
        builder: (_) {
          return ListView(
            children: store.blockUserList
                .map((e) => ListTile(
                      title: Text(codeUtils.unescapeHtml(e)),
                      trailing: Icon(Icons.delete),
                      onTap: () => _delete(e),
                    ))
                .toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: "添加屏蔽用户",
        onPressed: _showAddDialog,
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  void _deleteAll() {
    store
        .deleteAllUsers()
        .then((value) => Fluttertoast.showToast(msg: value))
        .catchError((e) {
      Fluttertoast.showToast(msg: e.toString());
    });
  }

  void _delete(String user) {
    store
        .deleteUser(user)
        .then((value) => Fluttertoast.showToast(msg: value))
        .catchError((e) {
      Fluttertoast.showToast(msg: e.toString());
    });
  }

  void _add(String user) {
    store
        .addUser(user)
        .then((value) => Fluttertoast.showToast(msg: value))
        .catchError((e) {
      Fluttertoast.showToast(msg: e.toString());
    });
  }

  void _showAddDialog() {
    showDialog(
        context: context,
        builder: (_) {
          return BlocklistEditDialog(
            title: "添加屏蔽用户",
            inputHint: "UID 或 用户名",
            callback: _add,
          );
        });
  }
}
