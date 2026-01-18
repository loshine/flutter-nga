# Material 3 Expressive UI 翻新计划

> 目标：将 flutter-nga 项目从 Material 2 风格升级为 Material 3 Expressive 风格

## 详细实施计划

| 阶段    | 文档                                                       | 主要内容                     |
| ------- | ---------------------------------------------------------- | ---------------------------- |
| Phase 1 | [核心主题系统重构](./phase1-core-theme-system.md)          | ThemeData、Palette、Dimen    |
| Phase 2 | [导航组件翻新](./phase2-navigation-components.md)          | Drawer、AppBar、FAB          |
| Phase 3 | [列表与卡片组件翻新](./phase3-list-card-components.md)     | TopicListItem、ForumGridItem |
| Phase 4 | [对话框与表单组件翻新](./phase4-dialog-form-components.md) | Dialog、TextField、Button    |
| Phase 5 | [页面细节优化与验证](./phase5-optimization-validation.md)  | 废弃 API、Motion、测试       |

---

## 现状分析

### 当前技术栈

- Flutter 3.38.5 (已支持 M3 Expressive)
- adaptive_theme 管理主题切换
- 硬编码颜色 (Palette 类)
- 手动定义字体大小 (Dimen 类)
- Material 2 组件样式

### 主要问题

1. **未启用 Material 3**: `ThemeData` 缺少 `useMaterial3: true`
2. **硬编码颜色**: Palette 类使用静态颜色，未利用动态色彩
3. **旧版组件**: Drawer、ListTile 等使用 M2 风格
4. **废弃 API**: 使用 `WillPopScope` (应迁移到 `PopScope`)
5. **手动排版**: 未使用 M3 TextTheme 规范

---

## Phase 1: 核心主题系统重构

### 1.1 启用 Material 3 Expressive

**文件**: `lib/my_app.dart`

```dart
ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.brown,
    brightness: Brightness.light,
  ),
  // M3 Expressive 特性
  pageTransitionsTheme: PageTransitionsTheme(
    builders: {
      TargetPlatform.android: CupertinoPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
    },
  ),
)
```

### 1.2 重构 Palette 类

**文件**: `lib/utils/palette.dart`

- 移除硬编码颜色，改用 `Theme.of(context).colorScheme`
- 保留语义化颜色方法，但返回 ColorScheme 中的对应色
- 添加 M3 Expressive 特有的曲面层级色

### 1.3 重构 Dimen 类

**文件**: `lib/utils/dimen.dart`

- 对齐 M3 Typography 规范
- 使用 `Theme.of(context).textTheme` 替代硬编码值

### 1.4 预期改动文件

- `lib/my_app.dart`
- `lib/utils/palette.dart`
- `lib/utils/dimen.dart`

---

## Phase 2: 导航组件翻新

### 2.1 Drawer → NavigationDrawer

**文件**: `lib/ui/page/home/home_page.dart`, `lib/ui/page/home/home_drawer.dart`

- 替换 `Drawer` 为 `NavigationDrawer`
- 使用 `NavigationDrawerDestination` 替代手动 ListTile
- 添加 M3 Expressive 的圆角和间距

### 2.2 AppBar 更新

**所有页面**

- 使用 M3 风格的 `AppBar` (自动圆角、表面色)
- 调整 elevation 使用 `scrolledUnderElevation`

### 2.3 FloatingActionButton 更新

**文件**: `lib/ui/page/home/home_page.dart`

- 使用 `FloatingActionButton.extended` 或 M3 风格 FAB
- 应用 `colorScheme.primaryContainer` 背景

### 2.4 预期改动文件

- `lib/ui/page/home/home_page.dart`
- `lib/ui/page/home/home_drawer.dart`

---

## Phase 3: 列表与卡片组件翻新

### 3.1 ListTile 更新

**所有使用 ListTile 的文件**

- 利用 M3 的新 ListTile 样式
- 使用 `ListTileTheme` 统一配置
- 添加适当的 `contentPadding` 和圆角

### 3.2 TopicListItemWidget 重构

**文件**: `lib/ui/widget/topic_list_item_widget.dart`

