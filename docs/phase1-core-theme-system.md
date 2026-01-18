# Phase 1: 核心主题系统重构

> 目标：启用 Material 3 Expressive，重构颜色和尺寸系统

## 概述

本阶段是整个 M3 迁移的基础，主要完成：
1. 在 ThemeData 中启用 Material 3
2. 重构 Palette 类，从硬编码颜色迁移到 ColorScheme
3. 重构 Dimen 类，对齐 M3 Typography 规范

## 改动文件清单

| 文件 | 改动类型 | 优先级 |
|------|----------|--------|
| `lib/my_app.dart` | 重构 | P0 |
| `lib/utils/palette.dart` | 重构 | P0 |
| `lib/utils/dimen.dart` | 重构 | P1 |

---

## 1.1 启用 Material 3 Expressive

### 文件：`lib/my_app.dart`

### 当前代码问题

```dart
// 当前代码 - 未启用 M3
ThemeData(
  brightness: Brightness.light,
  primarySwatch: Palette.colorPrimary,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Palette.colorPrimary,
    background: Palette.colorBackground,  // 已废弃
  ),
  // ... 硬编码颜色
)
```

### 目标代码

```dart
ThemeData _buildLightTheme() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: Colors.brown,
    brightness: Brightness.light,
  );
  
  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    // M3 Expressive 页面过渡
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
    // AppBar 主题
    appBarTheme: AppBarTheme(
      centerTitle: true,
      scrolledUnderElevation: 2,
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
    ),
    // Card 主题
    cardTheme: CardTheme(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: colorScheme.surfaceContainerLow,
    ),
    // FAB 主题
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: colorScheme.primaryContainer,
      foregroundColor: colorScheme.onPrimaryContainer,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    // Divider 主题
    dividerTheme: DividerThemeData(
      color: colorScheme.outlineVariant,
      thickness: 1,
    ),
    // ListTile 主题
    listTileTheme: ListTileThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );
}

ThemeData _buildDarkTheme() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: Colors.teal,
    brightness: Brightness.dark,
  );
  
  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
    appBarTheme: AppBarTheme(
      centerTitle: true,
      scrolledUnderElevation: 2,
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
    ),
    cardTheme: CardTheme(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: colorScheme.surfaceContainerLow,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: colorScheme.primaryContainer,
      foregroundColor: colorScheme.onPrimaryContainer,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    dividerTheme: DividerThemeData(
      color: colorScheme.outlineVariant,
      thickness: 1,
    ),
    listTileTheme: ListTileThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );
}
```

### 实施步骤

1. 在 `_MyAppState` 类中创建 `_buildLightTheme()` 和 `_buildDarkTheme()` 方法
2. 在 `AdaptiveTheme` 的 `light` 和 `dark` 参数中使用新方法
3. 添加 `useMaterial3: true`
4. 移除废弃的 `background` 参数，使用 `surfaceContainerLowest` 替代
5. 配置 M3 组件主题（AppBar、Card、FAB、Divider、ListTile）

---

## 1.2 重构 Palette 类

### 文件：`lib/utils/palette.dart`

### 当前代码问题

```dart
class Palette {
  static final colorPrimary = Colors.brown;           // 硬编码
  static final colorBackground = Color(0xFFFFF9E3);   // 硬编码
  static final colorDivider = Color(0xFFBDBDBD);      // 硬编码
  // ...
}
```

### 目标代码

```dart
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
```

### 实施步骤

1. 保留种子色常量 `seedColorLight` 和 `seedColorDark`
2. 添加 `colorScheme(context)` 快捷方法
3. 创建所有 ColorScheme 角色的快捷访问方法
4. 将旧的语义化方法改为返回 ColorScheme 对应色
5. 使用 `@Deprecated` 标记需要废弃的方法
6. 保留无法用 ColorScheme 表达的特殊颜色（如 `colorTextLock`）

---

## 1.3 重构 Dimen 类

### 文件：`lib/utils/dimen.dart`

### 当前代码问题

```dart
class Dimen {
  static final double caption = 12;   // 与 M3 不一致
  static final double body = 14;      // 与 M3 不一致
  static final double subheading = 16;
  static final double title = 20;
  // ...
}
```

### 目标代码

```dart
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
```

### 实施步骤

1. 添加完整的 M3 Typography Scale 常量
2. 使用 `@Deprecated` 标记旧的命名，提供兼容性
3. 添加 M3 间距和圆角常量
4. 添加 `textTheme(context)` 辅助方法
5. 使用 `const` 替代 `final` 提升性能

---

## 验证清单

- [ ] `fvm flutter analyze` 无错误
- [ ] `fvm flutter test` 全部通过
- [ ] 亮色主题正常显示
- [ ] 暗色主题正常显示
- [ ] adaptive_theme 主题切换正常
- [ ] 现有页面无明显视觉回归

## 回滚策略

如果出现严重问题：
1. 恢复 `my_app.dart` 中的 `useMaterial3: false`
2. 保留 Palette/Dimen 的废弃方法可确保兼容性

## 下一阶段

完成本阶段后，进入 [Phase 2: 导航组件翻新](./phase2-navigation-components.md)

---

*创建日期: 2026-01-18*
