import 'package:flutter/material.dart';
import 'package:flutter_nga/ui/widget/font_style_widget.dart';
import 'package:flutter_nga/utils/dimen.dart';
import 'package:flutter_nga/utils/route.dart';

class FontSizeDialog extends StatelessWidget {
  const FontSizeDialog({this.callback, super.key});
  final InputCallback? callback;

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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimen.radiusXL),
      ),
      backgroundColor: colorScheme.surfaceContainerHigh,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 24, 0, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                "字号",
                style: textTheme.headlineSmall?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 400),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: sizeList.length,
                itemBuilder: (context, index) {
                  final (label, _) = sizeList[index];
                  return _SizeOption(
                    label: label,
                    onTap: () {
                      callback?.call("[size=$label]", "[/size]", true);
                      Routes.pop(context);
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Routes.pop(context),
                    child: const Text('取消'),
                  ),
                ],
              ),
            ),
          ],
        ),
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
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        child: Row(
          children: [
            Icon(
              Icons.format_size,
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
