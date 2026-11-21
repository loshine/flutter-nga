import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_nga/ui/widget/m3_dialog.dart';

typedef EditCallback = void Function(String text);

/// 输入 UID 或用户名的对话框，用于添加收信人、邀请用户、屏蔽用户。
class ContactEditDialog extends HookWidget {
  final EditCallback? callback;
  final String title;

  const ContactEditDialog({super.key, this.callback, this.title = '添加收信人'});

  @override
  Widget build(BuildContext context) {
    final controller = useTextEditingController();

    void submit() {
      callback?.call(controller.text);
      Navigator.of(context).pop();
    }

    return M3Dialog(
      title: title,
      content: TextField(
        autofocus: true,
        maxLines: 1,
        controller: controller,
        decoration: const InputDecoration(
          labelText: 'UID 或用户名',
          helperText: '多个用空格或逗号分隔，纯数字用户名前加 \\',
        ),
        keyboardType: TextInputType.text,
        onSubmitted: (_) => submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        FilledButton(onPressed: submit, child: const Text('确定')),
      ],
    );
  }
}
