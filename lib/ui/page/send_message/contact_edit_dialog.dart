import 'dart:async';

import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_nga/ui/widget/adaptive/adaptive_controls.dart';
import 'package:flutter_nga/ui/widget/m3_dialog.dart';

typedef EditCallback = FutureOr<void> Function(String text);

/// 输入 UID 或用户名的对话框，用于添加收信人、邀请用户、屏蔽用户。
class ContactEditDialog extends HookWidget {
  final EditCallback? callback;
  final String title;

  const ContactEditDialog({super.key, this.callback, this.title = '添加收信人'});

  @override
  Widget build(BuildContext context) {
    final controller = useTextEditingController();
    final errorText = useState<String?>(null);
    final submitting = useState(false);

    Future<void> submit() async {
      if (submitting.value) return;
      final trimmed = controller.text.trim();
      if (trimmed.isEmpty) {
        errorText.value = '请输入 UID 或用户名';
        return;
      }
      errorText.value = null;
      submitting.value = true;
      try {
        await callback?.call(trimmed);
        if (context.mounted) {
          Navigator.of(context).pop();
        }
      } catch (err) {
        if (context.mounted) {
          errorText.value = '$err'.replaceFirst(RegExp(r'^Exception:\s*'), '');
          submitting.value = false;
        }
      }
    }

    return M3Dialog(
      title: title,
      content: TextField(
        autofocus: true,
        enabled: !submitting.value,
        maxLines: 1,
        controller: controller,
        onChanged: (_) {
          if (errorText.value != null) errorText.value = null;
        },
        decoration: InputDecoration(
          labelText: 'UID 或用户名',
          helperText: '多个用空格或逗号分隔，纯数字用户名前加 \\',
          errorText: errorText.value,
        ),
        keyboardType: TextInputType.text,
        onSubmitted: (_) => submit(),
      ),
      actions: [
        TextButton(
          onPressed: submitting.value
              ? null
              : () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: submitting.value ? null : submit,
          child: submitting.value
              ? const AppActivityIndicator(radius: 8, strokeWidth: 2)
              : const Text('确定'),
        ),
      ],
    );
  }
}
