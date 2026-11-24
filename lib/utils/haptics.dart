import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

/// 关键操作的轻量触感反馈，统一从这里调用。
///
/// 保持克制：普通点击和页面跳转不加。`InkWell` / `ListTile` 的长按默认
/// `enableFeedback`，已由 [Feedback.forLongPress] 在 Android、iOS 上震动，
/// 长按呼出菜单时不要再重复调用。
///
/// 是否震动由系统的触感设置决定（Android「触摸反馈」、iOS「系统触感反馈」），
/// 应用内不另设开关。
abstract final class AppHaptics {
  /// 点赞 / 点踩成功。
  static Future<void> reactionSucceeded() => HapticFeedback.lightImpact();

  /// 收藏 / 关键开关状态切换成功。
  static Future<void> selectionChanged() => HapticFeedback.selectionClick();

  /// 滑动操作越过或退回触发阈值。
  static Future<void> swipeThresholdChanged() =>
      HapticFeedback.selectionClick();

  /// 供 [Dismissible.onUpdate] 使用：仅在越过 / 退回阈值的那一帧反馈一次。
  static void onDismissUpdate(DismissUpdateDetails details) {
    if (details.reached != details.previousReached) {
      swipeThresholdChanged();
    }
  }
}
