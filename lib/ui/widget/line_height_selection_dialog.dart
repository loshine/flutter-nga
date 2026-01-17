import 'package:flutter/material.dart';
import 'package:flutter_nga/providers/settings/interface_settings_provider.dart';
import 'package:flutter_nga/utils/route.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class LineHeightSelectionDialog extends ConsumerWidget {
  const LineHeightSelectionDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(interfaceSettingsProvider);
    final notifier = ref.read(interfaceSettingsProvider.notifier);

    return AlertDialog(
      title: Text("选择行间距"),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView(
          shrinkWrap: true,
          children: [
            CustomLineHeight.NORMAL,
            CustomLineHeight.MEDIUM,
            CustomLineHeight.LARGE,
            CustomLineHeight.XLARGE,
            CustomLineHeight.XXLARGE,
          ].map((e) {
            return RadioListTile(
              value: e,
              groupValue: state.lineHeight,
              onChanged: (CustomLineHeight? customLineHeight) {
                notifier.setLineHeight(customLineHeight?.index ?? 0);
              },
              title: Text(e.nameWithSize),
            );
          }).toList(),
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
}
