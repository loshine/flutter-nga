import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_nga/store/settings/blocklist_settings_store.dart';
import 'package:flutter_nga/utils/route.dart';
import 'package:provider/provider.dart';

import '../../widget/block_mode_selection_dialog.dart';

class BlocklistSettingsPage extends StatefulWidget {
  @override
  _BlocklistSettingsState createState() => _BlocklistSettingsState();
}

class _BlocklistSettingsState extends State<BlocklistSettingsPage> {
  late BlocklistSettingsStore _store;

  @override
  void initState() {
    _store = Provider.of<BlocklistSettingsStore>(context, listen: false);
    _store.load().then((value) => null);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("屏蔽设置")),
      body: Observer(
        builder: (_) {
          return ListView(
            shrinkWrap: true,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 12),
                child: SwitchListTile(
                  value: _store.clientBlockEnabled,
                  onChanged: (v) => _store.setClientBlockEnabled(v),
                  title: Text("开启客户端屏蔽功能"),
                  subtitle: Text("默认不开启客户端屏蔽功能，开启后会有少许性能下降"),
                ),
              ),
              SwitchListTile(
                value: _store.listBlockEnabled,
                onChanged: _store.clientBlockEnabled
                    ? (v) => _store.setListBlockEnabled(v)
                    : null,
                title: Text("在列表页开启屏蔽功能"),
              ),
              SwitchListTile(
                value: _store.detailsBlockEnabled,
                onChanged: _store.clientBlockEnabled
                    ? (v) => _store.setDetailsBlockEnabled(v)
                    : null,
                title: Text("在详情页开启屏蔽功能"),
              ),
              ListTile(
                title: Text("屏蔽模式"),
                subtitle: Text("选择被屏蔽的用户、词语在客户端内的展示方式"),
                trailing: Text("${_store.blockMode.name}"),
                onTap: showBlockModeSelectionDialog,
              ),
              ListTile(
                title: Text("屏蔽用户"),
                subtitle: Text("已屏蔽 ${_store.blockUserList.length} 位用户的发言"),
                onTap: () => Routes.navigateTo(context, Routes.BLOCKLIST_USERS),
              ),
              ListTile(
                title: Text("屏蔽关键词"),
                subtitle: Text("已屏蔽 ${_store.blockWordList.length} 条关键词"),
                onTap: () =>
                    Routes.navigateTo(context, Routes.BLOCKLIST_KEYWORDS),
              ),
            ],
          );
        },
      ),
    );
  }

  showBlockModeSelectionDialog() {
    showDialog(
      context: context,
      builder: (_) => BlockModeSelectionDialog(store: _store),
    );
  }
}
