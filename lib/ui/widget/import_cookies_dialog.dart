import 'package:flutter/material.dart';
import 'package:flutter_nga/utils/route.dart';

class ImportCookiesDialog extends StatelessWidget {
  final Function(String) cookiesCallback;
  final _controller = TextEditingController();

  ImportCookiesDialog({Key? key, required this.cookiesCallback})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("导入 Cookies"),
      content: TextField(
        maxLines: 1,
        controller: _controller,
        decoration: InputDecoration(labelText: "cookies"),
        keyboardType: TextInputType.text,
      ),
      actions: [
        TextButton(
          onPressed: () => Routes.pop(context),
          child: Text("取消"),
        ),
        TextButton(
          onPressed: () {
            if (_controller.text.isNotEmpty) {
              cookiesCallback(_controller.text);
            }
            Routes.pop(context);
          },
          child: Text("确定"),
        )
      ],
    );
  }
}
