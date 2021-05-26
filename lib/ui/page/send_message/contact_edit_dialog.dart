import 'package:flutter/material.dart';
import 'package:flutter_nga/utils/route.dart';

typedef EditCallback = void Function(String text);

class ContactEditDialog extends StatelessWidget {
  final EditCallback? callback;

  final _controller = TextEditingController();

  ContactEditDialog({Key? key, this.callback}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("添加收信人"),
      content: TextField(
        maxLines: 1,
        controller: _controller,
        decoration: InputDecoration(
          labelText: "UID 或 用户名",
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
