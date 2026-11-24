import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_nga/data/entity/user_agent_config.dart';
import 'package:flutter_nga/providers/settings/user_agent_settings_provider.dart';
import 'package:flutter_nga/ui/widget/m3_dialog.dart';
import 'package:flutter_nga/utils/app_toast.dart';

/// UserAgent 选择对话框 / 底部面板
class UserAgentSelectionDialog extends ConsumerWidget {
  const UserAgentSelectionDialog({super.key, this.embedded = false});

  final bool embedded;

  static Future<void> show(BuildContext context) {
    return showM3SelectionSheet<void>(
      context: context,
      builder: (_) => const UserAgentSelectionDialog(embedded: true),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(userAgentSettingsProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final options = UserAgentPresets.all
        .map(
          (config) =>
              config.key == UserAgentPresets.custom.key &&
                  state.currentConfig.key == UserAgentPresets.custom.key
              ? state.currentConfig
              : config,
        )
        .toList();

    final radioList = RadioGroup<UserAgentConfig>(
      groupValue: state.currentConfig,
      onChanged: (value) {
        if (value == null || state.isLoading) return;
        _onSelectConfig(context, ref, state, value);
      },
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
            enabled: !state.isLoading,
            activeColor: colorScheme.primary,
            contentPadding: embedded
                ? const EdgeInsets.symmetric(horizontal: 16)
                : EdgeInsets.zero,
            dense: true,
          );
        },
      ),
    );

    if (embedded) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(0, 4, 0, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                '选择 User-Agent',
                style: textTheme.headlineSmall?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Flexible(child: radioList),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('取消'),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return AlertDialog(
      title: const Text('选择 User-Agent'),
      content: SizedBox(width: double.maxFinite, child: radioList),
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
    final value = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return HookBuilder(
          builder: (context) {
            final controller = useTextEditingController(text: initialValue);
            return M3Dialog(
              title: '自定义 User-Agent',
              content: TextField(
                controller: controller,
                autofocus: true,
                maxLines: 2,
                decoration: const InputDecoration(hintText: 'Mozilla/5.0 ...'),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('取消'),
                ),
                FilledButton(
                  onPressed: () =>
                      Navigator.of(dialogContext).pop(controller.text),
                  child: const Text('确定'),
                ),
              ],
            );
          },
        );
      },
    );
    if (value == null) return null;
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      AppToast.warning('User-Agent 不能为空');
      return null;
    }
    return trimmed;
  }
}
