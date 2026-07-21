import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_nga/utils/route.dart';

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

    return AlertDialog(
      title: Text(title),
      content: TextField(
        maxLines: 1,
        controller: controller,
        decoration: InputDecoration(
          labelText: inputHint,
        ),
        keyboardType: TextInputType.text,
      ),
      actions: [
        TextButton(
          onPressed: () => Routes.pop(context),
          child: Text(
            '取消',
            style:
                TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
          ),
        ),
        TextButton(
          onPressed: () {
            callback?.call(controller.text);
            Routes.pop(context);
          },
          child: Text('确定'),
        )
      ],
    );
  }
}
