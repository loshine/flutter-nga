import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_nga/store/settings/blocklist_settings_store.dart';
import 'package:flutter_nga/utils/route.dart';

class BlockModeSelectionDialog extends StatefulWidget {
  final BlocklistSettingsStore store;

  const BlockModeSelectionDialog({Key? key, required this.store})
      : super(key: key);

  @override
  _BlockModeSelectionDialogState createState() =>
      _BlockModeSelectionDialogState();
}

class _BlockModeSelectionDialogState extends State<BlockModeSelectionDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("选择屏蔽模式"),
      content: SizedBox(
        width: double.maxFinite,
        // height: double.minPositive,
        child: Observer(
          builder: (_) {
            return ListView(
              shrinkWrap: true,
              children: BlockMode.values
                  .map((e) => RadioListTile(
                        title: Text(e.name),
                        value: e,
                        groupValue: widget.store.blockMode,
                        onChanged: _onChanged,
                      ))
                  .toList(),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Routes.pop(context),
          child: Text('关闭'),
        )
      ],
    );
  }

  _onChanged(BlockMode? mode) {
    widget.store.updateBlockMode(mode ?? BlockMode.COLLAPSE);
  }
}
