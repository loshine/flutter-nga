import 'package:cupertino_ui/cupertino_ui.dart'
    show
        CupertinoActionSheet,
        CupertinoActionSheetAction,
        showCupertinoModalPopup;
import 'package:material_ui/material_ui.dart';

import 'package:flutter_nga/providers/settings/design_style_provider.dart';
import 'package:flutter_nga/ui/widget/adaptive/app_icons.dart';

/// 跨平台操作菜单项描述。
class AppMenuAction<T> {
  const AppMenuAction({
    required this.value,
    required this.label,
    this.icon,
    this.destructive = false,
  });

  final T value;
  final String label;
  final IconData? icon;
  final bool destructive;
}

/// 平台原生上下文/动作菜单：
/// - iOS（Apple 移动端）：弹出标准 [CupertinoActionSheet]；
/// - macOS / 桌面（带鼠标右键位置 [globalPosition]）：弹出紧凑右键菜单；
/// - Material You：弹出标准位置菜单或底部面板。
Future<T?> showAppActionMenu<T>({
  required BuildContext context,
  required List<AppMenuAction<T>> actions,
  String? title,
  Offset? globalPosition,
}) async {
  if (actions.isEmpty) return null;

  // iOS（非桌面 Apple）弹出标准底部 CupertinoActionSheet
  if (context.isAppleStyle && !context.isMacDesktopAppleStyle) {
    return showCupertinoModalPopup<T>(
      context: context,
      builder: (sheetContext) => CupertinoActionSheet(
        title: title != null ? Text(title) : null,
        actions: [
          for (final action in actions)
            CupertinoActionSheetAction(
              isDestructiveAction: action.destructive,
              onPressed: () => Navigator.of(sheetContext).pop(action.value),
              child: Text(action.label),
            ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () => Navigator.of(sheetContext).pop(),
          child: const Text('取消'),
        ),
      ),
    );
  }

  final overlay = Overlay.of(context).context.findRenderObject() as RenderBox?;
  final overlaySize = overlay?.size ?? MediaQuery.sizeOf(context);
  final anchor =
      globalPosition ?? Offset(overlaySize.width / 2, overlaySize.height / 2);

  final colorScheme = Theme.of(context).colorScheme;
  final isMac = context.isMacDesktopAppleStyle;

  return showMenu<T>(
    context: context,
    position: RelativeRect.fromRect(
      Rect.fromLTWH(anchor.dx, anchor.dy, 1, 1),
      Offset.zero & overlaySize,
    ),
    items: [
      for (final action in actions)
        PopupMenuItem<T>(
          value: action.value,
          height: isMac ? 32 : 44,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (action.icon != null) ...[
                Icon(
                  action.icon,
                  size: isMac ? 15 : 18,
                  color: action.destructive
                      ? colorScheme.error
                      : colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
              ],
              Text(
                action.label,
                style: TextStyle(
                  fontSize: isMac ? 13 : 14,
                  color: action.destructive
                      ? colorScheme.error
                      : colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
    ],
  );
}

/// 跨平台「更多操作」菜单按钮：
/// - Material You：保持原生 [PopupMenuButton]；
/// - Apple 风格：以按钮自身 [RenderBox] 为锚点弹出 [showAppActionMenu]。
class AppMoreMenuButton<T> extends StatefulWidget {
  const AppMoreMenuButton({
    super.key,
    required this.actions,
    required this.onSelected,
    this.tooltip = '更多操作',
    this.icon,
    this.title,
  });

  final List<AppMenuAction<T>> actions;
  final ValueChanged<T> onSelected;
  final String tooltip;
  final Widget? icon;
  final String? title;

  @override
  State<AppMoreMenuButton<T>> createState() => AppMoreMenuButtonState<T>();
}

class AppMoreMenuButtonState<T> extends State<AppMoreMenuButton<T>> {
  final _popupKey = GlobalKey<PopupMenuButtonState<T>>();

  /// 以当前按钮为锚点弹出菜单（供列表项长按等场景复用）。
  Future<void> showMenu() async {
    if (!mounted || widget.actions.isEmpty) return;
    if (!context.isAppleStyle) {
      _popupKey.currentState?.showButtonMenu();
      return;
    }
    final box = context.findRenderObject() as RenderBox?;
    final pos = box?.localToGlobal(Offset(box.size.width, box.size.height));
    final selected = await showAppActionMenu<T>(
      context: context,
      title: widget.title,
      globalPosition: pos,
      actions: widget.actions,
    );
    if (selected != null && mounted) {
      widget.onSelected(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (context.isAppleStyle) {
      return IconButton(
        tooltip: widget.tooltip,
        icon: widget.icon ?? Icon(AppIcons.more(context)),
        onPressed: showMenu,
      );
    }
    final colorScheme = Theme.of(context).colorScheme;
    return PopupMenuButton<T>(
      key: _popupKey,
      tooltip: widget.tooltip,
      icon: widget.icon,
      onSelected: widget.onSelected,
      itemBuilder: (_) => [
        for (final action in widget.actions)
          PopupMenuItem<T>(
            value: action.value,
            child: action.icon != null
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        action.icon,
                        size: 20,
                        color: action.destructive
                            ? colorScheme.error
                            : colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        action.label,
                        style: action.destructive
                            ? TextStyle(color: colorScheme.error)
                            : null,
                      ),
                    ],
                  )
                : Text(
                    action.label,
                    style: action.destructive
                        ? TextStyle(color: colorScheme.error)
                        : null,
                  ),
          ),
      ],
    );
  }
}
