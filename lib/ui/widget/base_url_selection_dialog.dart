import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_nga/data/entity/base_url_config.dart';
import 'package:flutter_nga/providers/settings/base_url_settings_provider.dart';
import 'package:flutter_nga/providers/settings/design_style_provider.dart';
import 'package:flutter_nga/ui/widget/adaptive/app_icons.dart';
import 'package:flutter_nga/ui/widget/m3_dialog.dart';
import 'package:flutter_nga/utils/dimen.dart';

/// BaseUrl 选择对话框 / 底部面板
class BaseUrlSelectionDialog extends ConsumerWidget {
  const BaseUrlSelectionDialog({super.key, this.embedded = false});

  final bool embedded;

  static Future<void> show(BuildContext context) {
    return showM3SelectionSheet<void>(
      context: context,
      builder: (_) => const BaseUrlSelectionDialog(embedded: true),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(baseUrlSettingsProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isApple = context.isAppleStyle;
    final options = BaseUrlPresets.all
        .map(
          (config) =>
              config.key == BaseUrlPresets.custom.key &&
                  state.currentConfig.key == BaseUrlPresets.custom.key
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
                              config.url.isEmpty ? '点击后输入自定义地址' : config.url,
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
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
      optionList = RadioGroup<BaseUrlConfig>(
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

            return RadioListTile<BaseUrlConfig>(
              title: Text(
                config.name,
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
              subtitle: Text(
                config.url.isEmpty ? '点击后输入自定义地址' : config.url,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
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
                '选择服务器',
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
      title: const Text('选择服务器'),
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
    BaseUrlSettingsState state,
    BaseUrlConfig config,
  ) async {
    var selected = config;
    if (config.key == BaseUrlPresets.custom.key) {
      final customUrl = await _showCustomBaseUrlInput(
        context,
        initialValue: state.currentConfig.key == BaseUrlPresets.custom.key
            ? state.currentConfig.url
            : '',
      );
      if (customUrl == null) return;
      selected = BaseUrlPresets.custom.copyWith(url: customUrl);
    } else if (config == state.currentConfig) {
      if (context.mounted) Navigator.of(context).pop();
      return;
    }
    await ref.read(baseUrlSettingsProvider.notifier).setBaseUrlConfig(selected);
    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<String?> _showCustomBaseUrlInput(
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
              final normalized = _normalizeBaseUrl(controller.text);
              if (normalized == null) {
                errorText.value = '请输入有效的 http/https 地址';
                return;
              }
              Navigator.of(dialogContext).pop(normalized);
            }

            return M3Dialog(
              title: '自定义服务器地址',
              content: TextField(
                controller: controller,
                autofocus: true,
                keyboardType: TextInputType.url,
                textInputAction: TextInputAction.done,
                onChanged: (_) {
                  if (errorText.value != null) errorText.value = null;
                },
                decoration: InputDecoration(
                  hintText: 'https://example.com/',
                  errorText: errorText.value,
                ),
                onSubmitted: (_) => submit(),
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

  String? _normalizeBaseUrl(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return null;
    final uri = Uri.tryParse(trimmed);
    if (uri == null ||
        !uri.hasScheme ||
        !(uri.scheme == 'http' || uri.scheme == 'https')) {
      return null;
    }
    return trimmed.endsWith('/') ? trimmed : '$trimmed/';
  }
}
