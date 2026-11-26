import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_nga/data/entity/user_agent_config.dart';
import 'package:flutter_nga/providers/settings/design_style_provider.dart';
import 'package:flutter_nga/providers/settings/user_agent_settings_provider.dart';
import 'package:flutter_nga/ui/widget/adaptive/app_icons.dart';
import 'package:flutter_nga/ui/widget/m3_dialog.dart';
import 'package:flutter_nga/utils/dimen.dart';

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
    final isApple = context.isAppleStyle;
    final options = UserAgentPresets.all
        .map(
          (config) =>
              config.key == UserAgentPresets.custom.key &&
                  state.currentConfig.key == UserAgentPresets.custom.key
              ? state.currentConfig
              : config,
        )
        .toList();

    final Widget optionList;
    if (isApple) {
      optionList = ListView.builder(
        shrinkWrap: true,
        itemCount: options.length,
        itemBuilder: (context, index) {
          final config = options[index];
          final selected = state.currentConfig == config;
          final subtitleText = config.isDeviceSpecific
              ? '根据当前设备自动选择'
              : (config.userAgent.isEmpty
                    ? '点击后输入自定义 User-Agent'
                    : config.userAgent);
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            child: Material(
              color: selected
                  ? colorScheme.primary.withValues(alpha: 0.12)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(Dimen.radiusM),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: state.isLoading
                    ? null
                    : () => _onSelectConfig(context, ref, state, config),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 11,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              config.name,
                              style: textTheme.bodyLarge?.copyWith(
                                fontSize: 15,
                                fontWeight: selected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                color: selected
                                    ? colorScheme.primary
                                    : colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              subtitleText,
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: config.isDeviceSpecific ? null : 11,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      if (selected)
                        Icon(
                          AppIcons.check(context),
                          size: 18,
                          color: colorScheme.primary,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    } else {
      optionList = RadioGroup<UserAgentConfig>(
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
    }

    if (embedded) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(0, 4, 0, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                '选择 User-Agent',
                textAlign: isApple ? TextAlign.center : TextAlign.start,
                style:
                    (isApple ? textTheme.titleMedium : textTheme.headlineSmall)
                        ?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: isApple ? FontWeight.w600 : null,
                        ),
              ),
            ),
            const SizedBox(height: 8),
            Flexible(child: optionList),
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
    }

    return AlertDialog(
      title: const Text('选择 User-Agent'),
      content: SizedBox(width: double.maxFinite, child: optionList),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('关闭'),
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
    } else if (config == state.currentConfig) {
      if (context.mounted) Navigator.of(context).pop();
      return;
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
    return showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return HookBuilder(
          builder: (context) {
            final controller = useTextEditingController(text: initialValue);
            final errorText = useState<String?>(null);

            void submit() {
              final trimmed = controller.text.trim();
              if (trimmed.isEmpty) {
                errorText.value = 'User-Agent 不能为空';
                return;
              }
              Navigator.of(dialogContext).pop(trimmed);
            }

            return M3Dialog(
              title: '自定义 User-Agent',
              content: TextField(
                controller: controller,
                autofocus: true,
                minLines: 1,
                maxLines: 3,
                textInputAction: TextInputAction.done,
                onChanged: (_) {
                  if (errorText.value != null) errorText.value = null;
                },
                onSubmitted: (_) => submit(),
                decoration: InputDecoration(
                  hintText: 'Mozilla/5.0 ...',
                  errorText: errorText.value,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('取消'),
                ),
                FilledButton(onPressed: submit, child: const Text('确定')),
              ],
            );
          },
        );
      },
    );
  }
}
