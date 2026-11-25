import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_nga/providers/settings/blocklist_settings_provider.dart';
import 'package:flutter_nga/providers/settings/design_style_provider.dart';
import 'package:flutter_nga/ui/widget/adaptive/app_icons.dart';
import 'package:flutter_nga/ui/widget/m3_dialog.dart';
import 'package:flutter_nga/utils/dimen.dart';

class BlockModeSelectionDialog extends ConsumerWidget {
  const BlockModeSelectionDialog({super.key, this.embedded = false});

  final bool embedded;

  static Future<void> show(BuildContext context) {
    return showM3SelectionSheet<void>(
      context: context,
      builder: (_) => const BlockModeSelectionDialog(embedded: true),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(blocklistSettingsProvider);
    final notifier = ref.read(blocklistSettingsProvider.notifier);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isApple = context.isAppleStyle;

    final body = Padding(
      padding: EdgeInsets.fromLTRB(0, embedded ? 4 : 24, 0, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              "选择屏蔽模式",
              textAlign: isApple ? TextAlign.center : TextAlign.start,
              style: (isApple ? textTheme.titleMedium : textTheme.headlineSmall)
                  ?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: isApple ? FontWeight.w600 : null,
                  ),
            ),
          ),
          const SizedBox(height: 12),
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: BlockMode.values.map((mode) {
                  return _BlockModeOption(
                    title: mode.name,
                    selected: state.blockMode == mode,
                    onTap: () => notifier.updateBlockMode(mode),
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
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('关闭'),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (embedded) return body;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimen.radiusXL),
      ),
      backgroundColor: colorScheme.surfaceContainerHigh,
      child: body,
    );
  }
}

class _BlockModeOption extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const _BlockModeOption({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isApple = context.isAppleStyle;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: selected
            ? (isApple
                  ? colorScheme.primary.withValues(alpha: 0.12)
                  : colorScheme.secondaryContainer)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(Dimen.radiusM),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: textTheme.bodyLarge?.copyWith(
                      fontSize: isApple ? 15 : null,
                      fontWeight: isApple && selected ? FontWeight.w600 : null,
                      color: selected
                          ? (isApple
                                ? colorScheme.primary
                                : colorScheme.onSecondaryContainer)
                          : colorScheme.onSurface,
                    ),
                  ),
                ),
                if (selected)
                  Icon(
                    AppIcons.check(context),
                    size: isApple ? 18 : 24,
                    color: isApple
                        ? colorScheme.primary
                        : colorScheme.onSecondaryContainer,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
