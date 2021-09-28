import 'package:flutter/material.dart';
import 'package:flutter_nga/utils/route.dart';

typedef EditCallback = void Function(String text);

class BlocklistEditDialog extends StatelessWidget {
  final EditCallback? callback;

  final String title;
  final String inputHint;

  final _controller = TextEditingController();

  BlocklistEditDialog(
      {Key? key, this.callback, required this.title, required this.inputHint})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: TextField(
        maxLines: 1,
        controller: _controller,
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
                TextStyle(color: Theme.of(context).textTheme.bodyText2?.color),
          ),
        ),
        TextButton(
          onPressed: () {
            callback?.call(_controller.text);
            Routes.pop(context);
          },
          child: Text('确定'),
        )
      ],
    );
  }
}
