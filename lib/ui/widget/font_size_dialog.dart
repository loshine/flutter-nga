import 'package:material_ui/material_ui.dart';
import 'package:flutter_nga/providers/settings/design_style_provider.dart';
import 'package:flutter_nga/ui/widget/adaptive/app_icons.dart';
import 'package:flutter_nga/ui/widget/font_style_widget.dart';
import 'package:flutter_nga/ui/widget/m3_dialog.dart';
import 'package:flutter_nga/utils/dimen.dart';

class FontSizeDialog extends StatelessWidget {
  const FontSizeDialog({this.callback, this.embedded = false, super.key});
  final InputCallback? callback;
  final bool embedded;

  static const sizeList = [
    ("110%", 1.1),
    ("120%", 1.2),
    ("130%", 1.3),
    ("150%", 1.5),
    ("200%", 2.0),
    ("300%", 3.0),
    ("400%", 4.0),
    ("500%", 5.0),
  ];

  static Future<void> show(BuildContext context, {InputCallback? callback}) {
    return showM3SelectionSheet<void>(
      context: context,
      builder: (_) => FontSizeDialog(callback: callback, embedded: true),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isApple = context.isAppleStyle;

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(24, embedded ? 4 : 24, 24, 8),
          child: Text(
            '字号',
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
              itemCount: sizeList.length,
              itemBuilder: (context, index) {
                final (label, _) = sizeList[index];
                return _SizeOption(
                  label: label,
                  onTap: () {
                    callback?.call('[size=$label]', '[/size]', true);
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

class _SizeOption extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _SizeOption({required this.label, required this.onTap});

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
            Icon(
              AppIcons.textFields(context),
              color: colorScheme.onSurfaceVariant,
              size: 20,
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
