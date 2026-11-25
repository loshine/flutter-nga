import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:flutter_nga/providers/forum/favourite_forum_list_provider.dart';
import 'package:flutter_nga/providers/settings/design_style_provider.dart';
import 'package:flutter_nga/ui/widget/adaptive/adaptive_controls.dart';
import 'package:flutter_nga/ui/widget/adaptive/app_icons.dart';
import 'package:flutter_nga/ui/widget/m3_dialog.dart';
import 'package:flutter_nga/utils/app_toast.dart';
import 'package:flutter_nga/utils/dimen.dart';

class CustomForumDialog extends HookConsumerWidget {
  const CustomForumDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fidController = useTextEditingController();
    final nameController = useTextEditingController();
    final nameFocusNode = useFocusNode();
    final submitting = useState(false);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isApple = context.isAppleStyle;

    InputDecoration buildDecoration({
      required String label,
      required String hint,
      required IconData icon,
    }) {
      if (isApple) {
        final radius = BorderRadius.circular(10);
        return InputDecoration(
          labelText: label,
          hintText: hint,
          isDense: true,
          filled: true,
          fillColor: colorScheme.surfaceContainerHighest.withValues(
            alpha: 0.65,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: radius,
            borderSide: BorderSide(
              color: colorScheme.outlineVariant,
              width: 0.5,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: radius,
            borderSide: BorderSide(
              color: colorScheme.outlineVariant,
              width: 0.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: radius,
            borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
          ),
          prefixIcon: Icon(icon, size: 17, color: colorScheme.onSurfaceVariant),
        );
      }

      return InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Dimen.radiusS),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Dimen.radiusS),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        prefixIcon: Icon(icon, color: colorScheme.onSurfaceVariant),
      );
    }

    Future<void> submit() async {
      if (submitting.value) return;
      final fid = int.tryParse(fidController.text.trim());
      if (fid == null) {
        AppToast.warning("请输入有效的版块 ID");
        return;
      }
      final name = nameController.text.trim();
      if (name.isEmpty) {
        AppToast.warning("请输入版块名称");
        return;
      }

      submitting.value = true;
      try {
        final added = await ref
            .read(favouriteForumListProvider.notifier)
            .add(fid, name);
        if (!added || !context.mounted) return;
        AppToast.success('添加成功');
        Navigator.of(context).pop();
      } catch (error) {
        debugPrint(error.toString());
        AppToast.error('添加自定义版块失败');
      } finally {
        if (context.mounted) submitting.value = false;
      }
    }

    return M3Dialog(
      title: "添加自定义版块",
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "输入 NGA 版块 fid，将其添加到收藏版块中",
            textAlign: isApple ? TextAlign.center : TextAlign.start,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          // FID 输入框（支持负数 fid，如 -7 大漩涡）
          TextField(
            controller: fidController,
            autofocus: true,
            enabled: !submitting.value,
            keyboardType: const TextInputType.numberWithOptions(signed: true),
            textInputAction: TextInputAction.next,
            onSubmitted: (_) => nameFocusNode.requestFocus(),
            decoration: buildDecoration(
              label: "版块 ID (fid)",
              hint: "如 -7 或 414",
              icon: AppIcons.tag(context),
            ),
          ),
          const SizedBox(height: 14),
          // 名称输入框
          TextField(
            controller: nameController,
            focusNode: nameFocusNode,
            enabled: !submitting.value,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => submit(),
            decoration: buildDecoration(
              label: "版块名称",
              hint: "输入版块显示名称",
              icon: AppIcons.forum(context),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: submitting.value
              ? null
              : () => Navigator.of(context).pop(),
          child: const Text("取消"),
        ),
        FilledButton(
          onPressed: submitting.value ? null : submit,
          child: submitting.value
              ? const SizedBox.square(
                  dimension: 16,
                  child: AppActivityIndicator(radius: 8, strokeWidth: 2),
                )
              : const Text("添加"),
        ),
      ],
    );
  }
}
