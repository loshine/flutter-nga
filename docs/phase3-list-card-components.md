# Phase 3: 列表与卡片组件翻新

> 目标：将列表项和卡片组件升级为 M3 Expressive 风格

## 概述

本阶段主要完成：
1. TopicListItemWidget 使用 Card 包裹
2. ForumGridItemWidget 使用 M3 Card 样式
3. 统一 ListTile 样式
4. 更新设置页面列表项

## 前置条件

- Phase 1 已完成（ThemeData 配置完成）
- Phase 2 已完成（导航组件更新完成）

## 改动文件清单

| 文件 | 改动类型 | 优先级 |
|------|----------|--------|
| `lib/ui/widget/topic_list_item_widget.dart` | 重构 | P0 |
| `lib/ui/widget/topic_history_list_item_widget.dart` | 重构 | P0 |
| `lib/ui/widget/forum_grid_item_widget.dart` | 重构 | P1 |
| `lib/ui/page/settings/settings_page.dart` | 更新 | P1 |
| `lib/ui/page/conversation/conversation_item_widget.dart` | 更新 | P2 |
| `lib/ui/page/notification/notification_item_widget.dart` | 更新 | P2 |

---

## 3.1 TopicListItemWidget 重构

### 文件：`lib/ui/widget/topic_list_item_widget.dart`

### 当前代码问题

```dart
// 当前：无 Card 包裹，使用 Divider 分隔
return InkWell(
  onTap: () => _goTopicDetail(context, topic, ref),
  onLongPress: onLongPress,
  child: Column(children: columnChildren),  // columnChildren 最后是 Divider
);
```

### 目标代码

