# Phase 2: 导航组件样式翻新

> 目标：将 Drawer、AppBar、FAB 等导航组件升级为 M3 Expressive 风格

## 概述

本阶段主要完成：

1. Drawer 样式翻新为 M3 风格（28dp 圆角导航项、secondaryContainer 选中色）
2. 更新 AppBar 为 M3 风格
3. 更新 FloatingActionButton 样式

**注意**：本阶段采用自定义 `_NavigationItem` 组件实现 M3 导航项样式，而非官方 `NavigationDrawer` 组件，以保持更灵活的布局控制。

## 前置条件

- Phase 1 已完成（`useMaterial3: true` 已启用）

## 改动文件清单

| 文件                                | 改动类型 | 优先级 |
| ----------------------------------- | -------- | ------ |
| `lib/ui/page/home/home_page.dart`   | 重构     | P0     |
| `lib/ui/page/home/home_drawer.dart` | 重构     | P0     |

---

## 2.1 Drawer 样式翻新

### 文件：`lib/ui/page/home/home_drawer.dart`

### 当前代码问题

```dart
// 当前使用手动构建的 ListTile
Material(
  child: InkWell(
    child: ListTile(
      leading: Icon(CommunityMaterialIcons.view_dashboard),
      title: Text("论坛"),
      selected: currentSelection == 0,
      selectedTileColor: Palette.getColorDrawerListTileBackground(context),
    ),
    onTap: () => onSelectedCallback?.call(0),
  ),
  color: Theme.of(context).scaffoldBackgroundColor,
),
```

### 目标代码 - HomeDrawerHeader

使用 `Container` + `MediaQuery.padding.top` 处理安全区，实现更精确的布局控制：

```dart
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_nga/providers/home/home_drawer_header_provider.dart';
import 'package:flutter_nga/ui/widget/avatar_widget.dart';
import 'package:flutter_nga/utils/route.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class HomeDrawerHeader extends HookConsumerWidget {
  const HomeDrawerHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userInfo = ref.watch(homeDrawerHeaderProvider);
    final colorScheme = Theme.of(context).colorScheme;

    useEffect(() {
      Future.microtask(() {
        ref.read(homeDrawerHeaderProvider.notifier).refresh();
      });
      return null;
    }, []);

    final paddingTop = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
      ),
      padding: EdgeInsets.fromLTRB(16, 16 + paddingTop, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => _maybeGoLogin(context, userInfo != null),
            borderRadius: BorderRadius.circular(28),
            child: AvatarWidget(
              userInfo != null ? userInfo.avatar : "",
              size: 56,
              username: userInfo != null ? userInfo.username : "",
            ),
          ),
          const SizedBox(height: 16),
          Text(
            userInfo != null ? userInfo.username! : "点击登录",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: colorScheme.onPrimaryContainer,
            ),
          ),
          if (userInfo != null)
            Text(
              "UID: ${userInfo.uid}",
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onPrimaryContainer.withOpacity(0.7),
              ),
            ),
        ],
      ),
    );
  }

  void _maybeGoLogin(BuildContext context, bool isLoggedIn) async {
    if (isLoggedIn) return;
    Routes.pop(context);
    Routes.navigateTo(context, Routes.LOGIN);
  }
}
```

### 目标代码 - HomeDrawerBody

