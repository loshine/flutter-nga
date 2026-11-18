import 'package:material_ui/material_ui.dart';

/// 带操作的底部提示。
///
/// 约定：纯通知用 `AppToast`；需要用户操作（如撤销）的反馈用 SnackBar，
/// 它在拇指可达的底部、自带读屏播报，开启无障碍时停留时间会自动延长。
abstract final class AppSnackBar {
  /// 显示「撤销」提示：点了撤销调用 [onUndo]，其余方式关闭（超时、被下一条
  /// 替换、被隐藏）调用 [onCommit]。显示前会先关掉当前提示，使上一次操作提交。
  static void undo(
    BuildContext context, {
    required String message,
    required VoidCallback onUndo,
    required VoidCallback onCommit,
    Duration duration = const Duration(seconds: 4),
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger
        .showSnackBar(
          SnackBar(
            content: Text(message),
            duration: duration,
            // 带 action 的 SnackBar 默认 persist（不自动消失），这里要超时后提交。
            // 开启无障碍导航时框架仍会保留提示直到用户处理。
            persist: false,
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(label: '撤销', onPressed: () {}),
          ),
        )
        .closed
        .then((reason) {
          if (reason == SnackBarClosedReason.action) {
            onUndo();
          } else {
            onCommit();
          }
        });
  }
}
