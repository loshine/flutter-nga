import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:flutter_nga/providers/settings/design_style_provider.dart';
import 'package:flutter_nga/ui/widget/adaptive/app_icons.dart';
import 'package:flutter_nga/ui/widget/m3_dialog.dart';
import 'package:flutter_nga/utils/dimen.dart';

/// 界面设计风格选择面板（跟随平台 / Material You / Apple 风格）。
class DesignStyleSelectionDialog extends ConsumerWidget {
  const DesignStyleSelectionDialog({super.key, this.embedded = false});

  final bool embedded;

  static Future<void> show(BuildContext context) {
    return showM3SelectionSheet<void>(
      context: context,
      builder: (_) => const DesignStyleSelectionDialog(embedded: true),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(designStyleProvider);
    final notifier = ref.read(designStyleProvider.notifier);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final platform = theme.platform;
    final defaultStyleName =
        platform == TargetPlatform.iOS || platform == TargetPlatform.macOS
        ? 'Apple 风格'
        : 'Material You';

    final body = SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.fromLTRB(0, embedded ? 4 : 24, 0, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                '界面风格',
                style: textTheme.headlineSmall?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(height: 12),
            _StyleOptionTile(
              title: DesignStylePreference.auto.label,
              subtitle: '当前平台默认使用 $defaultStyleName',
              icon: AppIcons.devices(context),
              selected: state.preference == DesignStylePreference.auto,
              onTap: () => notifier.setPreference(DesignStylePreference.auto),
            ),
            _StyleOptionTile(
              title: DesignStylePreference.material.label,
              subtitle: DesignStylePreference.material.subtitle,
              icon: Icons.android_outlined,
              selected: state.preference == DesignStylePreference.material,
              onTap: () =>
                  notifier.setPreference(DesignStylePreference.material),
            ),
            _StyleOptionTile(
              title: DesignStylePreference.apple.label,
              subtitle: state.nativeLiquidGlassSupported
                  ? 'Apple HIG 规范 · 已启用原生 Liquid Glass'
                  : 'Apple HIG 规范 · 毛玻璃视觉模拟',
              icon: AppIcons.style(context),
              selected: state.preference == DesignStylePreference.apple,
              onTap: () => notifier.setPreference(DesignStylePreference.apple),
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
      ),
    );

    if (embedded) return body;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimen.radiusXL),
      ),
      backgroundColor: colorScheme.surfaceContainerHigh,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: body,
      ),
    );
  }
}

class _StyleOptionTile extends StatelessWidget {
  const _StyleOptionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

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
        borderRadius: BorderRadius.circular(
          isApple ? Dimen.radiusM : Dimen.radiusM,
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: selected
                      ? (isApple
                            ? colorScheme.primary
                            : colorScheme.onSecondaryContainer)
                      : colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: textTheme.bodyLarge?.copyWith(
                          color: selected
                              ? (isApple
                                    ? colorScheme.primary
                                    : colorScheme.onSecondaryContainer)
                              : colorScheme.onSurface,
                          fontWeight: selected ? FontWeight.w600 : null,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: textTheme.bodySmall?.copyWith(
                          color: selected
                              ? (isApple
                                    ? colorScheme.primary.withValues(alpha: 0.8)
                                    : colorScheme.onSecondaryContainer
                                          .withValues(alpha: 0.8))
                              : colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (selected)
                  Icon(
                    AppIcons.check(context),
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
