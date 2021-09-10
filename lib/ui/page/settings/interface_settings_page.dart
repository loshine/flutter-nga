import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_nga/store/common/interface_settings_store.dart';
import 'package:flutter_nga/ui/widget/line_height_selection_dialog.dart';
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
                    title: Text("贴子列表标题缩放"),
                    trailing: Text("x ${store.titleSizeMultiple}"),
                    subtitle: Text("用于控制贴子列表标题字体大小"),
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
              ),
              Column(
                children: [
                  ListTile(
                    title: Text("贴子正文字体缩放"),
                    trailing: Text("x ${store.contentSizeMultiple}"),
                    subtitle: Text("用于控制贴子正文内容字体大小"),
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
              ListTile(
                title: Text("贴子正文行间距"),
                trailing: Text("${store.lineHeight.nameWithSize}"),
                subtitle: Text("用于控制贴子正文以及贴子列表的行间距"),
                onTap: showLineHeightSelectionDialog,
              ),
            ],
          );
        },
      ),
    );
  }

  showLineHeightSelectionDialog() {
    showDialog(
      context: context,
      builder: (_) => LineHeightSelectionDialog(
          interfaceSettingsStore:
              Provider.of<InterfaceSettingsStore>(context, listen: false)),
    );
  }
}
