# Material You (M3) UI/UX 优化方案与推进清单

> 基于项目当前代码现状（Flutter 3.50 / `material_ui`），对照 Material You（Material 3 / M3 Adaptive / M3 Expressive）设计规范梳理出的优化项与分步落地计划。每完成一项提交一个独立 commit。

## 推进清单

### P0：核心规范补齐与高收益修复

- [x] **P0-1 Android 原生预测性返回手势（Predictive Back）**
  - 在 `android/app/src/main/AndroidManifest.xml` 的 `<application>` 启用 `android:enableOnBackInvokedCallback="true"`，使 `ThemeBuilder` 中已配置的 `PredictiveBackPageTransitionsBuilder` 在 Android 13–15 上真正生效。

- [x] **P0-2 系统动态取色、默认跟随系统与高对比度主题**
  - 通过原生 `MethodChannel` 读取 Android 12+ 系统壁纸动态主色（`system_accent1_500`）与 macOS 系统强调色（`controlAccentColor`），零外部插件依赖、兼容 AGP 9 与 SPM。
  - 在 `PrefsKeys` 新增 `useDynamicColor`，支持在主题设置中开启/关闭动态配色。
  - 首次安装默认主题模式改为 `AdaptiveThemeMode.system`（跟随系统深浅色），保留已保存的用户设置。
  - 优化 `ThemeBuilder`：经典棕色主题保持暗金辅色，动态配色与其他种子色保留 M3 原生和谐 `secondary` 色阶；新增 `buildHighContrastLightTheme` / `buildHighContrastDarkTheme`（`contrastLevel: 1.0`）并接入 `MaterialApp.router`。

- [x] **P0-3 首页导航栏未读角标、大屏展开态与 TabBar 层级整理**
  - `NavigationBarThemeData` 背景色改为 `colorScheme.surfaceContainer`，与正文 `surface` 形成清晰色调分离。
  - 首页底部 `NavigationBar` 与侧边 `NavigationRail` 的「我的」目的地增加聚合未读 `Badge.count`，并在首页启动/账号切换时同步刷新未读数。
  - 宽屏（≥ 840dp，M3 Expanded 断点）支持 `NavigationRail(extended: true)` 并将 FAB 放入 `NavigationRail.leading`。
  - 去除 `ForumGroupTabsPage` 内部冗余的嵌套 `AppBar`，改为 `Material` + `TabBar(tabAlignment: TabAlignment.start)`；`ForumDetailPage` 的 `TabBar` 同步简化为 `tabAlignment: TabAlignment.start`。

- [x] **P0-4 版块网格自适应列数与补齐页面阅读宽度约束**
  - `FavouriteForumGroupPage` 与 `ForumCategoryPage` 改用 `SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 120, mainAxisExtent: 108)`，解决宽屏/横屏下固定 3 列严重拉伸的问题，并保留底部安全区。
  - 为 `MinePage` 与 `SendMessagePage` 补齐 `ReadableListPadding` 居中阅读宽度约束。

- [x] **P0-5 屏蔽列表与浏览历史支持左滑删除与 SnackBar 撤销**
  - `BlocklistUsersPage` 与 `BlocklistKeywordsPage` 移除点击整行直接删除的误触隐患，改为左滑 `Dismissible`（带阈值触感）+ 行尾 `IconButton` + `AppSnackBar.undo` 乐观删除/撤销，并补充 `ListStatusView` 空状态。
  - `TopicHistoryListPage` 单条历史删除对齐「左滑 + 行尾菜单 + SnackBar 撤销」，清空历史确认改用 `M3ConfirmDialog`。

### P1：视觉语言与交互模式统一

- [x] **P1-1 启用 M3 新版控件主题（Slider、ProgressIndicator、Switch、SnackBar）**
  - 在 `ThemeBuilder` 配置非弃用的 2024 M3 `SliderThemeData`（`GappedSliderTrackShape`、`HandleThumbShape`、轨道间隙）、`ProgressIndicatorThemeData`（圆角端点、轨道间隙与停顿点）、`SwitchThemeData`（`thumbIcon` ✓/✕）、`SnackBarThemeData`（floating 圆角与 `inverseSurface`）。

