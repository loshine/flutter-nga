import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_nga/providers/forum/favourite_forum_list_provider.dart';
import 'package:flutter_nga/utils/dimen.dart';
import 'package:flutter_nga/utils/route.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class CustomForumDialog extends HookConsumerWidget {
  const CustomForumDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fidController = useTextEditingController();
    final nameController = useTextEditingController();
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimen.radiusXL),
      ),
      backgroundColor: colorScheme.surfaceContainerHigh,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题
            Text(
              "添加自定义版面",
              style: textTheme.headlineSmall?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 24),

            // FID 输入框
            TextField(
              controller: fidController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "版面 ID (fid)",
                hintText: "输入版面 ID",
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(Dimen.radiusS),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(Dimen.radiusS),
                  borderSide: BorderSide(
                    color: colorScheme.primary,
                    width: 2,
                  ),
                ),
                prefixIcon: Icon(
                  Icons.tag,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 名称输入框
            TextField(
              controller: nameController,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                labelText: "版面名称",
                hintText: "输入版面显示名称",
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(Dimen.radiusS),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(Dimen.radiusS),
                  borderSide: BorderSide(
                    color: colorScheme.primary,
                    width: 2,
                  ),
                ),
                prefixIcon: Icon(
                  Icons.forum_outlined,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 操作按钮
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Routes.pop(context),
                  child: const Text("取消"),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () => _addForum(
                    context,
                    ref,
                    fidController.text,
                    nameController.text,
                  ),
                  child: const Text("添加"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _addForum(
    BuildContext context,
    WidgetRef ref,
    String fidText,
    String name,
  ) {
    final fid = int.tryParse(fidText);
    if (fid == null) {
      Fluttertoast.showToast(msg: "请输入有效的版面 ID");
      return;
    }
    if (name.isEmpty) {
      Fluttertoast.showToast(msg: "请输入版面名称");
      return;
    }

    ref.read(favouriteForumListProvider.notifier).add(fid, name).then((_) {
      Fluttertoast.showToast(msg: "添加成功");
      Routes.pop(context);
    }).catchError((e) {
      debugPrint(e.toString());
      Fluttertoast.showToast(msg: "添加自定义板块失败");
    });
  }
}
