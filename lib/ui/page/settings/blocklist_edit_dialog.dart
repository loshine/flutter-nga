import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_nga/ui/widget/m3_dialog.dart';

typedef EditCallback = void Function(String text);

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
        decoration: InputDecoration(labelText: inputHint),
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
