import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_nga/store/common/interface_settings_store.dart';
import 'package:flutter_nga/utils/route.dart';

class LineHeightSelectionDialog extends StatefulWidget {
  final InterfaceSettingsStore interfaceSettingsStore;

  const LineHeightSelectionDialog(
      {Key? key, required this.interfaceSettingsStore})
      : super(key: key);

  @override
  _LineHeightSelectionDialogState createState() =>
      _LineHeightSelectionDialogState();
}

class _LineHeightSelectionDialogState extends State<LineHeightSelectionDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("选择行间距"),
      content: SizedBox(
        width: double.maxFinite,
        // height: double.minPositive,
        child: Observer(
          builder: (_) {
            return ListView(
              shrinkWrap: true,
              children: [
                CustomLineHeight.normal,
                CustomLineHeight.medium,
                CustomLineHeight.large,
                CustomLineHeight.xlarge,
                CustomLineHeight.xxlarge,
              ].map((e) {
                return RadioListTile(
                  value: e,
                  groupValue: widget.interfaceSettingsStore.lineHeight,
                  onChanged: _onChanged,
                  title: Text(e.nameWithSize),
                );
              }).toList(),
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

  _onChanged(CustomLineHeight? customLineHeight) {
    widget.interfaceSettingsStore.setLineHeight(customLineHeight?.index ?? 0);
  }
}
