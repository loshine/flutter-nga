import 'package:material_ui/material_ui.dart';
import 'package:flutter_nga/utils/dimen.dart';

/// 响应式选择面板断点：小于 600dp 使用底部弹出 Modal Bottom Sheet，宽屏使用居中 Dialog。
const double kSelectionSheetBreakpoint = 600.0;

/// 按屏幕宽度自动以 Modal Bottom Sheet（窄屏）或居中 M3 Dialog（宽屏）展示选择面板。
Future<T?> showM3SelectionSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  double maxDialogWidth = 440,
}) {
  final isCompact =
      MediaQuery.sizeOf(context).width < kSelectionSheetBreakpoint;
  if (isCompact) {
    return showModalBottomSheet<T>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) => SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
          ),
          child: builder(sheetContext),
        ),
      ),
    );
  }
  return showDialog<T>(
    context: context,
    builder: (dialogContext) => Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimen.radiusXL),
      ),
      backgroundColor: Theme.of(dialogContext).colorScheme.surfaceContainerHigh,
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxDialogWidth),
        child: builder(dialogContext),
      ),
    ),
  );
}

/// M3 风格的基础 Dialog
class M3Dialog extends StatelessWidget {
  final String title;
  final Widget content;
  final List<Widget>? actions;
  final bool scrollable;

  const M3Dialog({
    super.key,
    required this.title,
    required this.content,
    this.actions,
    this.scrollable = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimen.radiusXL),
      ),
      backgroundColor: colorScheme.surfaceContainerHigh,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 标题
              Text(
                title,
                style: textTheme.headlineSmall?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              // 内容
              scrollable
                  ? Flexible(child: SingleChildScrollView(child: content))
                  : content,
              // 操作按钮
              if (actions != null) ...[
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: actions!
                      .map(
                        (action) => Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: action,
                        ),
                      )
                      .toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// M3 风格的确认 Dialog；取消返回 false，确认返回 true 并触发 [onConfirm]。
class M3ConfirmDialog extends StatelessWidget {
  final String title;
  final String content;
  final String confirmText;
  final String cancelText;
  final VoidCallback? onConfirm;
  final bool destructive;

  const M3ConfirmDialog({
    super.key,
    required this.title,
    required this.content,
    this.confirmText = "确定",
    this.cancelText = "取消",
    this.onConfirm,
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return M3Dialog(
      title: title,
      content: Text(
        content,
        style: Theme.of(context).textTheme.bodyMedium
            ?.copyWith(color: colorScheme.onSurfaceVariant),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(cancelText),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop(true);
            onConfirm?.call();
          },
          style: destructive
              ? FilledButton.styleFrom(
                  backgroundColor: colorScheme.error,
                  foregroundColor: colorScheme.onError,
                )
              : null,
          child: Text(confirmText),
        ),
      ],
    );
  }
}