```dart
class HomeDrawerBody extends StatelessWidget {
  final int? currentSelection;
  final Function(int)? onSelectedCallback;

  const HomeDrawerBody({
    Key? key,
    this.currentSelection,
    this.onSelectedCallback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Expanded(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 16, 16, 8),
            child: Text(
              "模块",
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),

          _NavigationItem(
            icon: Icons.dashboard_outlined,
            selectedIcon: Icons.dashboard,
            label: "论坛",
            selected: currentSelection == 0,
            onTap: () => onSelectedCallback?.call(0),
          ),
          _NavigationItem(
            icon: Icons.bookmark_outline,
            selectedIcon: Icons.bookmark,
            label: "贴子收藏",
            selected: currentSelection == 1,
            onTap: () => onSelectedCallback?.call(1),
          ),
          _NavigationItem(
            icon: Icons.history_outlined,
            selectedIcon: Icons.history,
            label: "浏览历史",
            selected: currentSelection == 2,
            onTap: () => onSelectedCallback?.call(2),
          ),
          _NavigationItem(
            icon: Icons.mail_outlined,
            selectedIcon: Icons.mail,
            label: "短消息",
            selected: currentSelection == 3,
            onTap: () => onSelectedCallback?.call(3),
          ),
          _NavigationItem(
            icon: Icons.notifications_outlined,
            selectedIcon: Icons.notifications,
            label: "提醒信息",
            selected: currentSelection == 4,
            onTap: () => onSelectedCallback?.call(4),
          ),

          const Divider(indent: 28, endIndent: 28),

          Padding(
            padding: const EdgeInsets.fromLTRB(28, 16, 16, 8),
            child: Text(
              "其它",
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),

          _NavigationItem(
            icon: Icons.settings_outlined,
            selectedIcon: Icons.settings,
            label: "设置",
            selected: false,
            onTap: () => Routes.navigateTo(context, Routes.SETTINGS),
          ),
          _NavigationItem(
            icon: Icons.info_outline,
            selectedIcon: Icons.info,
            label: "关于",
            selected: false,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

/// M3 风格的导航项（28dp 圆角 pill 形状）
class _NavigationItem extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  const _NavigationItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: selected ? colorScheme.secondaryContainer : Colors.transparent,
        borderRadius: BorderRadius.circular(28),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(28),
          child: Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(
                  selected ? selectedIcon : icon,
                  color: selected
                    ? colorScheme.onSecondaryContainer
                    : colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: selected
                        ? colorScheme.onSecondaryContainer
                        : colorScheme.onSurfaceVariant,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
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

### 实施步骤

1. 创建 `_NavigationItem` 私有组件，实现 M3 导航项样式
2. 使用 `Container` + `MediaQuery.padding.top` 处理安全区（而非 DrawerHeader）
3. 使用 Material 图标的 outlined/filled 变体
4. 应用 `secondaryContainer` 作为选中背景
5. 使用 28dp 圆角（M3 pill shape）
6. 移除 `CommunityMaterialIcons`，改用 Material Symbols

---

## 2.2 AppBar 更新

### 文件：`lib/ui/page/home/home_page.dart`

### 当前代码问题

```dart
AppBar(
  elevation: _getElevation(index),  // 硬编码 elevation
  title: Text(_getTitleText(index)),
  actions: _getActionsByPage(context, index),
),
```

### 目标代码

```dart
AppBar(
  title: Text(_getTitleText(index)),
  scrolledUnderElevation: index == 0 ? 0 : 2,  // M3 滚动时显示 elevation
  actions: _getActionsByPage(context, index),
),
```

### 变更说明

M3 AppBar 特性：

- 默认无 elevation，滚动时通过 `scrolledUnderElevation` 显示阴影
- 背景色自动使用 `colorScheme.surface`
- 前景色自动使用 `colorScheme.onSurface`
- 标题默认居中（已在 Phase 1 ThemeData 中配置）

---

## 2.3 FloatingActionButton 更新

### 文件：`lib/ui/page/home/home_page.dart`

### 当前代码问题

```dart
FloatingActionButton(
  tooltip: '添加自定义版面',
  onPressed: () => showDialog(...),
  child: Icon(
    CommunityMaterialIcons.plus,
    color: Colors.white,  // 硬编码颜色
  ),
),
```

### 目标代码

FAB 需要与 `forumGroupFabVisibleProvider` 集成，仅在"我的收藏" tab 显示：

```dart
Widget? _getFloatingActionButton(
    BuildContext context, WidgetRef ref, int index) {
  if (index == 0) {
    final fabVisible = ref.watch(forumGroupFabVisibleProvider);
    if (!fabVisible) return null;
    return FloatingActionButton(
      tooltip: '添加自定义版面',
      onPressed: () => showDialog(
        context: context,
        builder: (_) => const CustomForumDialog(),
      ),
      child: const Icon(Icons.add),
    );
  } else if (index == 3) {
    return FloatingActionButton(
      tooltip: '新建短消息',
      onPressed: () =>
          Routes.navigateTo(context, "${Routes.SEND_MESSAGE}?mid=0"),
      child: const Icon(Icons.edit_outlined),
    );
  }
  return null;
}
```

### 变更说明

M3 FAB 特性：

- 使用 `primaryContainer` / `onPrimaryContainer` 颜色
- 圆角 16dp（已在 Phase 1 ThemeData 中配置）
- 移除硬编码 `Colors.white`，让主题控制
- 与 `forumGroupFabVisibleProvider` 集成，仅在正确 tab 显示

---

## 2.4 WillPopScope → PopScope 迁移

### 文件：`lib/ui/page/home/home_page.dart`

### 当前代码问题

```dart
return WillPopScope(
  child: Scaffold(...),
  onWillPop: () async {
    if (scaffoldKey.currentState!.isDrawerOpen || index == 0) {
      return true;
    } else {
      ref.read(homeIndexProvider.notifier).setIndex(0);
      return false;
    }
  },
);
```

### 目标代码

```dart
return PopScope(
  canPop: false,
  onPopInvokedWithResult: (didPop, result) {
    if (didPop) return;

    if (_scaffoldKey.currentState?.isDrawerOpen == true) {
      Navigator.of(context).pop();
      return;
    }

    if (index != 0) {
      ref.read(homeIndexProvider.notifier).setIndex(0);
      return;
    }

    Navigator.of(context).pop();
  },
  child: Scaffold(...),
);
```

### 变更说明

- `WillPopScope` 在 Flutter 3.12 废弃
- `PopScope` 提供更精细的控制
- `canPop: false` 拦截所有返回操作
- `onPopInvokedWithResult` 处理返回逻辑

---

## 2.5 完整的 home_page.dart 重构

### 关键修复

**GlobalKey 必须声明为类字段**，避免在 build 方法中重建导致状态丢失：

```dart
class _HomePageContent extends HookConsumerWidget {
  const _HomePageContent();

