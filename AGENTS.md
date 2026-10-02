# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

> Flutter 开发的 NGA (艾泽拉斯国家地理) 论坛客户端。

## 环境准备

通过 [FVM](https://fvm.app) 锁定 Flutter stable 版本（以 `.fvmrc` 为准，当前 3.47.5），所有 flutter 命令用 `fvm flutter` 前缀执行。

```bash
dart pub global activate fvm   # 安装 FVM（如未安装）
fvm install                    # 安装 .fvmrc 指定版本
```

鸿蒙（OHOS）适配在 `feature/ohos` 分支维护，master 不包含 `ohos/` 目录和原生登录插件。

## 构建与测试

```bash
fvm flutter pub get
fvm flutter analyze
fvm flutter test                                    # 全部测试
fvm flutter test test/utils/json_cast_test.dart     # 单个文件
fvm flutter test --name "Substring test"            # 按名称匹配
fvm flutter build apk
fvm flutter build ios --no-codesign
```

Android 构建（详见 README）：
- Gradle 通过 Foojay 自动下载 Java 21 作为构建 JVM，启动 Wrapper 只需 Java 17+；应用字节码目标为 Java 17。
- `android.newDsl=false` 是 Flutter 3.47 所需，不要移除。
- `android/settings.gradle.kts` 会在 `build/gradle-compat/` 生成 `flutter_inappwebview_android` 的补丁副本以兼容 AGP 9，上游发布修复后可删除该逻辑。
- 签名读取 `android/key.properties`（参考 `key.example.properties`），缺失时 Release 回退 debug 签名。

## 核心架构

### Data() 单例（lib/data/data.dart）

全局数据入口，持有 Dio、Sembast Database 和所有 Repository（由 `data/core/data_repositories.dart` 装配）。访问任何属性前必须 `await Data().init()`，否则抛 `StateError`。
`DataConfigService` 管理运行时可切换的 baseUrl / UserAgent，变更通过 listener 自动同步到 Dio。

### 网络层（lib/data/core/nga_dio_configurator.dart）

- 请求拦截器从默认账号注入 Cookie（uid + cid）。
- 服务端返回 GBK，`responseType` 为 bytes，在响应拦截器用 `fast_gbk` 统一解码，业务层拿到的已是 UTF-8。
- JSON 响应若含 `data` 字段会被自动解包；服务端错误在拦截器里转为 `DioException`。
- 网络请求的 baseUrl 通过 `Data().baseUrl` / `Data().domain` 动态获取，不要写死域名。

### 内容解析管道（lib/utils/parser/content_parser.dart）

NGA 帖子使用 UBB 标签，`NgaContentParser.parse()` 将其转为 HTML：

`unescapeHtml → (Reply to 展开) → ReplyParser → DiceParser → RandomBlock → Album → Table → Content → Emoticon → Dictionary → UnsupportedTagFallback`

- `_ContentParser` 持有 `postDateTimestamp`（用于 `[noimg]` 附件日期前缀推断），每次新建；其余 Parser 无状态，复用 static 实例。
- Dice 需要 `authorId + tid + pid` 生成确定性伪随机结果，只有三者齐全时才执行。
- `quoteBodyByPid`（由 `buildQuoteBodyCache` 从同页楼层构建）用于把「Reply to」展开为带原文的引用。
- 表情映射在首次解析时从 `Data().emoticonRepository` 延迟加载。
- 结果缓存最多 256 条，key 含 dice 参数、发帖时间和引用缓存摘要；新增影响输出的参数时必须同步加入 cache key。

### HTML 渲染（lib/ui/widget/）

- `NgaHtmlContentWidget` / `NgaHtmlCommentWidget` 用 flutter_html 渲染解析结果。
- `nga_html_extensions.dart` 定义自定义标签：`nga_quote`、`album`、`collapse`、`nga_dict`、`nga_emoticon`、`nga_hr`。解析器新增输出标签时需在此处添加渲染。
- `pubspec.yaml` 将 `html` 锁在 0.15.6，因为 flutter_html 3.0.0 依赖了 0.15.7 中被移除的内部 API。

### Material UI 迁移

应用代码统一从 `package:material_ui/material_ui.dart` / `package:cupertino_ui/cupertino_ui.dart` 导入，lib 下不再使用 `package:flutter/material.dart`。
flutter_html、photo_view、toastification 尚未迁移，依赖旧版主题，由 `LegacyThemeBridge`（`MaterialUiCompatibilityBridge`）提供；`test/utils/material_ui_migration_test.dart` 覆盖这一桥接。

### 路由（lib/utils/route.dart, lib/utils/linkroute/）

- 基于 go_router，`Routes` 定义路由常量（SCREAMING_SNAKE_CASE），提供 `navigateTo()` / `navigateToWithParams()` / `pop()`。
- 帖子内链接点击走 `Routes.onLinkTap()`，由 `LinkRoute` 子类（Topic/User/Reply）按正则匹配站内链接，未匹配的用 url_launcher 打开。

### 状态管理

Riverpod 3.x + flutter_hooks。Provider 全部基于 `Notifier` / `NotifierProvider`（含 `.family` / `.autoDispose`），少量 `FutureProvider`，不使用 legacy 的 `StateProvider`。
页面优先 `HookConsumerWidget` / `ConsumerWidget`，`ref.watch` 监听、`ref.read` 一次性读取。按用户区分的数据（用户主页、主题/回复列表）用以 uid 为参数的 family provider 分桶，避免切换 uid 时串用旧缓存；切换登录账号后需调用相关 Notifier 的 `onAccountChanged()`（如 `favouriteForumListProvider`）刷新。

## 代码风格

- Lint：`package:flutter_lints/flutter.yaml`；analyzer 排除各平台原生目录。
- 导入顺序：`dart:` → 第三方包（含 `material_ui`）→ `package:flutter_nga/`。
- Provider 命名：小驼峰 + `Provider` 后缀。
- Repository：抽象类定义接口，实现类 `XxxDataRepository`，通过 `Data()` 访问。
- Entity：`factory fromJson()` + `toJson()`，字段 `final`；服务端字段类型不稳定时用 `utils/json_cast.dart` 的工具转换。

## CI

- PR 触发 `.github/workflows/check.yml`：在 ubuntu / windows / macos 上运行 `fvm flutter test`。
- Tag 推送触发 `build.yml`：测试后构建 APK 与 AAB 并发布。
