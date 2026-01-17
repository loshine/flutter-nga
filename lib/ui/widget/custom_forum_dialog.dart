import 'package:flutter/material.dart';
import 'package:flutter_nga/providers/forum/favourite_forum_list_provider.dart';
import 'package:flutter_nga/utils/route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CustomForumDialog extends ConsumerWidget {
  final _fidController = TextEditingController();
  final _nameController = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: Text("添加自定义版面"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            maxLines: 1,
            controller: _fidController,
            decoration: InputDecoration(labelText: "fid"),
            keyboardType: TextInputType.number,
          ),
          TextField(
            maxLines: 1,
            controller: _nameController,
            decoration: InputDecoration(labelText: "名称"),
            keyboardType: TextInputType.text,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            final fid = int.tryParse(_fidController.text)!;
            ref.read(favouriteForumListProvider.notifier)
                .add(fid, _nameController.text)
                .catchError((e) {
              debugPrint(e.toString());
              Fluttertoast.showToast(msg: "添加自定义板块失败");
            }).whenComplete(() => Routes.pop(context));
          },
          child: Text("确定"),
        )
      ],
    );
  }
}
