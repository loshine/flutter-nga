import 'package:cupertino_ui/cupertino_ui.dart'
    show
        CupertinoActivityIndicator,
        CupertinoSlider,
        CupertinoSlidingSegmentedControl,
        CupertinoSwitch;
import 'package:material_ui/material_ui.dart';

import 'package:flutter_nga/providers/settings/design_style_provider.dart';

/// 平台自适应开关：Apple 风格下渲染 [CupertinoSwitch]，其余使用 M3 [Switch]。
class AppSwitch extends StatelessWidget {
  const AppSwitch({super.key, required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    if (context.isAppleStyle) {
      return CupertinoSwitch(
        value: value,
        activeTrackColor: Theme.of(context).colorScheme.primary,
        onChanged: onChanged,
      );
    }
    return Switch(value: value, onChanged: onChanged);
  }
}

/// 平台自适应滑块：Apple 风格下渲染 [CupertinoSlider]，其余使用 M3 [Slider]。
class AppSlider extends StatelessWidget {
  const AppSlider({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    this.divisions,
    this.label,
    required this.onChanged,
  });

  final double value;
  final double min;
  final double max;
  final int? divisions;
  final String? label;
  final ValueChanged<double>? onChanged;

  @override
  Widget build(BuildContext context) {
    if (context.isAppleStyle) {
      return SizedBox(
        width: double.infinity,
        child: CupertinoSlider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          activeColor: Theme.of(context).colorScheme.primary,
          onChanged: onChanged,
        ),
      );
    }
    return Slider(
      value: value,
      min: min,
      max: max,
      divisions: divisions,
      label: label,
      onChanged: onChanged,
    );
  }
}

/// 分段选择项描述。
class AppSegment<T> {
  const AppSegment({required this.value, required this.label, this.icon});

  final T value;
  final String label;
  final IconData? icon;
}

/// 平台自适应分段控制器：Apple 风格下使用 [CupertinoSlidingSegmentedControl]，
/// 其余使用 M3 [SegmentedButton]。
class AppSegmentedControl<T extends Object> extends StatelessWidget {
  const AppSegmentedControl({
    super.key,
    required this.segments,
    required this.selected,
    required this.onChanged,
    this.expand = true,
  });

  final List<AppSegment<T>> segments;
  final T selected;
  final ValueChanged<T> onChanged;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    if (context.isAppleStyle) {
      final colorScheme = Theme.of(context).colorScheme;
      final isDark = Theme.of(context).brightness == Brightness.dark;
      final control = CupertinoSlidingSegmentedControl<T>(
        groupValue: selected,
        backgroundColor: isDark
            ? const Color(0xFF2C2C2E)
            : const Color(0xFFE5E5EA),
        thumbColor: isDark ? const Color(0xFF48484A) : Colors.white,
        onValueChanged: (value) {
          if (value != null) onChanged(value);
        },
        children: {
          for (final segment in segments)
            segment.value: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (segment.icon != null) ...[
                    Icon(segment.icon, size: 16, color: colorScheme.onSurface),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    segment.label,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: segment.value == selected
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
        },
      );
      return expand
          ? SizedBox(width: double.infinity, child: control)
          : control;
    }

    final button = SegmentedButton<T>(
      segments: [
        for (final segment in segments)
          ButtonSegment<T>(
            value: segment.value,
            label: Text(segment.label),
            icon: segment.icon != null ? Icon(segment.icon) : null,
          ),
      ],
      selected: {selected},
      onSelectionChanged: (values) => onChanged(values.first),
    );
    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}

/// 平台自适应加载指示器。
class AppActivityIndicator extends StatelessWidget {
  const AppActivityIndicator({super.key, this.radius = 12, this.strokeWidth});

  final double radius;
  final double? strokeWidth;

  @override
  Widget build(BuildContext context) {
    if (context.isAppleStyle) {
      return CupertinoActivityIndicator(radius: radius);
    }
    return CircularProgressIndicator(strokeWidth: strokeWidth ?? 4.0);
  }
}
