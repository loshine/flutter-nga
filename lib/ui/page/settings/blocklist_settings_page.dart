import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_nga/store/settings/blocklist_settings_store.dart';
import 'package:provider/provider.dart';

class BlocklistSettingsPage extends StatefulWidget {
  @override
  _BlocklistSettingsState createState() => _BlocklistSettingsState();
}

class _BlocklistSettingsState extends State<BlocklistSettingsPage> {
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
      appBar: AppBar(title: Text("屏蔽设置")),
      body: Observer(
        builder: (_) {
          return ListView(
            children: [
              SwitchListTile(
                value: store.clientEnabled,
                onChanged: (v) => store.setClientEnabled(v),
                title: Text("开启客户端屏蔽功能"),
                subtitle: Text("默认不开启客户端屏蔽功能，开启后会有少许性能下降"),
              ),
              SwitchListTile(
                value: store.clientEnabled,
                onChanged: (v) => store.setClientEnabled(v),
                title: Text("在列表页开启屏蔽功能"),
                subtitle: Text("会降低列表页加载速度"),
              ),
              SwitchListTile(
                value: store.clientEnabled,
                onChanged: (v) => store.setClientEnabled(v),
                title: Text("在详情页开启屏蔽功能"),
                subtitle: Text("会降详情页加载速度"),
              ),
              ListTile(
                title: Text("屏蔽模式"),
                subtitle: Text("选择被屏蔽的用户、词语在客户端内的展示方式"),
                trailing: Text("折叠"),
              ),
              ListTile(
                title: Text("屏蔽用户"),
                subtitle: Text("已屏蔽 ${store.blockUserList.length} 位用户的发言"),
              ),
              ListTile(
                title: Text("屏蔽关键词"),
                subtitle: Text("已屏蔽 ${store.blockWordList.length} 条关键词"),
              ),
            ],
          );
        },
      ),
    );
  }
}
