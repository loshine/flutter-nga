import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_nga/store/common/interface_settings_store.dart';
import 'package:provider/provider.dart';

class InterfaceSettingsPage extends StatefulWidget {
  @override
  _InterfaceSettingsState createState() => _InterfaceSettingsState();
}

class _InterfaceSettingsState extends State<InterfaceSettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("界面设置")),
      body: Observer(
        builder: (c) {
          final store = Provider.of<InterfaceSettingsStore>(c, listen: false);
          return ListView(
            children: [
              Column(
                children: [
                  ListTile(
                    title: Text("正文字体缩放"),
                    trailing: Text("x ${store.contentSizeMultiple}"),
                  ),
                  Slider(
                    value: store.contentSizeMultiple,
                    onChanged: (v) {
                      store.setContentSizeMultiple(v);
                    },
                    min: 1.0,
                    max: 2.0,
                    divisions: 10,
                  )
                ],
              ),
              Column(
                children: [
                  ListTile(
                    title: Text("贴子列表标题缩放"),
                    trailing: Text("x ${store.titleSizeMultiple}"),
                  ),
                  Slider(
                    value: store.titleSizeMultiple,
                    onChanged: (v) {
                      store.setTitleSizeMultiple(v);
                    },
                    min: 1.0,
                    max: 2.0,
                    divisions: 10,
                  )
                ],
              )
            ],
          );
        },
      ),
    );
  }
}