```dart
import 'package:flutter/material.dart';
import 'package:flutter_nga/data/entity/topic.dart';
import 'package:flutter_nga/providers/settings/blocklist_settings_provider.dart';
import 'package:flutter_nga/providers/settings/interface_settings_provider.dart';
import 'package:flutter_nga/providers/topic/topic_history_provider.dart';
import 'package:flutter_nga/utils/code_utils.dart' as codeUtils;
import 'package:flutter_nga/utils/dimen.dart';
import 'package:flutter_nga/utils/route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TopicListItemWidget extends ConsumerWidget {
  const TopicListItemWidget({
    Key? key,
    required this.topic,
    this.needBlock = true,
    this.onLongPress,
  }) : super(key: key);

  final Topic topic;
  final bool needBlock;
  final GestureLongPressCallback? onLongPress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final blockState = ref.watch(blocklistSettingsProvider);
    final interfaceState = ref.watch(interfaceSettingsProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    
    final blockEnabled =
        blockState.clientBlockEnabled && blockState.listBlockEnabled;
    final blockMode = blockState.blockMode;
    final topicSubject = codeUtils.unescapeHtml(topic.subject);
    final isTopicBlocked = _isBlocked(blockState, topicSubject);

    // 折叠模式
    if (blockEnabled && isTopicBlocked && blockMode == BlockMode.COLLAPSE) {
      return _buildCollapsedCard(context, colorScheme);
    }

    // 隐藏模式
    if (blockEnabled && isTopicBlocked && blockMode == BlockMode.GONE) {
      return const SizedBox.shrink();
    }

    // 计算透明度
    final alpha = (blockEnabled && isTopicBlocked && blockMode == BlockMode.ALPHA) 
        ? 0.38 
        : 1.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Card(
        elevation: 0,
        color: colorScheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimen.radiusM),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _goTopicDetail(context, topic, ref),
          onLongPress: onLongPress,
          child: Opacity(
            opacity: alpha,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 标题
                  _buildTitle(
                    context,
                    topic,
                    topicSubject,
                    blockEnabled,
                    blockMode,
                    isTopicBlocked,
                    interfaceState,
                    textTheme,
                  ),
                  
                  // 父版块标签
                  if (topic.parent?.name?.isNotEmpty == true)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(Dimen.radiusFull),
                        ),
                        child: Text(
                          codeUtils.unescapeHtml(topic.parent!.name!),
                          style: textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSecondaryContainer,
                          ),
                        ),
                      ),
                    ),
                  
                  const SizedBox(height: 12),
                  
                  // 元信息行
                  _buildMetaRow(
                    context,
                    blockEnabled,
                    blockMode,
                    isTopicBlocked,
                    colorScheme,
                    textTheme,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool _isBlocked(BlocklistSettingsState blockState, String topicSubject) {
    return blockState.blockUserList.contains(topic.author) ||
        blockState.blockUserList.contains(topic.authorId) ||
        blockState.blockWordList
            .any((blockWord) => topicSubject.contains(blockWord));
  }

  Widget _buildCollapsedCard(BuildContext context, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Card(
        elevation: 0,
        color: colorScheme.surfaceContainerLow.withOpacity(0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimen.radiusM),
        ),
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: Text("折叠的屏蔽内容"),
        ),
      ),
    );
  }

  Widget _buildTitle(
    BuildContext context,
    Topic topic,
    String topicSubject,
    bool blockEnabled,
    BlockMode blockMode,
    bool isTopicBlocked,
    InterfaceSettingsState interfaceState,
    TextTheme textTheme,
  ) {
    final isPaintBlockMode =
        blockEnabled && isTopicBlocked && blockMode == BlockMode.PAINT;
    final isDeleteBlockMode =
        blockEnabled && isTopicBlocked && blockMode == BlockMode.DELETE_LINE;

    return RichText(
      text: TextSpan(
        text: topicSubject,
        style: textTheme.titleMedium?.copyWith(
          fontSize: Dimen.titleMedium * interfaceState.titleSizeMultiple,
          backgroundColor: isPaintBlockMode
              ? textTheme.bodyMedium?.color
              : null,
          color: isPaintBlockMode
              ? Colors.transparent
              : topic.getSubjectColor() ?? textTheme.bodyLarge?.color,
          fontWeight: topic.isBold() ? FontWeight.bold : FontWeight.normal,
          fontStyle: topic.isItalic() ? FontStyle.italic : FontStyle.normal,
          decoration: isDeleteBlockMode
              ? TextDecoration.lineThrough
              : topic.isUnderline()
                  ? TextDecoration.underline
                  : null,
          height: interfaceState.lineHeight.size,
        ),
        children: [
          if (topic.locked())
            TextSpan(
              text: " [锁定]",
              style: textTheme.labelMedium?.copyWith(
                color: Colors.red.shade300,
                fontWeight: FontWeight.normal,
              ),
            ),
          if (topic.isAssemble())
            TextSpan(
              text: " [合集]",
              style: textTheme.labelMedium?.copyWith(
                color: Colors.blue.shade300,
                fontWeight: FontWeight.normal,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMetaRow(
    BuildContext context,
    bool blockEnabled,
    BlockMode blockMode,
    bool isTopicBlocked,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    final isPaintBlockMode =
        blockEnabled && isTopicBlocked && blockMode == BlockMode.PAINT;

    return Row(
      children: [
        // 作者
        Icon(
          Icons.person_outline,
          size: 14,
          color: colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            topic.author ?? '',
            style: textTheme.bodySmall?.copyWith(
              color: isPaintBlockMode
                  ? Colors.transparent
                  : colorScheme.onSurfaceVariant,
              backgroundColor: isPaintBlockMode
                  ? colorScheme.onSurfaceVariant
                  : null,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        
        // 附件图标
        if (topic.hasAttachment()) ...[
          Icon(
            Icons.attach_file,
            size: 14,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 12),
        ],
        
        // 回复数
        Icon(
          Icons.chat_bubble_outline,
          size: 14,
          color: colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 4),
        Text(
          "${topic.replies}",
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        
        const SizedBox(width: 12),
        
        // 时间
        Icon(
          Icons.access_time,
          size: 14,
          color: colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 4),
        Text(
          codeUtils.formatPostDate(topic.lastPost! * 1000),
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  void _goTopicDetail(BuildContext context, Topic topic, WidgetRef ref) {
    ref.read(topicHistoryProvider.notifier).insertHistory(topic.createHistory());
    Routes.navigateTo(
      context,
      "${Routes.TOPIC_DETAIL}?tid=${topic.tid}&fid=${topic.fid}&subject=${topic.subject!}",
    );
  }
}
```

### 关键变更

1. **Card 包裹**：使用 `Card` 组件，应用 M3 圆角和表面色
2. **移除 Divider**：Card 之间通过 padding 分隔
3. **Chip 风格标签**：父版块使用 pill 形状的 Chip
4. **Material Symbols**：替换 CommunityMaterialIcons
5. **语义化颜色**：使用 ColorScheme 替代硬编码颜色

---

## 3.2 ForumGridItemWidget 重构

### 文件：`lib/ui/widget/forum_grid_item_widget.dart`

### 目标代码

```dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nga/data/entity/forum.dart';
import 'package:flutter_nga/utils/dimen.dart';
import 'package:flutter_nga/utils/route.dart';

class ForumGridItemWidget extends StatelessWidget {
  final Forum forum;
  final GestureLongPressCallback? onLongPress;

  const ForumGridItemWidget(this.forum, {Key? key, this.onLongPress})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimen.radiusM),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Routes.navigateTo(
          context,
          "${Routes.FORUM_DETAIL}?fid=${forum.fid}&name=${forum.name}&type=${forum.type}",
        ),
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 图标容器
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(Dimen.radiusS),
                ),
                clipBehavior: Clip.antiAlias,
                child: CachedNetworkImage(
                  imageUrl: forum.getIconUrl(),
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Icon(
                    Icons.forum_outlined,
                    color: colorScheme.onPrimaryContainer,
                    size: 24,
                  ),
                  errorWidget: (context, url, err) => Icon(
                    Icons.forum_outlined,
                    color: colorScheme.onPrimaryContainer,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // 名称
              Text(
                forum.name,
                style: textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

### 关键变更

1. **Card 包裹**：统一卡片样式
2. **图标容器**：使用 `primaryContainer` 背景
3. **移除 Image.asset**：使用 Material Icon 作为占位符
4. **圆角统一**：使用 `Dimen.radiusM` 和 `Dimen.radiusS`

---

## 3.3 Settings 页面列表项更新

### 文件：`lib/ui/page/settings/settings_page.dart`

### 目标代码

```dart
import 'package:flutter/material.dart';
import 'package:flutter_nga/providers/settings/theme_provider.dart';
import 'package:flutter_nga/ui/widget/theme_selection_dialog.dart';
import 'package:flutter_nga/utils/dimen.dart';
import 'package:flutter_nga/utils/route.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  ConsumerState<SettingsPage> createState() => _SettingsState();
}

class _SettingsState extends ConsumerState<SettingsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(themeProvider.notifier).refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text("设置")),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          _SettingsGroup(
            title: "账户",
            children: [
              _SettingsTile(
                icon: Icons.person_outline,
                title: "账号管理",
                subtitle: "管理您的账号",
                onTap: () => Routes.navigateTo(context, Routes.ACCOUNT_MANAGEMENT),
              ),
            ],
          ),
          _SettingsGroup(
            title: "外观",
            children: [
              _SettingsTile(
                icon: Icons.palette_outlined,
                title: "主题模式",
                subtitle: "当前: ${themeState.modeName}",
                onTap: _showThemeSelectionDialog,
              ),
              _SettingsTile(
                icon: Icons.text_fields,
                title: "界面设置",
                subtitle: "文字大小等界面元素",
                onTap: () => Routes.navigateTo(context, Routes.INTERFACE_SETTINGS),
              ),
            ],
          ),
          _SettingsGroup(
            title: "内容",
            children: [
              _SettingsTile(
                icon: Icons.block_outlined,
                title: "屏蔽设置",
                subtitle: "屏蔽用户、关键词",
                onTap: () => Routes.navigateTo(context, Routes.BLOCKLIST_SETTINGS),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showThemeSelectionDialog() {
    showDialog(
      context: context,
      builder: (_) => const ThemeSelectionDialog(),
    );
  }
}

/// 设置分组
class _SettingsGroup extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsGroup({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: textTheme.titleSmall?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ...children,
      ],
    );
  }
}

/// 设置项
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(Dimen.radiusM),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(Dimen.radiusM),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(Dimen.radiusS),
                  ),
                  child: Icon(
                    icon,
                    color: colorScheme.onPrimaryContainer,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                trailing ??
                    Icon(
                      Icons.chevron_right,
                      color: colorScheme.onSurfaceVariant,
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

### 关键变更

1. **分组结构**：使用 `_SettingsGroup` 组织设置项
2. **图标容器**：带背景色的图标
3. **圆角点击区域**：`InkWell` 配合 `borderRadius`
4. **语义化颜色**：ColorScheme

---

## 3.4 通用列表项组件

建议创建可复用的列表项组件供其他页面使用。

### 新文件：`lib/ui/widget/m3_list_tile.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_nga/utils/dimen.dart';

/// M3 风格的列表项
class M3ListTile extends StatelessWidget {
  final Widget? leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool selected;

  const M3ListTile({
    Key? key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.onLongPress,
    this.selected = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: selected ? colorScheme.secondaryContainer : Colors.transparent,
        borderRadius: BorderRadius.circular(Dimen.radiusM),
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(Dimen.radiusM),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                if (leading != null) ...[
                  leading!,
                  const SizedBox(width: 16),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: textTheme.bodyLarge?.copyWith(
                          color: selected
                              ? colorScheme.onSecondaryContainer
                              : colorScheme.onSurface,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style: textTheme.bodySmall?.copyWith(
                            color: selected
                                ? colorScheme.onSecondaryContainer.withOpacity(0.8)
                                : colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

---

## 验证清单

- [ ] TopicListItemWidget 卡片样式正确
- [ ] 屏蔽模式（折叠/透明/隐藏/涂抹/删除线）正常工作
- [ ] ForumGridItemWidget 在网格中正确显示
- [ ] 设置页面分组和图标显示正确
- [ ] 所有列表项点击反馈正常
- [ ] 深色主题下颜色正确
- [ ] `fvm flutter analyze` 无错误

## 回滚策略

如果出现严重问题：
1. 移除 Card 包裹，恢复原有结构
2. 保留 InkWell 点击逻辑

## 下一阶段

完成本阶段后，进入 [Phase 4: 对话框与表单组件翻新](./phase4-dialog-form-components.md)

---

*创建日期: 2026-01-18*
