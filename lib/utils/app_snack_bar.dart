import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';

/// [AppSnackBar.undo] 返回的操作句柄，供页面在离开或退后台时关闭并结算对应的提示。
class UndoSnackBarHandle {
  UndoSnackBarHandle._(this._dismiss);

  final VoidCallback _dismiss;

  /// 关闭当前提示（若仍在展示），触发一次性的 `onCommit` 结算。
  void dismiss() => _dismiss();
}

/// 带操作的底部提示。
///
/// 约定：纯通知用 `AppToast`；需要用户操作（如撤销）的反馈用 SnackBar，
/// 移动端位于拇指可达的底部，桌面端限宽紧凑胶囊浮在操作栏底部，
/// 自带读屏播报，开启无障碍时停留时间会自动延长。
abstract final class AppSnackBar {
  /// 桌面/宽屏下的最大悬浮胶囊宽度（逻辑像素）。
  static const double maxDesktopWidth = 360.0;

  /// 显示「撤销」提示：点了撤销调用 [onUndo]，其余方式关闭（超时、被下一条
  /// 替换、被隐藏）调用 [onCommit]；每次调用最多结算一次，避免重复提交。
  static UndoSnackBarHandle undo(
    BuildContext context, {
    required String message,
    required VoidCallback onUndo,
    required VoidCallback onCommit,
    Duration duration = const Duration(seconds: 4),
  }) {
    final messenger = ScaffoldMessenger.of(context);
    final width = _resolveWidth(context);
    messenger.hideCurrentSnackBar();

    var settled = false;
    void settle({required bool undone}) {
      if (settled) return;
      settled = true;
      if (undone) {
        onUndo();
      } else {
        onCommit();
      }
    }

    final controller = messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
        // 带 action 的 SnackBar 默认 persist（不自动消失），这里要超时后提交。
        // 开启无障碍导航时框架仍会保留提示直到用户处理。
        persist: false,
        behavior: SnackBarBehavior.floating,
        width: width,
        action: SnackBarAction(label: '撤销', onPressed: () {}),
      ),
    );

    controller.closed.then((reason) {
      settle(undone: reason == SnackBarClosedReason.action);
    });

    return UndoSnackBarHandle._(() {
      if (settled) return;
      if (messenger.mounted) {
        messenger.hideCurrentSnackBar();
      }
      settle(undone: false);
    });
  }

  /// 桌面端或宽容器下返回紧凑限宽（不超过 [maxDesktopWidth]，并在窄列表栏中留出两侧间距）；
  /// 移动端窄屏返回 `null` 以使用系统默认浮动边距。
  static double? _resolveWidth(BuildContext context) {
    final isDesktop =
        !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.macOS ||
            defaultTargetPlatform == TargetPlatform.windows ||
            defaultTargetPlatform == TargetPlatform.linux);
    final renderBox = context.findRenderObject() as RenderBox?;
    final hostWidth = (renderBox != null && renderBox.hasSize)
        ? renderBox.size.width
        : MediaQuery.sizeOf(context).width;
    if (!isDesktop && hostWidth < 600) return null;
    final available = hostWidth - 24.0;
    if (available <= 0) return null;
    return math.min(maxDesktopWidth, available);
  }
}
