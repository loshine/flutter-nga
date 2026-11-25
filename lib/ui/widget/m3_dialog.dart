import 'package:cupertino_ui/cupertino_ui.dart'
    show CupertinoAlertDialog, CupertinoDialogAction;
import 'package:material_ui/material_ui.dart';

import 'package:flutter_nga/providers/settings/design_style_provider.dart';
import 'package:flutter_nga/ui/widget/adaptive/liquid_glass_surface.dart';
import 'package:flutter_nga/utils/dimen.dart';

/// 响应式选择面板断点：小于 600dp 使用底部弹出 Modal Bottom Sheet，宽屏使用居中 Dialog。
const double kSelectionSheetBreakpoint = 600.0;

/// 按屏幕宽度与当前设计风格自动展示选择面板：
/// - Material You：窄屏 Modal Bottom Sheet，宽屏居中 M3 Dialog；
/// - Apple 风格：窄屏液态玻璃浮起 Sheet，宽屏居中液态玻璃 Sheet Dialog。
Future<T?> showM3SelectionSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  double maxDialogWidth = 440,
}) {
  final isCompact =
      MediaQuery.sizeOf(context).width < kSelectionSheetBreakpoint;
  final isApple = context.isAppleStyle;

  if (isCompact) {
    if (isApple) {
      return showModalBottomSheet<T>(
        context: context,
        backgroundColor: Colors.transparent,
        elevation: 0,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (sheetContext) => Padding(
          padding: EdgeInsets.fromLTRB(
            8,
            0,
            8,
            8 + MediaQuery.viewInsetsOf(sheetContext).bottom,
          ),
          child: LiquidGlassSurface(
            borderRadius: BorderRadius.circular(28),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 8),
                  Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Theme.of(sheetContext).colorScheme.onSurfaceVariant
                          .withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Flexible(child: builder(sheetContext)),
                ],
              ),
            ),
          ),
        ),
      );
    }

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

  if (isApple) {
    return showDialog<T>(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxDialogWidth),
          child: LiquidGlassSurface(
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: builder(dialogContext),
            ),
          ),
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
        // 子面板在 embedded 模式下按带 DragHandle 的 BottomSheet 预留了 4dp 顶部间距，
        // Dialog 无拖动手柄，在此补足 20dp 以对齐 M3 Dialog 的 24dp 顶部规范。
        child: Padding(
          padding: const EdgeInsets.only(top: 20),
          child: builder(dialogContext),
        ),
      ),
    ),
  );
}

/// 平台自适应基础 Dialog：Material You 使用 M3 圆角卡片，Apple 风格使用 Liquid Glass 弹窗。
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
    final isApple = context.isAppleStyle;

    final inner = ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 440),
      child: Padding(
        padding: EdgeInsets.all(isApple ? 20 : 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: isApple
              ? CrossAxisAlignment.stretch
              : CrossAxisAlignment.start,
          children: [
            Text(
              title,
              textAlign: isApple ? TextAlign.center : TextAlign.start,
              style: (isApple ? textTheme.titleMedium : textTheme.headlineSmall)
                  ?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: isApple ? FontWeight.w600 : null,
                  ),
            ),
            const SizedBox(height: 16),
            scrollable
                ? Flexible(child: SingleChildScrollView(child: content))
                : content,
            if (actions != null) ...[
              SizedBox(height: isApple ? 20 : 24),
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
    );

    if (isApple) {
      return Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: LiquidGlassSurface(
          borderRadius: BorderRadius.circular(22),
          child: inner,
        ),
      );
    }

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimen.radiusXL),
      ),
      backgroundColor: colorScheme.surfaceContainerHigh,
      child: inner,
    );
  }
}

/// 平台自适应确认弹窗：
/// - Apple 风格渲染原生 [CupertinoAlertDialog]；
/// - Material You 渲染 [M3Dialog]。
/// 取消返回 false，确认返回 true 并触发 [onConfirm]。
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
    if (context.isAppleStyle) {
      return CupertinoAlertDialog(
        title: Text(title),
        content: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(content),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          CupertinoDialogAction(
            isDestructiveAction: destructive,
            isDefaultAction: !destructive,
            onPressed: () {
              Navigator.of(context).pop(true);
              onConfirm?.call();
            },
            child: Text(confirmText),
          ),
        ],
      );
    }

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
