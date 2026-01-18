import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_nga/providers/forum/favourite_forum_list_provider.dart';
import 'package:flutter_nga/utils/route.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class CustomForumDialog extends HookConsumerWidget {
  const CustomForumDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fidController = useTextEditingController();
    final nameController = useTextEditingController();

    return AlertDialog(
      title: Text("添加自定义版面"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            maxLines: 1,
            controller: fidController,
            decoration: InputDecoration(labelText: "fid"),
            keyboardType: TextInputType.number,
          ),
          TextField(
            maxLines: 1,
            controller: nameController,
            decoration: InputDecoration(labelText: "名称"),
            keyboardType: TextInputType.text,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            if (fidController.text.isEmpty) {
               Fluttertoast.showToast(msg: "fid不能为空");
               return;
            }
            final fid = int.tryParse(fidController.text);
             if (fid == null) {
               Fluttertoast.showToast(msg: "fid必须为数字");
               return;
            }
            ref.read(favouriteForumListProvider.notifier)
                .add(fid, nameController.text)
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