  // GlobalKey 声明为 static final，避免重建
  static final GlobalKey<TopicHistoryListPageState> _historyStateKey =
      GlobalKey<TopicHistoryListPageState>();
  static final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>();

  // ... 其他代码
}
```

### 目标代码

```dart
import 'package:flutter/material.dart';
import 'package:flutter_nga/providers/home/home_provider.dart';
import 'package:flutter_nga/providers/settings/blocklist_settings_provider.dart';
import 'package:flutter_nga/providers/settings/interface_settings_provider.dart';
import 'package:flutter_nga/ui/page/conversation/conversation_list_page.dart';
import 'package:flutter_nga/ui/page/favourite_topic_list/favourite_topic_list_page.dart';
import 'package:flutter_nga/ui/page/forum_group/forum_group_tabs.dart';
import 'package:flutter_nga/ui/page/history/topic_history_list_page.dart';
import 'package:flutter_nga/ui/page/home/home_drawer.dart';
import 'package:flutter_nga/ui/page/notification/notification_list_page.dart';
import 'package:flutter_nga/ui/widget/custom_forum_dialog.dart';
import 'package:flutter_nga/utils/route.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class HomePage extends HookConsumerWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(blocklistSettingsProvider.notifier).init();
      ref.read(blocklistSettingsProvider.notifier).loopSyncBlockList();
      ref.read(interfaceSettingsProvider.notifier).init();
    });
    return const _HomePageContent();
  }
}

class _HomePageContent extends HookConsumerWidget {
  const _HomePageContent();

  static final GlobalKey<TopicHistoryListPageState> _historyStateKey =
      GlobalKey<TopicHistoryListPageState>();
  static final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>();

  List<Widget> _buildPageList() {
    return [
      const ForumGroupTabsPage(),
      const FavouriteTopicListPage(),
      TopicHistoryListPage(key: _historyStateKey),
      const ConversationListPage(),
      const NotificationListPage(),
    ];
  }

  String _getTitleText(int index) {
    const titles = ['NGA', '贴子收藏', '浏览历史', '短消息', '提醒信息'];
    return titles.elementAtOrNull(index) ?? '';
  }

  List<Widget> _getActionsByPage(BuildContext context, int index) {
    return switch (index) {
      0 => [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => Routes.navigateTo(context, Routes.SEARCH),
          ),
        ],
      2 => [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _historyStateKey.currentState?.showCleanDialog(),
          ),
        ],
      _ => [],
    };
  }

  Widget? _getFloatingActionButton(
      BuildContext context, WidgetRef ref, int index) {
    if (index == 0) {
      final fabVisible = ref.watch(forumGroupFabVisibleProvider);
      if (!fabVisible) return null;
      return FloatingActionButton(
        tooltip: '添加自定义版面',
        onPressed: () => showDialog(
          context: context,
          builder: (_) => const CustomForumDialog(),
        ),
        child: const Icon(Icons.add),
      );
    } else if (index == 3) {
      return FloatingActionButton(
        tooltip: '新建短消息',
        onPressed: () =>
            Routes.navigateTo(context, "${Routes.SEND_MESSAGE}?mid=0"),
        child: const Icon(Icons.edit_outlined),
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(homeIndexProvider);
    final pageList = _buildPageList();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        if (_scaffoldKey.currentState?.isDrawerOpen == true) {
          Navigator.of(context).pop();
          return;
        }

        if (index != 0) {
          ref.read(homeIndexProvider.notifier).setIndex(0);
          return;
        }

        Navigator.of(context).pop();
      },
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(_getTitleText(index)),
          scrolledUnderElevation: index == 0 ? 0 : 2,
          actions: _getActionsByPage(context, index),
        ),
        drawer: Drawer(
          child: Column(
            children: [
              const HomeDrawerHeader(),
              HomeDrawerBody(
                currentSelection: index,
                onSelectedCallback: (i) {
                  Routes.pop(context);
                  ref.read(homeIndexProvider.notifier).setIndex(i);
                },
              ),
            ],
          ),
        ),
        body: pageList[index],
        floatingActionButton: _getFloatingActionButton(context, ref, index),
      ),
    );
  }
}
```

---

## 验证清单

- [ ] Drawer 打开/关闭动画流畅
- [ ] 导航项选中状态正确显示
- [ ] 导航项点击反馈（ripple）正常
- [ ] AppBar 滚动时 elevation 变化正确
- [ ] FAB 仅在"我的收藏" tab 显示（index == 0 且 fabVisible）
- [ ] FAB 点击和悬停状态正常
- [ ] 返回键行为正确（先回到首页，再退出）
- [ ] Tab 切换状态正确保持（GlobalKey 不重建）
- [ ] 深色主题下颜色正确
- [ ] `fvm flutter analyze` 无错误

## 回滚策略

如果出现严重问题：

1. 恢复 `WillPopScope` 使用
2. 保留旧的 ListTile 实现

## 下一阶段

完成本阶段后，进入 [Phase 3: 列表与卡片组件翻新](./phase3-list-card-components.md)

---

_更新日期: 2026-01-18_
