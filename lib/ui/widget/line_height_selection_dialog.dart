import 'package:flutter/material.dart';
import 'package:flutter_nga/providers/settings/interface_settings_provider.dart';
import 'package:flutter_nga/utils/dimen.dart';
import 'package:flutter_nga/utils/route.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class LineHeightSelectionDialog extends ConsumerWidget {
  const LineHeightSelectionDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(interfaceSettingsProvider);
    final notifier = ref.read(interfaceSettingsProvider.notifier);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimen.radiusXL),
      ),
      backgroundColor: colorScheme.surfaceContainerHigh,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 24, 0, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                "选择行间距",
                style: textTheme.headlineSmall?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomLineHeight.NORMAL,
                    CustomLineHeight.MEDIUM,
                    CustomLineHeight.LARGE,
                    CustomLineHeight.XLARGE,
                    CustomLineHeight.XXLARGE,
                  ].map((e) {
                    return _LineHeightOption(
                      title: e.nameWithSize,
                      selected: state.lineHeight == e,
                      onTap: () => notifier.setLineHeight(e.index),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Routes.pop(context),
                    child: const Text('关闭'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LineHeightOption extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const _LineHeightOption({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        color: selected ? colorScheme.secondaryContainer : null,
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: textTheme.bodyLarge?.copyWith(
                  color: selected
                      ? colorScheme.onSecondaryContainer
                      : colorScheme.onSurface,
                ),
              ),
            ),
            if (selected)
              Icon(
                Icons.check,
                color: colorScheme.onSecondaryContainer,
              ),
          ],
        ),
      ),
    );
  }
}