import 'package:material_ui/material_ui.dart';
import 'package:flutter_nga/providers/settings/design_style_provider.dart';
import 'package:flutter_nga/ui/widget/font_style_widget.dart';
import 'package:flutter_nga/ui/widget/m3_dialog.dart';
import 'package:flutter_nga/utils/constant.dart';
import 'package:flutter_nga/utils/dimen.dart';

class FontColorDialog extends StatelessWidget {
  const FontColorDialog({this.callback, this.embedded = false, super.key});
  final InputCallback? callback;
  final bool embedded;

  static Future<void> show(BuildContext context, {InputCallback? callback}) {
    return showM3SelectionSheet<void>(
      context: context,
      builder: (_) => FontColorDialog(callback: callback, embedded: true),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isApple = context.isAppleStyle;
    final keyList = TEXT_COLOR_MAP.keys.toList();
    final valueList = TEXT_COLOR_MAP.values.toList();

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(24, embedded ? 4 : 24, 24, 8),
          child: Text(
            '颜色',
            textAlign: isApple ? TextAlign.center : TextAlign.start,
            style: (isApple ? textTheme.titleMedium : textTheme.headlineSmall)
                ?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: isApple ? FontWeight.w600 : null,
                ),
          ),
        ),
        Flexible(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 360),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: TEXT_COLOR_MAP.length,
              itemBuilder: (context, index) {
                return _ColorOption(
                  label: keyList[index],
                  color: valueList[index],
                  onTap: () {
                    callback?.call(
                      '[color=${keyList[index]}]',
                      '[/color]',
                      true,
                    );
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
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
    );

    if (embedded) return content;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimen.radiusXL),
      ),
      backgroundColor: colorScheme.surfaceContainerHigh,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: content,
      ),
    );
  }
}

class _ColorOption extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ColorOption({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(color: colorScheme.outlineVariant, width: 1),
              ),
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
