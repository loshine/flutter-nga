import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_nga/providers/settings/theme_provider.dart';
import 'package:flutter_nga/ui/widget/m3_dialog.dart';
import 'package:flutter_nga/utils/dimen.dart';
import 'package:flutter_nga/utils/motion.dart';
import 'package:flutter_nga/utils/theme_builder.dart';

class ThemeSelectionDialog extends ConsumerWidget {
  const ThemeSelectionDialog({super.key, this.embedded = false});

  /// 为 true 时直接渲染内容面板，供 [showM3SelectionSheet] 包裹。
  final bool embedded;

  /// 按屏幕尺寸以 Modal Bottom Sheet（窄屏）或居中 Dialog（宽屏）打开。
  static Future<void> show(BuildContext context) {
    return showM3SelectionSheet<void>(
      context: context,
      builder: (_) => const ThemeSelectionDialog(embedded: true),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(themeProvider);
    final notifier = ref.read(themeProvider.notifier);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final body = SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.fromLTRB(0, embedded ? 4 : 24, 0, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                "主题与配色",
                style: textTheme.headlineSmall?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 主题模式区域
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                "主题模式",
                style: textTheme.titleSmall?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 8),

            _ThemeOption(
              title: "跟随系统",
              subtitle: "根据系统设置自动切换",
              icon: Icons.brightness_auto,
              selected:
                  state.mode == AdaptiveThemeMode.system || state.mode == null,
              onTap: () => notifier.update(context, AdaptiveThemeMode.system),
            ),
            _ThemeOption(
              title: "亮色主题",
              subtitle: "始终使用亮色主题",
              icon: Icons.light_mode_outlined,
              selected: state.mode == AdaptiveThemeMode.light,
              onTap: () => notifier.update(context, AdaptiveThemeMode.light),
            ),
            _ThemeOption(
              title: "暗色主题",
              subtitle: "始终使用暗色主题",
              icon: Icons.dark_mode_outlined,
              selected: state.mode == AdaptiveThemeMode.dark,
              onTap: () => notifier.update(context, AdaptiveThemeMode.dark),
            ),

            // 颜色设置区域
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                "颜色方案",
                style: textTheme.titleSmall?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 4),

            if (state.isDynamicColorAvailable)
              SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                secondary: Icon(
                  Icons.wallpaper_outlined,
                  color: colorScheme.onSurfaceVariant,
                ),
                title: const Text('动态配色'),
                subtitle: const Text('跟随系统壁纸或系统强调色'),
                value: state.useDynamicColor,
                onChanged: (enabled) =>
                    notifier.setUseDynamicColor(context, enabled),
              ),

            _ColorPicker(
              selectedColor: state.seedColor,
              isDynamicActive: state.isDynamicColorActive,
              onColorSelected: (color) => notifier.setSeedColor(context, color),
            ),

            const SizedBox(height: 8),

            // 关闭按钮
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

/// 颜色选择器组件
class _ColorPicker extends StatelessWidget {
  final Color selectedColor;
  final bool isDynamicActive;
  final ValueChanged<Color> onColorSelected;

  const _ColorPicker({
    required this.selectedColor,
    required this.isDynamicActive,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (var i = 0; i < ThemeColors.presets.length; i++)
            _PaletteSwatch(
              seedColor: ThemeColors.presets[i],
              label: ThemeColors.names[i],
              brightness: brightness,
              isSelected:
                  !isDynamicActive &&
                  ThemeColors.presets[i].toARGB32() == selectedColor.toARGB32(),
              onTap: () => onColorSelected(ThemeColors.presets[i]),
            ),
        ],
      ),
    );
  }
}

/// Material You 三色调色盘色块：满足 48dp 最小触控热区、水波纹与读屏语义
class _PaletteSwatch extends StatelessWidget {
  final Color seedColor;
  final String label;
  final Brightness brightness;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaletteSwatch({
    required this.seedColor,
    required this.label,
    required this.brightness,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final previewScheme = brightness == Brightness.dark
        ? ThemeBuilder.buildDarkTheme(seedColor).colorScheme
        : ThemeBuilder.buildLightTheme(seedColor).colorScheme;
    final hostScheme = Theme.of(context).colorScheme;

    return Semantics(
      label: label,
      selected: isSelected,
      button: true,
      child: Tooltip(
        message: label,
        child: SizedBox(
          width: 48,
          height: 48,
          child: Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            child: InkResponse(
              onTap: onTap,
              customBorder: const CircleBorder(),
              radius: 24,
              child: Center(
                child: AnimatedContainer(
                  duration: Motion.resolveDuration(
                    context,
                    Motion.durationShort4,
                  ),
                  width: 40,
                  height: 40,
                  padding: EdgeInsets.all(isSelected ? 2 : 0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: isSelected
                        ? Border.all(color: hostScheme.primary, width: 2.5)
                        : Border.all(
                            color: hostScheme.outlineVariant,
                            width: 1,
                          ),
                  ),
                  child: ClipOval(
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Column(
                          children: [
                            Expanded(
                              child: ColoredBox(
                                color: previewScheme.primary,
                                child: const SizedBox.expand(),
                              ),
                            ),
                            Expanded(
                              child: Row(
                                children: [
                                  Expanded(
                                    child: ColoredBox(
                                      color: previewScheme.secondaryContainer,
                                      child: const SizedBox.expand(),
                                    ),
                                  ),
                                  Expanded(
                                    child: ColoredBox(
                                      color: previewScheme.tertiaryContainer,
                                      child: const SizedBox.expand(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (isSelected)
                          Center(
                            child: Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: previewScheme.primaryContainer,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.check,
                                size: 15,
                                color: previewScheme.onPrimaryContainer,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: selected ? colorScheme.secondaryContainer : Colors.transparent,
        borderRadius: BorderRadius.circular(Dimen.radiusM),
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
                      ? colorScheme.onSecondaryContainer
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
                              ? colorScheme.onSecondaryContainer
                              : colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: textTheme.bodySmall?.copyWith(
                          color: selected
                              ? colorScheme.onSecondaryContainer.withValues(
                                  alpha: 0.8,
                                )
                              : colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (selected)
                  Icon(Icons.check, color: colorScheme.onSecondaryContainer),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
