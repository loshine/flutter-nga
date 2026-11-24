import 'package:material_ui/material_ui.dart';
import 'package:flutter_nga/utils/dimen.dart';

/// Material You 分组设置卡片：组标题 + `surfaceContainerLow` 圆角容器 + 组内细分割线。
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              title!,
              style: textTheme.titleSmall?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          )
        else
          const SizedBox(height: Dimen.spacingM),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Material(
            color: colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(Dimen.radiusL),
            clipBehavior: Clip.antiAlias,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < children.length; i++) ...[
                  if (i > 0)
                    Divider(
                      height: 1,
                      indent: dividerIndent,
                      endIndent: 16,
                      color: colorScheme.outlineVariant.withValues(alpha: 0.6),
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
  });

  final IconData? icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final int badgeCount;
  final bool showChevron;
  final IconData? trailingIcon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            if (icon != null) ...[
              Badge.count(
                count: badgeCount,
                isLabelVisible: badgeCount > 0,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(Dimen.radiusFull),
                  ),
                  child: Icon(
                    icon,
                    color: colorScheme.onPrimaryContainer,
                    size: Dimen.iconSmall,
                  ),
                ),
              ),
              const SizedBox(width: Dimen.spacingL),
            ],
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
            if (trailing != null) ...[
              const SizedBox(width: Dimen.spacingS),
              trailing!,
            ],
            if (onTap != null && showChevron) ...[
              const SizedBox(width: Dimen.spacingXS),
              Icon(
                trailingIcon ?? Icons.chevron_right,
                color: colorScheme.onSurfaceVariant,
                size: trailingIcon != null ? 18 : 24,
              ),
            ],
          ],
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

    return InkWell(
      onTap: enabled ? () => onChanged!(!value) : null,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.45,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              if (icon != null) ...[
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(Dimen.radiusFull),
                  ),
                  child: Icon(
                    icon,
                    color: colorScheme.onPrimaryContainer,
                    size: Dimen.iconSmall,
                  ),
                ),
                const SizedBox(width: Dimen.spacingL),
              ],
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
              const SizedBox(width: Dimen.spacingS),
              Switch(value: value, onChanged: onChanged),
            ],
          ),
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(Dimen.radiusFull),
            ),
            child: Icon(
              icon,
              color: colorScheme.onSurfaceVariant,
              size: Dimen.iconSmall,
            ),
          ),
          const SizedBox(width: Dimen.spacingL),
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
        ],
      ),
    );
  }
}
