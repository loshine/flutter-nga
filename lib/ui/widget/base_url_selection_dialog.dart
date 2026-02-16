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
    final options = BaseUrlPresets.all
        .map((config) => config.key == BaseUrlPresets.custom.key &&
                state.currentConfig.key == BaseUrlPresets.custom.key
            ? state.currentConfig
            : config)
        .toList();

    return AlertDialog(
      title: const Text('选择服务器'),
      content: SizedBox(
        width: double.maxFinite,
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
    final controller = TextEditingController(text: initialValue);
    final value = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('自定义服务器地址'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'https://example.com/',
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
    final normalized = _normalizeBaseUrl(value ?? '');
    if (normalized == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('请输入有效的 http/https 地址')),
        );
      }
      return null;
    }
    return normalized;
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
