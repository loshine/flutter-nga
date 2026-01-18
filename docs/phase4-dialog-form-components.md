# Phase 4: 对话框与表单组件翻新

> 目标：将 Dialog、TextField、Button 等组件升级为 M3 Expressive 风格

## 概述

本阶段主要完成：
1. Dialog 使用 M3 大圆角样式
2. TextField 使用 M3 风格装饰
3. Button 统一使用 FilledButton/OutlinedButton/TextButton
4. 废弃 API 迁移（MaterialStateProperty → WidgetStateProperty）

## 前置条件

- Phase 1-3 已完成

## 改动文件清单

| 文件 | 改动类型 | 优先级 |
|------|----------|--------|
| `lib/ui/widget/theme_selection_dialog.dart` | 更新 | P0 |
| `lib/ui/widget/custom_forum_dialog.dart` | 更新 | P0 |
| `lib/ui/widget/font_size_dialog.dart` | 更新 | P1 |
| `lib/ui/widget/font_color_dialog.dart` | 更新 | P1 |
| `lib/ui/widget/block_mode_selection_dialog.dart` | 更新 | P1 |
| `lib/ui/widget/import_cookies_dialog.dart` | 更新 | P1 |
| `lib/ui/page/login/login_page.dart` | 更新 | P1 |
| `lib/ui/page/publish/publish_page.dart` | 更新 | P2 |
| `lib/ui/page/topic_detail/topic_page_select_dialog.dart` | 更新 | P2 |
| `lib/ui/page/topic_detail/topic_reply_item_widget.dart` | 更新 | P1 |
| `lib/ui/widget/collapse_widget.dart` | 更新 | P2 |

---

## 4.1 Dialog 通用模板

### M3 Dialog 特性

| 属性 | M2 | M3 |
|------|----|----|
| 圆角 | 4dp | 28dp |
| 内边距 | 24dp | 24dp |
| 标题字号 | 20sp | 24sp (headlineSmall) |
| 按钮样式 | TextButton | TextButton/FilledButton |

### 通用 Dialog 封装

建议创建通用的 M3 Dialog 组件。

### 新文件：`lib/ui/widget/m3_dialog.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_nga/utils/dimen.dart';
import 'package:flutter_nga/utils/route.dart';

/// M3 风格的基础 Dialog
class M3Dialog extends StatelessWidget {
  final String title;
  final Widget content;
  final List<Widget>? actions;
  final bool scrollable;

