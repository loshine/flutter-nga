import 'package:cupertino_ui/cupertino_ui.dart' show CupertinoIcons;
import 'package:material_ui/material_ui.dart';

import 'package:flutter_nga/providers/settings/design_style_provider.dart';
import 'package:flutter_nga/ui/widget/adaptive/adaptive_controls.dart';
import 'package:flutter_nga/utils/dimen.dart';

/// 分组设置卡片：
/// - Material You：组标题 + `surfaceContainerLow` 圆角容器 + 组内分割线；
/// - Apple 风格：Inset Grouped 分组列表（次要灰标题 + 12pt 圆角卡片 + 0.5px hairline 分割线）。
class M3SettingsGroup extends StatelessWidget {
  const M3SettingsGroup({
    super.key,
    this.title,
    required this.children,
    this.dividerIndent = 72,
  });

  final String? title;
  final List<Widget> children;
  final double dividerIndent;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isApple = context.isAppleStyle;
    final isHighContrast = MediaQuery.highContrastOf(context);
    final effectiveIndent = isApple
        ? (dividerIndent > 16 ? 58.0 : dividerIndent)
        : dividerIndent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          Padding(
            padding: isApple
                ? const EdgeInsets.fromLTRB(28, 18, 16, 6)
                : const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              title!,
              style: isApple
                  ? textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.2,
                    )
                  : textTheme.titleSmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
            ),
          )
        else
          SizedBox(height: isApple ? Dimen.spacingL : Dimen.spacingM),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: isApple ? 16 : 12),
          child: Material(
            color: colorScheme.surfaceContainerLow,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                isApple ? Dimen.radiusM : Dimen.radiusL,
              ),
              side: isApple
                  ? BorderSide(
                      color: colorScheme.outlineVariant,
                      width: isHighContrast ? 1 : 0.5,
                    )
                  : BorderSide.none,
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < children.length; i++) ...[
                  if (i > 0)
                    Divider(
                      height: isApple ? 0.5 : 1,
                      thickness: isApple ? 0.5 : 1,
                      indent: effectiveIndent,
                      endIndent: isApple ? 0 : 16,
                      color: colorScheme.outlineVariant.withValues(
                        alpha: isApple ? 0.7 : 0.6,
                      ),
                    ),
                  children[i],
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// 分组设置卡片内的可点击条目，支持可选图标容器、未读角标与自定义尾部组件。
class M3SettingsTile extends StatelessWidget {
  const M3SettingsTile({
    super.key,
    this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.badgeCount = 0,
    this.showChevron = true,
    this.trailingIcon,
    this.selected = false,
  });

  final IconData? icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final int badgeCount;
  final bool showChevron;
  final IconData? trailingIcon;

  /// 是否在大屏双栏设置页中处于当前选中状态
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isApple = context.isAppleStyle;

    return Material(
      color: selected
          ? (isApple
                ? colorScheme.primary.withValues(alpha: 0.14)
                : colorScheme.secondaryContainer.withValues(alpha: 0.6))
          : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: isApple ? 10 : 12,
          ),
          child: Row(
            children: [
              if (icon != null) ...[
                Badge.count(
                  count: badgeCount,
                  isLabelVisible: badgeCount > 0,
                  child: Container(
                    width: isApple ? 30 : 40,
                    height: isApple ? 30 : 40,
                    decoration: BoxDecoration(
                      color: isApple
                          ? (selected
                                ? colorScheme.primary
                                : colorScheme.primary.withValues(alpha: 0.14))
                          : (selected
                                ? colorScheme.primary
                                : colorScheme.primaryContainer),
                      borderRadius: BorderRadius.circular(
                        isApple ? 7 : Dimen.radiusFull,
                      ),
                    ),
                    child: Icon(
                      icon,
                      color: isApple
                          ? (selected
                                ? colorScheme.onPrimary
                                : colorScheme.primary)
                          : (selected
                                ? colorScheme.onPrimary
                                : colorScheme.onPrimaryContainer),
                      size: isApple ? 17 : Dimen.iconSmall,
                    ),
                  ),
                ),
                SizedBox(width: isApple ? 12 : Dimen.spacingL),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: textTheme.bodyLarge?.copyWith(
                        fontSize: isApple ? 15 : null,
                        color: selected
                            ? (isApple
                                  ? colorScheme.primary
                                  : colorScheme.onSecondaryContainer)
                            : colorScheme.onSurface,
                        fontWeight: selected ? FontWeight.w600 : null,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
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
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: Dimen.spacingS),
                trailing!,
              ],
              if (onTap != null && showChevron) ...[
                const SizedBox(width: Dimen.spacingXS),
                Icon(
                  trailingIcon ??
                      (isApple
                          ? CupertinoIcons.chevron_forward
                          : Icons.chevron_right),
                  color: selected
                      ? (isApple
                            ? colorScheme.primary
                            : colorScheme.onSecondaryContainer)
                      : colorScheme.onSurfaceVariant.withValues(
                          alpha: isApple ? 0.65 : 1.0,
                        ),
                  size: trailingIcon != null ? 18 : (isApple ? 16 : 24),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// 分组设置卡片内的开关条目。
class M3SettingsSwitchTile extends StatelessWidget {
  const M3SettingsSwitchTile({
    super.key,
    this.icon,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData? icon;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final enabled = onChanged != null;
    final isApple = context.isAppleStyle;

    return InkWell(
      onTap: enabled ? () => onChanged!(!value) : null,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: isApple ? 8 : 10,
        ),
        child: Row(
          children: [
            Expanded(
              child: Opacity(
                opacity: enabled ? 1.0 : 0.45,
                child: Row(
                  children: [
                    if (icon != null) ...[
                      Container(
                        width: isApple ? 30 : 40,
                        height: isApple ? 30 : 40,
                        decoration: BoxDecoration(
                          color: isApple
                              ? colorScheme.primary.withValues(alpha: 0.14)
                              : colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(
                            isApple ? 7 : Dimen.radiusFull,
                          ),
                        ),
                        child: Icon(
                          icon,
                          color: isApple
                              ? colorScheme.primary
                              : colorScheme.onPrimaryContainer,
                          size: isApple ? 17 : Dimen.iconSmall,
                        ),
                      ),
                      SizedBox(width: isApple ? 12 : Dimen.spacingL),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: textTheme.bodyLarge?.copyWith(
                              fontSize: isApple ? 15 : null,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          if (subtitle != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              subtitle!,
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: Dimen.spacingS),
            AppSwitch(value: value, onChanged: onChanged),
          ],
        ),
      ),
    );
  }
}

/// 分组设置卡片内的只读信息条目。
class M3SettingsInfoTile extends StatelessWidget {
  const M3SettingsInfoTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isApple = context.isAppleStyle;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: isApple ? 10 : 12,
      ),
      child: Row(
        children: [
          Container(
            width: isApple ? 30 : 40,
            height: isApple ? 30 : 40,
            decoration: BoxDecoration(
              color: isApple
                  ? colorScheme.onSurfaceVariant.withValues(alpha: 0.12)
                  : colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(
                isApple ? 7 : Dimen.radiusFull,
              ),
            ),
            child: Icon(
              icon,
              color: colorScheme.onSurfaceVariant,
              size: isApple ? 17 : Dimen.iconSmall,
            ),
          ),
          SizedBox(width: isApple ? 12 : Dimen.spacingL),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.bodyLarge?.copyWith(
                    fontSize: isApple ? 15 : null,
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
        ],
      ),
    );
  }
}
