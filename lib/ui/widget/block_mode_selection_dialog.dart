import 'package:flutter/material.dart';
import 'package:flutter_nga/providers/settings/blocklist_settings_provider.dart';
import 'package:flutter_nga/utils/route.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class BlockModeSelectionDialog extends ConsumerWidget {
  const BlockModeSelectionDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(blocklistSettingsProvider);
    final notifier = ref.read(blocklistSettingsProvider.notifier);

    return AlertDialog(
      title: Text("选择屏蔽模式"),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView(
          shrinkWrap: true,
          children: BlockMode.values
              .map((e) => RadioListTile(
                    title: Text(e.name),
                    value: e,
                    groupValue: state.blockMode,
                    onChanged: (BlockMode? mode) {
                      notifier.updateBlockMode(mode ?? BlockMode.COLLAPSE);
                    },
                  ))
              .toList(),
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
