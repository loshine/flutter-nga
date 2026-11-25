import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_nga/providers/settings/interface_settings_provider.dart';
import 'package:flutter_nga/ui/widget/line_height_selection_dialog.dart';
import 'package:flutter_nga/ui/widget/m3_settings_group.dart';
import 'package:flutter_nga/ui/widget/readable_width.dart';
import 'package:flutter_nga/utils/dimen.dart';

class InterfaceSettingsPage extends ConsumerWidget {
  const InterfaceSettingsPage({super.key, this.embedded = false});

  /// 是否作为大屏双栏设置页的右侧内嵌面板展示
  final bool embedded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(interfaceSettingsProvider);
    final notifier = ref.read(interfaceSettingsProvider.notifier);
    final mediaPadding = MediaQuery.paddingOf(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: !embedded,
        centerTitle: embedded ? false : null,
        title: const Text("界面设置"),
      ),
      body: ReadableListPadding(
        padding: EdgeInsets.fromLTRB(
          mediaPadding.left,
          8,
          mediaPadding.right,
          16 + mediaPadding.bottom,
        ),
        builder: (context, padding) => ListView(
          padding: padding,
          children: [
            _TypographyPreviewCard(state: state),
            M3SettingsGroup(
              title: "字号与行距",
              dividerIndent: 16,
              children: [
                _SliderSettingItem(
                  title: "贴子列表标题缩放",
                  subtitle: "控制贴子列表标题字体大小",
                  valueLabel: "${state.titleSizeMultiple.toStringAsFixed(1)}x",
                  value: state.titleSizeMultiple,
                  min: 1.0,
                  max: 2.0,
                  divisions: 10,
                  onChanged: notifier.setTitleSizeMultiple,
                ),
                _SliderSettingItem(
                  title: "贴子正文字体缩放",
                  subtitle: "控制贴子正文内容字体大小",
                  valueLabel:
                      "${state.contentSizeMultiple.toStringAsFixed(1)}x",
                  value: state.contentSizeMultiple,
                  min: 1.0,
                  max: 2.0,
                  divisions: 10,
                  onChanged: notifier.setContentSizeMultiple,
                ),
                M3SettingsTile(
                  icon: Icons.format_line_spacing,
                  title: "贴子正文行间距",
                  subtitle: "控制贴子正文及列表标题的行间距",
                  trailing: Text(
                    state.lineHeight.nameWithSize,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onTap: () => _showLineHeightSelectionDialog(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showLineHeightSelectionDialog(BuildContext context) {
    LineHeightSelectionDialog.show(context);
  }
}

/// 实时排版预览卡片：随滑块与行间距变化即时展示效果
class _TypographyPreviewCard extends StatelessWidget {
  const _TypographyPreviewCard({required this.state});

  final InterfaceSettingsState state;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Material(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(Dimen.radiusL),
        child: Padding(
          padding: const EdgeInsets.all(Dimen.spacingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.visibility_outlined,
                    size: 16,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: Dimen.spacingXS),
                  Text(
                    '实时预览',
                    style: textTheme.labelMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Dimen.spacingM),
              Text(
                '[讨论] 艾泽拉斯国家地理排版效果预览标题',
                style: textTheme.titleMedium?.copyWith(
                  fontSize: Dimen.titleMedium * state.titleSizeMultiple,
                  height: state.lineHeight.size,
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: Dimen.spacingS),
              Text(
                '拖动下方滑块或切换行间距，可以实时观察帖子列表标题与楼层正文的字号、行高变化效果。',
                style: textTheme.bodyMedium?.copyWith(
                  fontSize: Dimen.bodyMedium * state.contentSizeMultiple,
                  height: state.lineHeight.size,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SliderSettingItem extends StatelessWidget {
  const _SliderSettingItem({
    required this.title,
    required this.subtitle,
    required this.valueLabel,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final String valueLabel;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                valueLabel,
                style: textTheme.labelLarge?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: Dimen.spacingXS),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            label: valueLabel,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
