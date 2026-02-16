import 'package:flutter/material.dart';
import 'package:flutter_nga/data/entity/user_agent_config.dart';
import 'package:flutter_nga/providers/settings/user_agent_settings_provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// UserAgent 选择对话框
class UserAgentSelectionDialog extends ConsumerWidget {
  const UserAgentSelectionDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(userAgentSettingsProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AlertDialog(
      title: const Text('选择 User-Agent'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: UserAgentPresets.all.length,
          itemBuilder: (context, index) {
            final config = UserAgentPresets.all[index];

            return RadioListTile<UserAgentConfig>(
              title: Text(
                config.name,
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
              subtitle: config.isDeviceSpecific
                  ? Text(
                      '根据当前设备自动选择',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    )
                  : Text(
                      config.userAgent,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 11,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
              value: config,
              groupValue: state.currentConfig,
              onChanged: state.isLoading
                  ? null
                  : (value) async {
                      if (value != null) {
                        await ref
                            .read(userAgentSettingsProvider.notifier)
                            .setUserAgentConfig(value);
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
