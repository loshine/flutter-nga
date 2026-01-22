import 'package:flutter/material.dart';
import 'package:flutter_nga/ui/widget/font_style_widget.dart';
import 'package:flutter_nga/utils/constant.dart';
import 'package:flutter_nga/utils/dimen.dart';
import 'package:flutter_nga/utils/route.dart';

class FontColorDialog extends StatelessWidget {
  const FontColorDialog({this.callback, Key? key}) : super(key: key);
  final InputCallback? callback;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final keyList = TEXT_COLOR_MAP.keys.toList();
    final valueList = TEXT_COLOR_MAP.values.toList();

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
                "颜色",
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
                itemCount: TEXT_COLOR_MAP.length,
                itemBuilder: (context, index) {
                  return _ColorOption(
                    label: keyList[index],
                    color: valueList[index],
                    onTap: () {
                      callback?.call(
                          "[color=${keyList[index]}]", "[/color]", true);
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
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: colorScheme.outlineVariant,
                  width: 1,
                ),
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