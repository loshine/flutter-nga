import 'package:flutter/material.dart';
import 'package:flutter_nga/data/entity/base_url_config.dart';
import 'package:flutter_nga/providers/settings/base_url_settings_provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// BaseUrl 选择对话框
class BaseUrlSelectionDialog extends ConsumerWidget {
  const BaseUrlSelectionDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(baseUrlSettingsProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AlertDialog(
      title: const Text('选择服务器'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: BaseUrlPresets.all.length,
          itemBuilder: (context, index) {
            final config = BaseUrlPresets.all[index];

            return RadioListTile<BaseUrlConfig>(
              title: Text(
                config.name,
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
              subtitle: Text(
                config.url,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              value: config,
              groupValue: state.currentConfig,
              onChanged: state.isLoading
                  ? null
                  : (value) async {
                      if (value != null) {
                        await ref
                            .read(baseUrlSettingsProvider.notifier)
                            .setBaseUrlConfig(value);
                        if (context.mounted) {
                          Navigator.of(context).pop();
                        }
                      }
                    },
              activeColor: colorScheme.primary,
              contentPadding: EdgeInsets.zero,
              dense: true,
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
      ],
    );
  }
}
