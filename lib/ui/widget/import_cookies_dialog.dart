import 'package:flutter/material.dart';
import 'package:flutter_nga/utils/dimen.dart';
import 'package:flutter_nga/utils/route.dart';

class ImportCookiesDialog extends StatelessWidget {
  final Function(String) cookiesCallback;
  final _controller = TextEditingController();

  ImportCookiesDialog({Key? key, required this.cookiesCallback})
      : super(key: key);

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
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "导入 Cookies",
              style: textTheme.headlineSmall?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _controller,
              maxLines: null,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                labelText: "Cookies",
                hintText: "粘贴 Cookies 内容",
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(Dimen.radiusS),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(Dimen.radiusS),
                  borderSide: BorderSide(
                    color: colorScheme.primary,
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Routes.pop(context),
                  child: Text("取消"),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () {
                    if (_controller.text.isNotEmpty) {
                      cookiesCallback(_controller.text);
                    }
                    Routes.pop(context);
                  },
                  child: Text("确定"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}