- 使用 `Card` 包裹，应用 M3 圆角 (16dp)
- 使用 `colorScheme.surfaceContainerLow` 背景
- 更新图标为 M3 Symbols 风格

### 3.3 ForumGridItemWidget 更新

**文件**: `lib/ui/widget/forum_grid_item_widget.dart`

- 使用 M3 Card 样式
- 添加适当的 elevation 层级

### 3.4 预期改动文件

- `lib/ui/widget/topic_list_item_widget.dart`
- `lib/ui/widget/topic_history_list_item_widget.dart`
- `lib/ui/widget/forum_grid_item_widget.dart`
- `lib/ui/page/settings/settings_page.dart`
- `lib/ui/page/conversation/*.dart`
- `lib/ui/page/notification/*.dart`

---

## Phase 4: 对话框与表单组件翻新

### 4.1 Dialog 更新

**所有 Dialog 文件**

- 使用 `Dialog` 的 M3 风格 (更大圆角 28dp)
- 使用 `AlertDialog.adaptive` 或标准 M3 Dialog
- 统一使用 `FilledButton` 和 `TextButton`

### 4.2 TextField 更新

**发布页面、登录页面等**

- 使用 M3 风格的 `OutlineInputBorder`
- 配置 `filled: true` 与适当的 fillColor

### 4.3 Button 更新

**全局**

- 统一使用 `FilledButton`, `OutlinedButton`, `TextButton`
- 移除旧的 `RaisedButton`, `FlatButton` 用法
- 应用 M3 圆角样式 (20dp)

### 4.4 预期改动文件

- `lib/ui/widget/theme_selection_dialog.dart`
- `lib/ui/widget/custom_forum_dialog.dart`
- `lib/ui/widget/font_size_dialog.dart`
- `lib/ui/widget/font_color_dialog.dart`
- `lib/ui/widget/block_mode_selection_dialog.dart`
- `lib/ui/page/login/login_page.dart`
- `lib/ui/page/publish/publish_page.dart`
- `lib/ui/page/topic_detail/topic_page_select_dialog.dart`

---

## Phase 5: 页面细节优化与验证

### 5.1 废弃 API 迁移

- `WillPopScope` → `PopScope`
- `MaterialStateProperty` → `WidgetStateProperty`

### 5.2 Motion 系统

- 使用 M3 Expressive 的 easing curves
- 统一动画时长

### 5.3 验证清单

- [ ] 浅色主题效果
- [ ] 深色主题效果
- [ ] 无障碍对比度
- [ ] 组件交互状态 (hover, pressed, focused)
- [ ] 静态分析通过
- [ ] 测试通过

### 5.4 预期改动文件

- `lib/ui/page/home/home_page.dart` (WillPopScope)
- 其他需要更新的页面

---

## 实施顺序

```
Phase 1 (核心) → Phase 2 (导航) → Phase 3 (列表) → Phase 4 (对话框) → Phase 5 (验证)
     ↓              ↓               ↓                ↓                ↓
  my_app.dart   home_*.dart    *_item_*.dart    *_dialog.dart     analyze/test
  palette.dart                 settings.dart    login_page.dart
  dimen.dart
```

## 关键 M3 Expressive 特性

| 特性 | M2          | M3 Expressive        |
| ---- | ----------- | -------------------- |
| 圆角 | 4dp         | 12-28dp              |
| 色彩 | 静态        | 动态种子色           |
| 表面 | 单一        | 5 级容器层           |
| 按钮 | Raised/Flat | Filled/Outlined/Text |
| 动效 | 线性        | Emphasized curves    |
| 导航 | Drawer      | NavigationDrawer     |

---

## 风险与注意事项

1. **adaptive_theme 兼容性**: 确保与 M3 ThemeData 配合正常
2. **颜色对比度**: M3 动态色可能影响可读性，需验证
3. **第三方库样式**: flutter_html, pull_to_refresh 等可能需要额外适配
4. **渐进式迁移**: 每个 Phase 完成后验证，避免大规模回滚

---

_创建日期: 2026-01-18_
_Flutter 版本: 3.38.5_
