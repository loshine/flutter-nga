import 'package:flutter/material.dart';

/// 尺寸常量 - M3 Typography 对齐版本
/// 
/// 推荐使用 Theme.of(context).textTheme 获取文字样式，
/// 本类提供数值常量用于特殊场景
class Dimen {
  // ============ M3 Typography Scale ============
  // 参考: https://m3.material.io/styles/typography/type-scale-tokens
  
  /// Display Large: 57sp
  static const double displayLarge = 57;
  
  /// Display Medium: 45sp
  static const double displayMedium = 45;
  
  /// Display Small: 36sp
  static const double displaySmall = 36;
  
  /// Headline Large: 32sp
  static const double headlineLarge = 32;
  
  /// Headline Medium: 28sp
  static const double headlineMedium = 28;
  
  /// Headline Small: 24sp
  static const double headlineSmall = 24;
  
  /// Title Large: 22sp
  static const double titleLarge = 22;
  
  /// Title Medium: 16sp
  static const double titleMedium = 16;
  
  /// Title Small: 14sp
  static const double titleSmall = 14;
  
  /// Body Large: 16sp
  static const double bodyLarge = 16;
  
  /// Body Medium: 14sp
  static const double bodyMedium = 14;
  
  /// Body Small: 12sp
  static const double bodySmall = 12;
  
  /// Label Large: 14sp
  static const double labelLarge = 14;
  
  /// Label Medium: 12sp
  static const double labelMedium = 12;
  
  /// Label Small: 11sp
  static const double labelSmall = 11;

  // ============ 兼容性别名（逐步废弃）============
  
  @Deprecated('使用 labelLarge 替代')
  static const double button = labelLarge;
  
  @Deprecated('使用 bodySmall 替代')
  static const double caption = bodySmall;
  
  @Deprecated('使用 bodyMedium 替代')
  static const double body = bodyMedium;
  
  @Deprecated('使用 titleMedium 替代')
  static const double subheading = titleMedium;
  
  @Deprecated('使用 titleLarge 替代')
  static const double title = titleLarge;
  
  @Deprecated('使用 headlineSmall 替代')
  static const double headline = headlineSmall;
  
  @Deprecated('使用 displaySmall 替代')
  static const double display1 = displaySmall;
  
  @Deprecated('使用 displayMedium 替代')
  static const double display2 = displayMedium;
  
  @Deprecated('使用 displayLarge 替代')
  static const double display3 = displayLarge;

  // ============ 布局尺寸 ============
  
  /// 底部面板高度
  static const double bottomPanelHeight = 240;
  
  /// 普通图标尺寸
  static const double icon = 12;
  
  /// M3 推荐图标尺寸
  static const double iconSmall = 20;
  static const double iconMedium = 24;
  static const double iconLarge = 40;

  // ============ M3 间距常量 ============
  
  /// 紧凑间距: 4dp
  static const double spacingXS = 4;
  
  /// 小间距: 8dp
  static const double spacingS = 8;
  
  /// 中等间距: 12dp
  static const double spacingM = 12;
  
  /// 标准间距: 16dp
  static const double spacingL = 16;
  
  /// 大间距: 24dp
  static const double spacingXL = 24;
  
  /// 超大间距: 32dp
  static const double spacingXXL = 32;

  // ============ M3 圆角常量 ============
  
  /// 无圆角
  static const double radiusNone = 0;
  
  /// 超小圆角: 4dp
  static const double radiusXS = 4;
  
  /// 小圆角: 8dp
  static const double radiusS = 8;
  
  /// 中等圆角: 12dp (Card, ListTile)
  static const double radiusM = 12;
  
  /// 大圆角: 16dp (FAB)
  static const double radiusL = 16;
  
  /// 超大圆角: 28dp (Dialog)
  static const double radiusXL = 28;
  
  /// 完全圆角 (用于 Chip, Button)
  static const double radiusFull = 100;

  // ============ 辅助方法 ============
  
  /// 获取 M3 TextTheme
  static TextTheme textTheme(BuildContext context) {
    return Theme.of(context).textTheme;
  }
}