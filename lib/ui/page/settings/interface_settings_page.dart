import 'package:flutter/material.dart';
import 'package:flutter_nga/providers/settings/interface_settings_provider.dart';
import 'package:flutter_nga/ui/widget/line_height_selection_dialog.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class InterfaceSettingsPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(interfaceSettingsProvider);
    final notifier = ref.read(interfaceSettingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text("界面设置")),
      body: ListView(
        children: [
          Column(
            children: [
              ListTile(
                title: Text("贴子列表标题缩放"),
                trailing: Text("x ${state.titleSizeMultiple}"),
                subtitle: Text("用于控制贴子列表标题字体大小"),
              ),
              Slider(
                value: state.titleSizeMultiple,
                onChanged: (v) {
                  notifier.setTitleSizeMultiple(v);
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
                trailing: Text("x ${state.contentSizeMultiple}"),
                subtitle: Text("用于控制贴子正文内容字体大小"),
              ),
              Slider(
                value: state.contentSizeMultiple,
                onChanged: (v) {
                  notifier.setContentSizeMultiple(v);
                },
                min: 1.0,
                max: 2.0,
                divisions: 10,
              )
            ],
          ),
          ListTile(
            title: Text("贴子正文行间距"),
            trailing: Text("${state.lineHeight.nameWithSize}"),
            subtitle: Text("用于控制贴子正文以及贴子列表的行间距"),
            onTap: () => _showLineHeightSelectionDialog(context, ref),
          ),
        ],
      ),
    );
  }

  void _showLineHeightSelectionDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => LineHeightSelectionDialog(),
    );
  }
}
