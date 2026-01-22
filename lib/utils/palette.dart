import 'package:flutter/material.dart';

/// 调色板 - M3 Expressive 版本
/// 
/// 所有颜色都从 ColorScheme 动态获取，支持主题切换和动态色彩
class Palette {
  // ============ 种子色定义 ============
  static const seedColorLight = Colors.brown;
  static const seedColorDark = Colors.teal;

  // ============ 语义色特例（非 ColorScheme 覆盖的场景）============
  static const colorTextLock = Color(0xFFC58080);
  static const colorTextAssemble = Color(0xFFA0B4F0);

  // ============ 主题判断 ============
  static bool isDark(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  // ============ ColorScheme 快捷访问 ============
  static ColorScheme colorScheme(BuildContext context) {
    return Theme.of(context).colorScheme;
  }

  // ============ Primary 色系 ============
  static Color primary(BuildContext context) => colorScheme(context).primary;
  static Color onPrimary(BuildContext context) => colorScheme(context).onPrimary;
  static Color primaryContainer(BuildContext context) => colorScheme(context).primaryContainer;
  static Color onPrimaryContainer(BuildContext context) => colorScheme(context).onPrimaryContainer;

  // ============ Secondary 色系 ============
  static Color secondary(BuildContext context) => colorScheme(context).secondary;
  static Color onSecondary(BuildContext context) => colorScheme(context).onSecondary;

  // ============ Surface 色系 (M3 5级容器层) ============
  static Color surface(BuildContext context) => colorScheme(context).surface;
  static Color onSurface(BuildContext context) => colorScheme(context).onSurface;
  static Color surfaceContainerLowest(BuildContext context) => colorScheme(context).surfaceContainerLowest;
  static Color surfaceContainerLow(BuildContext context) => colorScheme(context).surfaceContainerLow;
  static Color surfaceContainer(BuildContext context) => colorScheme(context).surfaceContainer;
  static Color surfaceContainerHigh(BuildContext context) => colorScheme(context).surfaceContainerHigh;
  static Color surfaceContainerHighest(BuildContext context) => colorScheme(context).surfaceContainerHighest;

  // ============ Outline 色系 ============
  static Color outline(BuildContext context) => colorScheme(context).outline;
  static Color outlineVariant(BuildContext context) => colorScheme(context).outlineVariant;

  // ============ Error 色系 ============
  static Color error(BuildContext context) => colorScheme(context).error;
  static Color onError(BuildContext context) => colorScheme(context).onError;

  // ============ 兼容性方法（逐步废弃）============
  
  @Deprecated('使用 primary(context) 替代')
  static Color getColorPrimary(BuildContext context) => primary(context);
  
  // 保留原有静态变量以兼容旧代码（虽然不再建议直接使用）
  static final colorPrimary = seedColorLight;
  static final colorDarkPrimary = seedColorDark;
  
  // 以下静态变量在M3重构中应尽量避免使用，但为了兼容性暂时保留，或映射到近似色
  static const colorBackground = Color(0xFFFFF9E3); // 仅作为参考，实际应使用 surface
  static const colorDivider = Color(0xFFBDBDBD); // 仅作为参考
  static const colorIcon = Colors.black45;
  static const colorSplash = Colors.black12;
  static const colorHighlight = Colors.black12;
  static const colorTextPrimary = Colors.black87;
  static const colorTextSecondary = Colors.black54;
  static const colorTextHintWhite = Colors.white54;
  static const colorTextSubTitle = Color(0xFF591804);

  /// 引用背景色 - 使用 surfaceContainerHigh
  static Color getColorQuoteBackground(BuildContext context) {
    return surfaceContainerHigh(context);
  }

  /// 缩略图背景色 - 使用 surfaceContainerHighest
  static Color getColorThumbBackground(BuildContext context) {
    return surfaceContainerHighest(context);
  }

  /// 相册边框色 - 使用 outlineVariant
  static Color getColorAlbumBorder(BuildContext context) {
    return outlineVariant(context);
  }

  /// 相册背景色 - 使用 surfaceContainerLow
  static Color getColorAlbumBackground(BuildContext context) {
    return surfaceContainerLow(context);
  }

  /// 用户信息卡背景 - 使用 surfaceContainerLow
  static Color getColorUserInfoCard(BuildContext context) {
    return surfaceContainerLow(context);
  }

  /// 副标题颜色 - 使用 onSurfaceVariant
  static Color getColorTextSubtitle(BuildContext context) {
    return colorScheme(context).onSurfaceVariant;
  }

  /// Drawer ListTile 选中背景 - 使用 secondaryContainer
  static Color getColorDrawerListTileBackground(BuildContext context) {
    return colorScheme(context).secondaryContainer;
  }
}