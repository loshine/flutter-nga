import 'dart:async';

import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_nga/providers/settings/design_style_provider.dart';
import 'package:flutter_nga/ui/widget/adaptive/adaptive_controls.dart';
import 'package:flutter_nga/ui/widget/m3_dialog.dart';
import 'package:flutter_nga/utils/dimen.dart';

class ImportCookiesDialog extends HookWidget {
  final FutureOr<void> Function(String cookies) cookiesCallback;

  const ImportCookiesDialog({super.key, required this.cookiesCallback});

  @override
  Widget build(BuildContext context) {
    final controller = useTextEditingController();
    final errorText = useState<String?>(null);
    final submitting = useState(false);
    final colorScheme = Theme.of(context).colorScheme;
    final isApple = context.isAppleStyle;

    Future<void> submit() async {
      if (submitting.value) return;
      final trimmed = controller.text.trim();
      if (trimmed.isEmpty) {
        errorText.value = '请输入 Cookies 内容';
        return;
      }
      errorText.value = null;
      submitting.value = true;
      try {
        await cookiesCallback(trimmed);
        if (context.mounted) {
          if (ModalRoute.of(context)?.isCurrent ?? false) {
            Navigator.of(context).pop(true);
          } else {
            submitting.value = false;
          }
        }
      } catch (err) {
        if (context.mounted) {
          errorText.value = '$err'.replaceFirst(
            RegExp(r'^(FormatException|Exception):\s*'),
            '',
          );
          submitting.value = false;
        }
      }
    }

    final borderRadius = BorderRadius.circular(isApple ? 10 : Dimen.radiusS);

    return PopScope(
      canPop: !submitting.value,
      child: M3Dialog(
        title: '导入 Cookies',
        scrollable: true,
        content: TextField(
          controller: controller,
          autofocus: true,
          enabled: !submitting.value,
          minLines: 3,
          maxLines: 6,
          keyboardType: TextInputType.multiline,
          onChanged: (_) {
            if (errorText.value != null) errorText.value = null;
          },
          decoration: InputDecoration(
            labelText: 'Cookies',
            hintText: '粘贴包含 ngaPassportUid、ngaPassportCid、ngaPassportUrlencodedUname 的 Cookies',
            errorText: errorText.value,
            errorMaxLines: 3,
            filled: true,
            fillColor: isApple
                ? colorScheme.surfaceContainerLow
                : colorScheme.surfaceContainerHighest,
            border: OutlineInputBorder(
              borderRadius: borderRadius,
              borderSide: isApple
                  ? BorderSide(color: colorScheme.outlineVariant, width: 0.5)
                  : BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: borderRadius,
              borderSide: isApple
                  ? BorderSide(color: colorScheme.outlineVariant, width: 0.5)
                  : BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: borderRadius,
              borderSide: BorderSide(
                color: colorScheme.primary,
                width: isApple ? 1.5 : 2,
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: submitting.value
                ? null
                : () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: submitting.value ? null : submit,
            child: submitting.value
                ? const AppActivityIndicator(radius: 8, strokeWidth: 2)
                : const Text('确定'),
          ),
        ],
      ),
    );
  }
}
