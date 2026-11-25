import 'dart:async';

import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_nga/ui/widget/adaptive/adaptive_controls.dart';
import 'package:flutter_nga/ui/widget/m3_dialog.dart';

typedef EditCallback = FutureOr<void> Function(String text);

class BlocklistEditDialog extends HookWidget {
  final EditCallback? callback;

  final String title;
  final String inputHint;

  const BlocklistEditDialog({
    super.key,
    this.callback,
    required this.title,
    required this.inputHint,
  });

  @override
  Widget build(BuildContext context) {
    final controller = useTextEditingController();
    final errorText = useState<String?>(null);
    final submitting = useState(false);

    Future<void> submit() async {
      if (submitting.value) return;
      final trimmed = controller.text.trim();
      if (trimmed.isEmpty) {
        errorText.value = '请输入内容';
        return;
      }
      errorText.value = null;
      submitting.value = true;
      try {
        await callback?.call(trimmed);
        if (context.mounted && (ModalRoute.of(context)?.isCurrent ?? false)) {
          Navigator.of(context).pop();
        }
      } catch (err) {
        if (context.mounted) {
          errorText.value = '$err'.replaceFirst(RegExp(r'^Exception:\s*'), '');
          submitting.value = false;
        }
      }
    }

    return PopScope(
      canPop: !submitting.value,
      child: M3Dialog(
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
            labelText: inputHint,
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
      ),
    );
  }
}