- [ ] **P1-2 统一 M3 分组设置卡片组件并升级个人/设置/关于页**
  - 抽象通用 `M3SettingsGroup` / `M3SettingsTile` / `M3SettingsSwitchTile` / `M3SettingsInfoTile`（`surfaceContainerLow` 圆角分组卡片 + 组内细分割线）。
  - 统一重构 `SettingsPage`（主题设置副标题与尾部显示当前主题色预览）、`MinePage`、`InterfaceSettingsPage`（增加顶部**实时排版预览卡片**与 Slider 数值气泡）、`BlocklistSettingsPage` 与 `AboutPage`（使用真实应用图标 `images/launcher/icon_1024.png`，开源协议接入 `showLicensePage`）。

- [ ] **P1-3 统一确认对话框与响应式 Modal Bottom Sheet 选择面板**
  - 抽象 `showM3SelectionSheet`：窄屏（< 600dp）使用 `showModalBottomSheet(showDragHandle: true)` 便于单手操作，宽屏自动切换为居中 M3 `Dialog`。
  - 升级 `ThemeSelectionDialog`（新增动态配色开关、M3 三色调色盘色块、`InkResponse` 48dp 触控区与读屏语义）、`LineHeightSelectionDialog`、`BlockModeSelectionDialog`、`BaseUrlSelectionDialog`、`UserAgentSelectionDialog`、`ForumTagDialog`；清理绕过封装的 `ScaffoldMessenger.showSnackBar`。
  - 其余确认/输入弹窗（`FavouriteForumGroupPage`、`NotificationListPage`、`ConversationDetailPage`、`PublishPage`、`BlocklistEditDialog`、`ContactEditDialog`）统一改为 `M3ConfirmDialog` / `M3Dialog`，消除泛泛的「提示」标题。

- [ ] **P1-4 帖子详情页底栏主操作层级与页码/楼层精准跳转**
  - `TopicDetailPage` 底栏将「回复」升级为强调态主操作（`IconButton.filledTonal`），页码指示改为标准 `TextButton`（保证 48dp 触控高度）。
  - `TopicPageSelectDialog` 升级为响应式 Bottom Sheet / Dialog：补全 `Slider` 气泡标签、`max == 1` 安全处理、新增 +/- 步进按钮与数字直输框，便于高楼帖精准跳转。

### P2：细节打磨与无障碍完善

- [ ] **P2-1 搜索页升级为 M3 SearchBar 风格与 SegmentedButton**
  - `SearchPage` 进入自动聚焦，消除框内与 AppBar 双重搜索图标冗余；将互斥单选项（搜索类型、搜索范围、搜索方式）从 `ChoiceChip` 升级为 `SegmentedButton`。

- [ ] **P2-2 沉浸式图片预览页**
  - `PhotoPreviewPage` 改为纯黑沉浸背景 + 渐变半透明悬浮顶栏（`extendBodyBehindAppBar: true`），支持点击显隐工具栏与标准 Material 下载图标。

- [ ] **P2-3 动效适配系统减弱动画设置与微交互完善**
  - `Motion` 新增 `Motion.resolveDuration(context, duration)` 尊重 `MediaQuery.disableAnimationsOf(context)`。
  - 优化 `MinePage` 过长的 700ms 错峰位移入场动画，为 `ForumDetailPage` FAB 补齐缩放淡入动效，扩展 `AppHaptics` 覆盖收藏/发布等关键操作，整理 `EasyRefresh` 默认头尾配置位置。

- [ ] **P2-4 统一 Material 图标风格、触控热区、空状态与排版 Token**
  - 用原生 Material Icons 替换常用位置的旧版 `CommunityMaterialIcons`（日夜切换、收藏、评论、点赞/点踩、保存等）。
  - 提升小触控区交互：`HotRepliesSection` `[原帖]` 改用 `TextButton`、`UserInfoPage` 个人版面/管理版块改用 `ActionChip`；补全缺失的 `tooltip` 与收藏高亮态。
  - 为 `ChildForumListPage`、`AccountManagementPage` 空列表接入 `ListStatusView`；将 `TopicReplyItemWidget`、`TopicHistoryListPage` 等处的硬编码 `TextStyle(fontSize: ...)` 改为从 `textTheme` 派生。
