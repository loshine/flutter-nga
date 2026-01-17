# Flutter NGA MobX → Riverpod + flutter_hooks 迁移计划

## 目录
- [1. Migration Strategy](#1-migration-strategy)
- [2. Dependency Changes](#2-dependency-changes)
- [3. Architecture Mapping](#3-architecture-mapping)
- [4. Phase-by-Phase Plan](#4-phase-by-phase-plan)
- [5. Per-Category Migration Details](#5-per-category-migration-details)
- [6. Risk Assessment](#6-risk-assessment)
- [7. Rollback Strategy](#7-rollback-strategy)
- [8. Success Criteria](#8-success-criteria)
- [9. Store Inventory](#9-store-inventory)
- [10. Test Plan](#10-test-plan)

---

## 1. Migration Strategy

**目标**：保持功能一致、逐步替换、可回滚，避免一次性大改。

**策略**：分阶段替换 Store 与 UI，先简单后复杂，先局部后全局，过程中双栈共存。

### 关键原则
- **KISS/YAGNI**：只实现现有功能，不引入新范式或新架构
- **依赖链推进**：最少依赖的 store 先动
- **UI 迁移滞后**：保证逻辑层稳定后再替换 Observer

### 风险控制
- 阶段性合并：每阶段可构建、可运行
- 保留 MobX store 一段时间，避免 UI 大范围同时改动

---

## 2. Dependency Changes

### pubspec.yaml 修改

**新增依赖：**
```yaml
dependencies:
  flutter_riverpod: ^2.4.9
  hooks_riverpod: ^2.4.9
  flutter_hooks: ^0.20.5
  riverpod_annotation: ^2.3.3

dev_dependencies:
  riverpod_generator: ^2.3.9
  build_runner: ^2.4.9  # 保留，用于 Riverpod 代码生成
  custom_lint: ^0.5.8
  riverpod_lint: ^2.3.7
```

**移除依赖（迁移完成后）：**
```yaml
# 移除
  mobx: ^2.5.0
  flutter_mobx: ^2.3.0
  
# dev_dependencies 移除
  mobx_codegen: ^2.6.1
```

**建议步骤：**
1. 先添加 Riverpod/hooks 依赖，保持 MobX 存在
2. 迁移完成后再移除 MobX 相关依赖
3. 删除所有 `.g.dart` 文件后重新生成

---

## 3. Architecture Mapping

### MobX → Riverpod 概念映射

| MobX | Riverpod | 说明 |
|------|----------|------|
| `@observable` 字段 | `state` in `Notifier` | 状态字段 |
| `@action` 方法 | `Notifier` 的普通方法 | 状态修改 |
| `@computed` | `Provider` 依赖另一个 Provider | 派生状态 |
| `ObservableList` | `List<T>` (不可变复制) | 列表状态 |
| `Observer` widget | `Consumer` / `HookConsumerWidget` | UI 订阅 |
| `Store` 实例 | `Provider` / `NotifierProvider` | 状态容器 |
| `reaction` / `autorun` | `ref.listen` / `ref.listenManual` | 副作用 |
| `Provider.of<T>(context)` | `ref.watch` / `ref.read` | 依赖注入 |

### 推荐 Provider 类型选择

| 场景 | 推荐 Provider 类型 |
|------|-------------------|
| 简单不可变值 | `Provider` |
| 简单可变值 | `StateProvider` |
| 带逻辑的同步状态 | `NotifierProvider` |
| 带逻辑的异步状态 | `AsyncNotifierProvider` |
| 一次性异步获取 | `FutureProvider` |
| 流数据 | `StreamProvider` |

### 代码生成模式（推荐）

使用 `@riverpod` 注解自动生成 Provider：

```dart
// 使用代码生成
@riverpod
class Counter extends _$Counter {
  @override
  int build() => 0;
  
  void increment() => state++;
}

// 自动生成 counterProvider
```

---

## 4. Phase-by-Phase Plan

### Phase 1: Infrastructure Setup (Day 1)

**目标**：建立 Riverpod 基础设施

**任务清单：**
- [ ] 添加 Riverpod 相关依赖到 pubspec.yaml
- [ ] 在 `main.dart` 用 `ProviderScope` 包裹 app
- [ ] 创建 `lib/providers/` 目录结构
- [ ] 封装基础 Provider：
  - `sharedPreferencesProvider` - SharedPreferences 实例
  - `databaseProvider` - Sembast Database 实例
  - `dioProvider` - Dio 实例
- [ ] 验证项目可编译运行

**目录结构：**
```
lib/
├── providers/
│   ├── core/
│   │   ├── shared_preferences_provider.dart
│   │   ├── database_provider.dart
│   │   └── dio_provider.dart
│   ├── settings/
│   ├── home/
│   ├── forum/
│   ├── topic/
│   ├── user/
│   ├── message/
│   ├── notification/
│   ├── search/
│   └── common/
```

**验收标准：**
- 项目可编译
- MobX 功能仍正常工作

---

### Phase 2: Simple Stores (Day 1-2)

**范围：**
- `home_store.dart` (15 lines)
- `home_drawer_header_store.dart` (27 lines)
- `photo_min_scale_store.dart` (21 lines)
- `topic_history_store.dart` (14 lines)
- `input_deletion_status_store.dart` (16 lines)

**迁移示例 - HomeStore：**

```dart
// 原 MobX (home_store.dart)
class HomeStore = _HomeStore with _$HomeStore;
abstract class _HomeStore with Store {
  @observable
  var index = 0;

  @action
  void setIndex(int index) {
    this.index = index;
  }
}

// 新 Riverpod (providers/home/home_provider.dart)
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'home_provider.g.dart';

@riverpod
class HomeIndex extends _$HomeIndex {
  @override
  int build() => 0;
  
  void setIndex(int index) => state = index;
}
```

**UI 迁移示例：**

```dart
// 原 MobX
class _HomePageState extends State<_HomePage> {
  final _store = HomeStore();
  
  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) => Text(_store.index.toString()),
    );
  }
}

// 新 Riverpod + Hooks
class HomePage extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(homeIndexProvider);
    return Text(index.toString());
  }
}
```

**验收标准：**
- 首页导航切换正常
- 抽屉头部显示正常
- 图片缩放功能正常

---

### Phase 3: Settings Stores (Day 2-3)

**范围：**
- `theme_store.dart` (36 lines)
- `display_mode_store.dart` (76 lines)
- `interface_settings_store.dart` (120 lines)
- `blocklist_settings_store.dart` (244 lines) - 最复杂

**持久化模式示例：**

```dart
// providers/settings/interface_settings_provider.dart
@riverpod
class InterfaceSettings extends _$InterfaceSettings {
  static const _prefsName = 'ui';
  
  @override
  Future<InterfaceSettingsState> build() async {
    final prefs = await ref.watch(sharedPreferencesProvider.future);
    return InterfaceSettingsState(
      contentSizeMultiple: prefs.getDouble('${_prefsName}_contentSizeMultiple') ?? 1.0,
      titleSizeMultiple: prefs.getDouble('${_prefsName}_titleSizeMultiple') ?? 1.0,
      lineHeight: _getLineHeight(prefs),
    );
  }
  
  Future<void> setContentSizeMultiple(double multiple) async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    await prefs.setDouble('${_prefsName}_contentSizeMultiple', multiple);
    state = AsyncData(state.value!.copyWith(contentSizeMultiple: multiple));
  }
}

@freezed
class InterfaceSettingsState with _$InterfaceSettingsState {
  const factory InterfaceSettingsState({
    required double contentSizeMultiple,
    required double titleSizeMultiple,
    required CustomLineHeight lineHeight,
  }) = _InterfaceSettingsState;
}
```

**定时任务迁移（BlocklistSettings）：**

```dart
@riverpod
class BlocklistSettings extends _$BlocklistSettings {
  Timer? _syncTimer;
  
  @override
  Future<BlocklistState> build() async {
    // 启动定时同步
    _startPeriodicSync();
    
    // 清理定时器
    ref.onDispose(() => _syncTimer?.cancel());
    
    return _loadFromPrefs();
  }
  
  void _startPeriodicSync() {
    _syncTimer = Timer.periodic(Duration(minutes: 5), (_) => load());
  }
}
```

**验收标准：**
- 主题切换持久化正常
- 字体大小设置持久化正常
- 屏蔽列表同步正常
- App 重启后设置保持

---

### Phase 4: List/Pagination Stores (Day 3-5)

**范围：**
- `forum_detail_store.dart` (81 lines)
- `favourite_forum_list_store.dart` (39 lines)
- `favourite_forum_store.dart` (33 lines)
- `forum_tag_list_store.dart` (27 lines)
- `child_forum_subscription_store.dart` (41 lines)
- `topic_history_list_store.dart` (118 lines)
- `topic_reply_store.dart` (61 lines)
- `favourite_topic_list_store.dart` (92 lines)
- `search_topic_list_store.dart` (70 lines)
- `search_options_store.dart` (66 lines)
- `search_forum_store.dart` (19 lines)

**分页状态模式：**

```dart
// 通用分页状态
@freezed
class PagedState<T> with _$PagedState<T> {
  const factory PagedState({
    @Default([]) List<T> items,
    @Default(1) int page,
    @Default(1) int maxPage,
    @Default(false) bool isLoading,
    @Default(false) bool hasError,
    String? errorMessage,
  }) = _PagedState<T>;
  
  bool get canLoadMore => page < maxPage && !isLoading;
}
```

**ForumDetail 迁移示例：**

```dart
// providers/forum/forum_detail_provider.dart
@riverpod
class ForumDetail extends _$ForumDetail {
  @override
  PagedState<Topic> build(int fid, {bool recommend = false, int? type}) {
    return const PagedState();
  }
  
  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, hasError: false);
    try {
      final data = await ref.read(topicRepositoryProvider)
          .getTopicList(fid: fid, page: 1, recommend: recommend, type: type);
      state = PagedState(
        items: data.topicList.values.toList(),
        page: 1,
        maxPage: data.maxPage,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, hasError: true, errorMessage: e.toString());
      rethrow;
    }
  }
  
  Future<void> loadMore() async {
    if (!state.canLoadMore) return;
    state = state.copyWith(isLoading: true);
    try {
      final data = await ref.read(topicRepositoryProvider)
          .getTopicList(fid: fid, page: state.page + 1, recommend: recommend, type: type);
      state = state.copyWith(
        items: [...state.items, ...data.topicList.values],
        page: state.page + 1,
        maxPage: data.maxPage,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, hasError: true);
      rethrow;
    }
  }
}
```

**验收标准：**
- 版块列表加载、分页正常
- 收藏版块显示正常
- 搜索功能正常
- 历史记录加载正常

---

### Phase 5: Complex Stores (Day 5-7)

**范围：**
- `topic_detail_store.dart` (51 lines)
- `topic_single_page_store.dart` (98 lines)
- `user_info_store.dart` (132 lines)
- `user_topics_store.dart` (74 lines)
- `user_replies_store.dart` (68 lines)
- `conversation_list_store.dart` (63 lines)
- `conversation_detail_store.dart` (66 lines)
- `send_message_store.dart` (39 lines)
- `notification_list_store.dart` (36 lines)
- `account_list_store.dart` (33 lines)

**TopicSinglePage 迁移示例（多 API 聚合）：**

```dart
@riverpod
class TopicSinglePage extends _$TopicSinglePage {
  @override
  FutureOr<TopicSinglePageState> build(int tid, int page, {int? authorId}) {
    return TopicSinglePageState.initial();
  }
  
  Future<void> refresh() async {
    state = const AsyncLoading();
    try {
      final data = await ref.read(topicRepositoryProvider)
          .getTopicDetail(tid, page, authorId);
      
      // 处理热门回复
      List<Reply> hotReplies = [];
      if (page == 1 && data.hotReplies.isNotEmpty && authorId == null) {
        final hots = await Future.wait(
          data.hotReplies.map((e) => 
            ref.read(topicRepositoryProvider).getTopicReplies(e))
        );
        for (final hot in hots) {
          hotReplies.addAll(hot.replyList.values);
        }
      }
      
      state = AsyncData(TopicSinglePageState(
        topic: data.topic,
        replyList: data.replyList.values.toList(),
        hotReplyList: hotReplies,
        userList: data.userList.values.toList(),
        // ... 其他字段
      ));
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
```

**验收标准：**
- 帖子详情加载正常
- 用户信息页正常
- 私信收发正常
- 通知列表正常

---

### Phase 6: UI Migration (Day 7-9)

**目标**：将所有 Observer widget 替换为 Consumer/HookConsumerWidget

**迁移清单（35+ 处）：**

| 文件 | Observer 位置 |
|------|--------------|
| `interface_settings_page.dart` | body |
| `blocklist_users_page.dart` | body |
| `blocklist_keywords_page.dart` | body |
| `blocklist_settings_page.dart` | body |
| `settings_page.dart` | subtitle |
| `home_page.dart` | build return |
| `home_drawer.dart` | child |
| `account_management_page.dart` | child |
| `favourite_forum_group_page.dart` | return |
| `notification_list_page.dart` | return |
| `send_message_page.dart` | child |
| `search_forum_page.dart` | body |
| `search_page.dart` | suffixIcon, body |
| `search_topic_list_page.dart` | body |
| `photo_preview_page.dart` | body |
| `favourite_topic_list_page.dart` | return |
| `reply_detail_dialog.dart` | content |
| `topic_detail_page.dart` | return |
| `topic_single_page.dart` | return |
| `forum_tag_dialog.dart` | content |
| `topic_history_list_page.dart` | return |
| `forum_favourite_button_widget.dart` | return |
| `child_forum_item_widget.dart` | 条件 |
| `forum_recommend_topic_list_page.dart` | return |
| `forum_detail_page.dart` | body |
| `user_topics_page.dart` | body |
| `user_replies_page.dart` | body |
| `user_info_page.dart` | body |
| `conversation_list_page.dart` | return |
| `conversation_detail_page.dart` | body |
| `block_mode_selection_dialog.dart` | child |
| `theme_selection_dialog.dart` | child |
| `line_height_selection_dialog.dart` | child |

**flutter_hooks 使用示例：**

```dart
class ForumDetailPage extends HookConsumerWidget {
  final int fid;
  final String? name;
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 使用 hooks 管理控制器
    final refreshController = useMemoized(() => RefreshController(initialRefresh: true));
    final tabController = useTabController(initialLength: 3);
    
    // 清理
    useEffect(() {
      return () {
        refreshController.dispose();
      };
    }, []);
    
    // 监听状态
    final state = ref.watch(forumDetailProvider(fid));
    
    return Scaffold(
      body: SmartRefresher(
        controller: refreshController,
        onRefresh: () => ref.read(forumDetailProvider(fid).notifier).refresh(),
        child: ListView.builder(
          itemCount: state.items.length,
          itemBuilder: (_, i) => TopicListItemWidget(topic: state.items[i]),
        ),
      ),
    );
  }
}
```

**验收标准：**
- 所有页面 UI 行为一致
- 无 Provider 未找到异常
- 无异常重建

---

### Phase 7: Cleanup and Testing (Day 9-10)

**任务清单：**
- [ ] 删除所有 MobX store 文件
- [ ] 删除所有 `.g.dart` 生成文件
- [ ] 从 pubspec.yaml 移除 MobX 依赖
- [ ] 运行 `flutter pub get`
- [ ] 运行 `dart run build_runner build --delete-conflicting-outputs`
- [ ] 全量回归测试
- [ ] 性能测试（rebuild 次数）

---

## 5. Per-Category Migration Details

### Settings 类
- **迁移重心**：持久化 + 定时任务
- **典型风险**：同步循环漏取消
- **建议**：在 Provider 里管理 Timer 生命周期，使用 `ref.onDispose`

### Home/Common 类
- **迁移重心**：简单状态替换
- **风险**：低，可作为模板

### Forum/Topic/Search 类
- **迁移重心**：分页/缓存/数据库
- **重点**：不可变 state + 幂等加载

### User/Message/Notification 类
- **迁移重心**：多 API 调用、合成状态
- **重点**：错误处理与并发控制

---

## 6. Risk Assessment

| 风险 | 说明 | 应对措施 |
|------|------|----------|
| 状态丢失 | Provider 生命周期不一致 | 谨慎使用 `autoDispose`，必要时使用 `keepAlive` |
| 频繁重建 | watch 粒度太粗 | 切分 Provider，使用 `select` |
| 共享依赖变更 | Repository/Provider 拆分不一致 | 提前抽象 Repository 层 |
| 数据库/持久化回归 | Store 逻辑改变 | 回归测试 + mock |
| 定时任务泄露 | Timer 未正确取消 | 使用 `ref.onDispose` |
| 并发状态覆盖 | 多个请求同时修改状态 | 使用 loading flag 防止重复请求 |

---

## 7. Rollback Strategy

1. **阶段性保留**：每阶段保留 MobX store 与 Riverpod 并存
2. **Feature Flag**：UI 切换采用 feature flag 或路由级分支
3. **快速回滚**：如失败，切回 MobX store 与 Observer
4. **代码保留**：不删除 MobX 代码直到全量通过验收

**Git 分支策略：**
```
main
├── feature/riverpod-phase1
├── feature/riverpod-phase2
├── ...
└── feature/riverpod-complete
```

---

## 8. Success Criteria

### Functional
- [ ] 所有页面功能一致（列表加载、收藏、设置、消息等）
- [ ] 所有状态读写正常
- [ ] 持久化数据正确

### Observable
- [ ] 无崩溃
- [ ] 无重复请求
- [ ] 无 UI 空状态异常
- [ ] 日志无报错（Provider 未找到、监听泄露）

### Pass/Fail
- [ ] App 能完整运行主要流程
- [ ] 所有回归测试通过
- [ ] 迁移后无 MobX 依赖残留
- [ ] `flutter analyze` 无错误

---

## 9. Store Inventory

### 完整 Store 清单（30个）

| 分类 | 文件 | 行数 | 复杂度 | 优先级 |
|------|------|------|--------|--------|
| **Home** | home_store.dart | 15 | 简单 | P1 |
| | home_drawer_header_store.dart | 27 | 简单 | P1 |
| **Common** | photo_min_scale_store.dart | 21 | 简单 | P1 |
| **Topic** | topic_history_store.dart | 14 | 简单 | P1 |
| **Search** | input_deletion_status_store.dart | 16 | 简单 | P1 |
| | search_forum_store.dart | 19 | 简单 | P2 |
| **Settings** | theme_store.dart | 36 | 中等 | P2 |
| | display_mode_store.dart | 76 | 中等 | P2 |
| | interface_settings_store.dart | 120 | 复杂 | P2 |
| | blocklist_settings_store.dart | 244 | 复杂 | P2 |
| **Forum** | forum_tag_list_store.dart | 27 | 简单 | P3 |
| | favourite_forum_store.dart | 33 | 简单 | P3 |
| | favourite_forum_list_store.dart | 39 | 中等 | P3 |
| | child_forum_subscription_store.dart | 41 | 中等 | P3 |
| | forum_detail_store.dart | 81 | 复杂 | P3 |
| **Notification** | notification_list_store.dart | 36 | 中等 | P4 |
| **Message** | send_message_store.dart | 39 | 中等 | P4 |
| | conversation_list_store.dart | 63 | 中等 | P4 |
| | conversation_detail_store.dart | 66 | 中等 | P4 |
| **User** | account_list_store.dart | 33 | 中等 | P4 |
| | user_replies_store.dart | 68 | 中等 | P4 |
| | user_topics_store.dart | 74 | 中等 | P4 |
| | user_info_store.dart | 132 | 复杂 | P4 |
| **Topic** | topic_detail_store.dart | 51 | 中等 | P4 |
| | topic_reply_store.dart | 61 | 中等 | P4 |
| | favourite_topic_list_store.dart | 92 | 复杂 | P4 |
| | topic_single_page_store.dart | 98 | 复杂 | P4 |
| | topic_history_list_store.dart | 118 | 复杂 | P4 |
| **Search** | search_options_store.dart | 66 | 中等 | P3 |
| | search_topic_list_store.dart | 70 | 中等 | P3 |

---

## 10. Test Plan

### Objective
验证 Riverpod 迁移后核心功能一致性与稳定性。

### Prerequisites
- Build 成功
- API/本地数据库可用
- 已登录测试账号

### Test Cases

| ID | 测试场景 | 操作步骤 | 预期结果 |
|----|----------|----------|----------|
| T1 | Settings 持久化 | 修改主题 → 重启 App | 主题保持修改后的值 |
| T2 | 字体大小设置 | 修改字体大小 → 重启 | 字体大小保持 |
| T3 | 屏蔽列表同步 | 添加屏蔽用户 → 等待5分钟 | 列表自动同步 |
| T4 | 版块列表分页 | 打开版块 → 下拉刷新 → 上拉加载 | 分页正常，数据递增 |
| T5 | 收藏版块 | 收藏/取消收藏版块 | 状态正确更新 |
| T6 | 帖子详情 | 打开帖子 → 翻页 | 内容和回复正常加载 |
| T7 | 用户信息 | 打开用户页 | 头像、帖子列表正常 |
| T8 | 发送私信 | 发送消息 | 发送成功，列表更新 |
| T9 | 搜索功能 | 输入关键词搜索 | 结果列表正常显示 |
| T10 | 浏览历史 | 查看帖子后检查历史 | 历史记录正确添加 |
| T11 | 通知列表 | 打开通知页 | 通知正常加载 |
| T12 | 登录/登出 | 切换账号 | 状态正确切换 |

### Success Criteria
所有测试用例通过。

### How to Execute
1. 运行 App（debug/release 均可）
2. 手动执行上述测试用例
3. 观察日志与 UI 行为
4. 记录任何异常

---

## Effort Estimate

| 阶段 | 预估时间 | 复杂度 |
|------|----------|--------|
| Phase 1: Infrastructure | 0.5 天 | 低 |
| Phase 2: Simple Stores | 0.5 天 | 低 |
| Phase 3: Settings Stores | 1 天 | 中 |
| Phase 4: List Stores | 2 天 | 高 |
| Phase 5: Complex Stores | 2 天 | 高 |
| Phase 6: UI Migration | 2 天 | 中 |
| Phase 7: Cleanup | 1 天 | 低 |
| **总计** | **9-10 天** | - |

---

## 附录：常用 Hooks

| Hook | 用途 | 替代 |
|------|------|------|
| `useState` | 局部状态 | `setState` |
| `useEffect` | 副作用 | `initState` / `dispose` |
| `useMemoized` | 缓存计算结果 | 手动缓存 |
| `useCallback` | 缓存回调 | 手动缓存 |
| `useRef` | 可变引用 | 实例变量 |
| `useTextEditingController` | 文本控制器 | 手动创建/销毁 |
| `useTabController` | Tab 控制器 | SingleTickerProviderStateMixin |
| `useAnimationController` | 动画控制器 | SingleTickerProviderStateMixin |
| `useScrollController` | 滚动控制器 | 手动创建/销毁 |

---

*文档生成时间：2026-01-17*
*项目：flutter_nga*
*迁移目标：MobX → Riverpod + flutter_hooks*
