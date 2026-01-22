import 'package:flutter/material.dart';

/// M3 Expressive Motion 常量
class Motion {
  // ============ Duration 常量 ============
  
  /// 短动画: 50ms (微交互)
  static const Duration durationShort1 = Duration(milliseconds: 50);
  /// 短动画: 100ms (微交互)
  static const Duration durationShort2 = Duration(milliseconds: 100);
  /// 短动画: 150ms (微交互)
  static const Duration durationShort3 = Duration(milliseconds: 150);
  /// 短动画: 200ms (微交互)
  static const Duration durationShort4 = Duration(milliseconds: 200);
  
  /// 中等动画: 250ms (页面内过渡)
  static const Duration durationMedium1 = Duration(milliseconds: 250);
  /// 中等动画: 300ms (页面内过渡)
  static const Duration durationMedium2 = Duration(milliseconds: 300);
  /// 中等动画: 350ms (页面内过渡)
  static const Duration durationMedium3 = Duration(milliseconds: 350);
  /// 中等动画: 400ms (页面内过渡)
  static const Duration durationMedium4 = Duration(milliseconds: 400);
  
  /// 长动画: 450ms (页面间过渡)
  static const Duration durationLong1 = Duration(milliseconds: 450);
  /// 长动画: 500ms (页面间过渡)
  static const Duration durationLong2 = Duration(milliseconds: 500);
  /// 长动画: 550ms (页面间过渡)
  static const Duration durationLong3 = Duration(milliseconds: 550);
  /// 长动画: 600ms (页面间过渡)
  static const Duration durationLong4 = Duration(milliseconds: 600);
  
  /// 超长动画: 700ms+ (复杂动画)
  static const Duration durationExtraLong1 = Duration(milliseconds: 700);
  static const Duration durationExtraLong2 = Duration(milliseconds: 800);
  static const Duration durationExtraLong3 = Duration(milliseconds: 900);
  static const Duration durationExtraLong4 = Duration(milliseconds: 1000);

  // ============ Easing 曲线 ============
  
  /// 标准 Emphasized 曲线 (最常用)
  static const Curve emphasized = Cubic(0.2, 0.0, 0.0, 1.0);
  
  /// Emphasized 加速 (退出动画)
  static const Curve emphasizedAccelerate = Cubic(0.3, 0.0, 0.8, 0.15);
  
  /// Emphasized 减速 (进入动画)
  static const Curve emphasizedDecelerate = Cubic(0.05, 0.7, 0.1, 1.0);
  
  /// Standard 曲线 (次要动画)
  static const Curve standard = Cubic(0.2, 0.0, 0.0, 1.0);
  
  /// Standard 加速
  static const Curve standardAccelerate = Cubic(0.3, 0.0, 1.0, 1.0);
  
  /// Standard 减速
  static const Curve standardDecelerate = Cubic(0.0, 0.0, 0.0, 1.0);
  
  /// 线性 (进度条等)
  static const Curve linear = Curves.linear;

  // ============ 常用动画预设 ============
  
  /// 淡入动画
  static const fadeIn = (
    duration: durationMedium2,
    curve: emphasizedDecelerate,
  );
  
  /// 淡出动画
  static const fadeOut = (
    duration: durationShort4,
    curve: emphasizedAccelerate,
  );
  
  /// 展开动画
  static const expand = (
    duration: durationMedium2,
    curve: emphasized,
  );
  
  /// 收起动画
  static const collapse = (
    duration: durationShort4,
    curve: emphasized,
  );
  
  /// 页面进入
  static const pageEnter = (
    duration: durationMedium4,
    curve: emphasizedDecelerate,
  );
  
  /// 页面退出
  static const pageExit = (
    duration: durationShort4,
    curve: emphasizedAccelerate,
  );
}