  const M3Dialog({
    Key? key,
    required this.title,
    required this.content,
    this.actions,
    this.scrollable = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimen.radiusXL),
      ),
      backgroundColor: colorScheme.surfaceContainerHigh,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题
            Text(
              title,
              style: textTheme.headlineSmall?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            // 内容
            scrollable
                ? Flexible(child: SingleChildScrollView(child: content))
                : content,
            // 操作按钮
            if (actions != null) ...[
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: actions!
                    .map((action) => Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: action,
                        ))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// M3 风格的确认 Dialog
class M3ConfirmDialog extends StatelessWidget {
  final String title;
  final String content;
  final String confirmText;
  final String cancelText;
  final VoidCallback? onConfirm;
  final bool destructive;

  const M3ConfirmDialog({
    Key? key,
    required this.title,
    required this.content,
    this.confirmText = "确定",
    this.cancelText = "取消",
    this.onConfirm,
    this.destructive = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return M3Dialog(
      title: title,
      content: Text(
        content,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
      ),
      actions: [
        TextButton(
          onPressed: () => Routes.pop(context),
          child: Text(cancelText),
        ),
        FilledButton(
          onPressed: () {
            Routes.pop(context);
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
```

---

## 4.2 ThemeSelectionDialog 重构

### 文件：`lib/ui/widget/theme_selection_dialog.dart`

### 目标代码

```dart
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nga/providers/settings/theme_provider.dart';
import 'package:flutter_nga/utils/dimen.dart';
import 'package:flutter_nga/utils/route.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ThemeSelectionDialog extends ConsumerWidget {
  const ThemeSelectionDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(themeProvider);
    final notifier = ref.read(themeProvider.notifier);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimen.radiusXL),
      ),
      backgroundColor: colorScheme.surfaceContainerHigh,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 24, 0, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                "选择主题模式",
                style: textTheme.headlineSmall?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // 选项列表
            _ThemeOption(
              title: "跟随系统",
              subtitle: "根据系统设置自动切换",
              icon: Icons.brightness_auto,
              selected: state.mode == AdaptiveThemeMode.system,
              onTap: () => notifier.update(context, AdaptiveThemeMode.system),
            ),
            _ThemeOption(
              title: "亮色主题",
              subtitle: "始终使用亮色主题",
              icon: Icons.light_mode_outlined,
              selected: state.mode == AdaptiveThemeMode.light,
              onTap: () => notifier.update(context, AdaptiveThemeMode.light),
            ),
            _ThemeOption(
              title: "暗色主题",
              subtitle: "始终使用暗色主题",
              icon: Icons.dark_mode_outlined,
              selected: state.mode == AdaptiveThemeMode.dark,
              onTap: () => notifier.update(context, AdaptiveThemeMode.dark),
            ),
            
            const SizedBox(height: 8),
            
            // 关闭按钮
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Routes.pop(context),
                    child: const Text('关闭'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        color: selected ? colorScheme.secondaryContainer : null,
        child: Row(
          children: [
            Icon(
              icon,
              color: selected
                  ? colorScheme.onSecondaryContainer
                  : colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: textTheme.bodyLarge?.copyWith(
                      color: selected
                          ? colorScheme.onSecondaryContainer
                          : colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: textTheme.bodySmall?.copyWith(
                      color: selected
                          ? colorScheme.onSecondaryContainer.withOpacity(0.8)
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              Icon(
                Icons.check,
                color: colorScheme.onSecondaryContainer,
              ),
          ],
        ),
      ),
    );
  }
}
```

---

## 4.3 CustomForumDialog 重构

### 文件：`lib/ui/widget/custom_forum_dialog.dart`

### 目标代码

```dart
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_nga/providers/forum/favourite_forum_list_provider.dart';
import 'package:flutter_nga/utils/dimen.dart';
import 'package:flutter_nga/utils/route.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class CustomForumDialog extends HookConsumerWidget {
  const CustomForumDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fidController = useTextEditingController();
    final nameController = useTextEditingController();
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimen.radiusXL),
      ),
      backgroundColor: colorScheme.surfaceContainerHigh,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题
            Text(
              "添加自定义版面",
              style: textTheme.headlineSmall?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 24),
            
            // FID 输入框
            TextField(
              controller: fidController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "版面 ID (fid)",
                hintText: "输入版面 ID",
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(Dimen.radiusS),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(Dimen.radiusS),
                  borderSide: BorderSide(
                    color: colorScheme.primary,
                    width: 2,
                  ),
                ),
                prefixIcon: Icon(
                  Icons.tag,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // 名称输入框
            TextField(
              controller: nameController,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                labelText: "版面名称",
                hintText: "输入版面显示名称",
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(Dimen.radiusS),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(Dimen.radiusS),
                  borderSide: BorderSide(
                    color: colorScheme.primary,
                    width: 2,
                  ),
                ),
                prefixIcon: Icon(
                  Icons.forum_outlined,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // 操作按钮
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Routes.pop(context),
                  child: const Text("取消"),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () => _addForum(
                    context,
                    ref,
                    fidController.text,
                    nameController.text,
                  ),
                  child: const Text("添加"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _addForum(
    BuildContext context,
    WidgetRef ref,
    String fidText,
    String name,
  ) {
    final fid = int.tryParse(fidText);
    if (fid == null) {
      Fluttertoast.showToast(msg: "请输入有效的版面 ID");
      return;
    }
    if (name.isEmpty) {
      Fluttertoast.showToast(msg: "请输入版面名称");
      return;
    }

    ref
        .read(favouriteForumListProvider.notifier)
        .add(fid, name)
        .then((_) {
          Fluttertoast.showToast(msg: "添加成功");
          Routes.pop(context);
        })
        .catchError((e) {
          debugPrint(e.toString());
          Fluttertoast.showToast(msg: "添加自定义板块失败");
        });
  }
}
```

### 关键变更

1. **使用 hooks**：`useTextEditingController()` 自动管理生命周期
2. **M3 TextField 样式**：
   - `filled: true` + `fillColor`
   - `borderSide: BorderSide.none` 默认无边框
   - `focusedBorder` 聚焦时显示 primary 边框
3. **FilledButton**：主操作使用填充按钮
4. **输入验证**：添加简单的验证逻辑

---

## 4.4 TextField 通用样式

建议在 `my_app.dart` 的 ThemeData 中配置全局 TextField 样式。

### 添加到 `_buildLightTheme()` / `_buildDarkTheme()`

```dart
inputDecorationTheme: InputDecorationTheme(
  filled: true,
  fillColor: colorScheme.surfaceContainerHighest,
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(Dimen.radiusS),
    borderSide: BorderSide.none,
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(Dimen.radiusS),
    borderSide: BorderSide.none,
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(Dimen.radiusS),
    borderSide: BorderSide(
      color: colorScheme.primary,
      width: 2,
    ),
  ),
  errorBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(Dimen.radiusS),
    borderSide: BorderSide(
      color: colorScheme.error,
      width: 1,
    ),
  ),
  focusedErrorBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(Dimen.radiusS),
    borderSide: BorderSide(
      color: colorScheme.error,
      width: 2,
    ),
  ),
  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
),
```

---

## 4.5 MaterialStateProperty → WidgetStateProperty

### 文件：`lib/ui/page/topic_detail/topic_reply_item_widget.dart`

### 当前代码问题

```dart
ElevatedButton(
  style: ButtonStyle(elevation: MaterialStateProperty.all(0)),  // 已废弃
  child: Text(...),
  onPressed: ...,
)
```

### 目标代码

```dart
FilledButton.tonal(
  onPressed: () => setState(() => _attachmentsExpanded = !_attachmentsExpanded),
  child: Text(
    _attachmentsExpanded ? "收起附件" : "展开附件",
    style: TextStyle(fontSize: Dimen.labelLarge),
  ),
)
```

### 变更说明

- 使用 `FilledButton.tonal` 替代 `ElevatedButton`
- 移除 `MaterialStateProperty`（Flutter 3.22+ 废弃，改用 `WidgetStateProperty`）
- 简化按钮样式配置

---

## 4.6 FontSizeDialog 重构

### 文件：`lib/ui/widget/font_size_dialog.dart`

### 目标代码

```dart
import 'package:flutter/material.dart';
import 'package:flutter_nga/ui/widget/font_style_widget.dart';
import 'package:flutter_nga/utils/dimen.dart';
import 'package:flutter_nga/utils/route.dart';

class FontSizeDialog extends StatelessWidget {
  const FontSizeDialog({this.callback, Key? key}) : super(key: key);
  final InputCallback? callback;

  static const sizeList = [
    ("110%", 1.1),
    ("120%", 1.2),
    ("130%", 1.3),
    ("150%", 1.5),
    ("200%", 2.0),
    ("300%", 3.0),
    ("400%", 4.0),
    ("500%", 5.0),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimen.radiusXL),
      ),
      backgroundColor: colorScheme.surfaceContainerHigh,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 24, 0, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                "字号",
                style: textTheme.headlineSmall?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 400),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: sizeList.length,
                itemBuilder: (context, index) {
                  final (label, _) = sizeList[index];
                  return _SizeOption(
                    label: label,
                    onTap: () {
                      callback?.call("[size=$label]", "[/size]", true);
                      Routes.pop(context);
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Routes.pop(context),
                    child: const Text('取消'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SizeOption extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _SizeOption({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        child: Row(
          children: [
            Icon(
              Icons.format_size,
              color: colorScheme.onSurfaceVariant,
              size: 20,
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 4.7 Button 样式总结

### M3 Button 类型对照

| 场景 | M2 | M3 |
|------|----|----|
| 主要操作 | ElevatedButton | FilledButton |
| 次要操作 | OutlinedButton | OutlinedButton |
| 第三操作 | TextButton | TextButton |
| 低强调操作 | FlatButton | FilledButton.tonal |
| 图标按钮 | IconButton | IconButton |

### 全局 Button 主题配置

添加到 `_buildLightTheme()` / `_buildDarkTheme()`：

```dart
// FilledButton 主题
filledButtonTheme: FilledButtonThemeData(
  style: FilledButton.styleFrom(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(Dimen.radiusFull),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
  ),
),

// OutlinedButton 主题
outlinedButtonTheme: OutlinedButtonThemeData(
  style: OutlinedButton.styleFrom(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(Dimen.radiusFull),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
  ),
),

// TextButton 主题
textButtonTheme: TextButtonThemeData(
  style: TextButton.styleFrom(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(Dimen.radiusFull),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  ),
),

// Dialog 主题
dialogTheme: DialogTheme(
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(Dimen.radiusXL),
  ),
  backgroundColor: colorScheme.surfaceContainerHigh,
),
```

---

## 验证清单

- [ ] 所有 Dialog 圆角正确 (28dp)
- [ ] TextField 样式统一
- [ ] FilledButton/TextButton 点击效果正常
- [ ] 无 `MaterialStateProperty` 废弃警告
- [ ] Dialog 在不同屏幕尺寸下正常显示
- [ ] 深色主题下颜色正确
- [ ] `fvm flutter analyze` 无错误

## 回滚策略

如果出现严重问题：
1. 恢复 AlertDialog 使用
2. 保留 ElevatedButton/TextButton

## 下一阶段

完成本阶段后，进入 [Phase 5: 页面细节优化与验证](./phase5-optimization-validation.md)

---

*创建日期: 2026-01-18*
