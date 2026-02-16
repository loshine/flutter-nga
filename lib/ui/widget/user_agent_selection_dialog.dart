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
    final options = UserAgentPresets.all
        .map((config) => config.key == UserAgentPresets.custom.key &&
                state.currentConfig.key == UserAgentPresets.custom.key
            ? state.currentConfig
            : config)
        .toList();

    return AlertDialog(
      title: const Text('选择 User-Agent'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: options.length,
          itemBuilder: (context, index) {
            final config = options[index];

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
                      config.userAgent.isEmpty
                          ? '点击后输入自定义 User-Agent'
                          : config.userAgent,
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
                        await _onSelectConfig(context, ref, state, value);
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

  Future<void> _onSelectConfig(
    BuildContext context,
    WidgetRef ref,
    UserAgentSettingsState state,
    UserAgentConfig config,
  ) async {
    var selected = config;
    if (config.key == UserAgentPresets.custom.key) {
      final customUserAgent = await _showCustomUserAgentInput(
        context,
        initialValue: state.currentConfig.key == UserAgentPresets.custom.key
            ? state.currentConfig.userAgent
            : '',
      );
      if (customUserAgent == null) return;
      selected = UserAgentPresets.custom.copyWith(userAgent: customUserAgent);
    }
    await ref
        .read(userAgentSettingsProvider.notifier)
        .setUserAgentConfig(selected);
    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<String?> _showCustomUserAgentInput(
    BuildContext context, {
    required String initialValue,
  }) async {
    final controller = TextEditingController(text: initialValue);
    final value = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('自定义 User-Agent'),
          content: TextField(
            controller: controller,
            autofocus: true,
            maxLines: 2,
            decoration: const InputDecoration(
              hintText: 'Mozilla/5.0 ...',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(controller.text),
              child: const Text('确定'),
            ),
          ],
        );
      },
    );
    controller.dispose();
    final trimmed = (value ?? '').trim();
    if (trimmed.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User-Agent 不能为空')),
        );
      }
      return null;
    }
    return trimmed;
  }
}
