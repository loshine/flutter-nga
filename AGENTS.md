# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

> Flutter 开发的 NGA (艾泽拉斯国家地理) 论坛客户端。

## 环境准备

项目通过 [FVM](https://fvm.app) 锁定 Flutter 3.38.5，所有 flutter 命令必须用 `fvm flutter` 前缀执行。

```bash
dart pub global activate fvm   # 安装 FVM（如未安装）
fvm install 3.38.5             # 安装指定 Flutter 版本
fvm use 3.38.5                 # 切换到项目版本
```

## 构建与测试

```bash
fvm flutter pub get          # 获取依赖
fvm flutter analyze          # 静态分析
fvm flutter test             # 运行所有测试
fvm flutter test test/widget_test.dart              # 单个测试文件
fvm flutter test --name "Substring test"            # 按名称匹配
fvm flutter build apk                               # 构建 APK
```

## 核心架构

### Data() 单例（lib/data/data.dart）

全局入口，延迟初始化，管理 Dio、Database、所有 Repository。通过 `DataConfigService` 支持运行时切换 baseUrl 和 UserAgent，变更自动同步到 Dio。访问任何属性前必须确保 `Data().init()` 已完成。

### 内容解析管道（lib/utils/parser/content_parser.dart）

NGA 帖子内容使用 UBB 标签格式，解析链将其转换为 HTML：

`unescapeHtml → ReplyParser → DiceParser → Album/Table/Content/Emoticon/FallbackParser`

关键点：
- `_ContentParser` 持有 `postDateTimestamp` 状态（用于 `[noimg]` 附件日期前缀推断），每次需新建实例；其余 Parser 无状态，复用 static final 实例
- Dice 标签需要 `authorId+tid+pid` 三元组生成确定性伪随机结果
- 表情解析延迟初始化：首次调用时从 Repository 加载映射表
- LRU 缓存 256 条，key 包含上下文参数以区分同内容不同骰子结果

### HTML 渲染（lib/ui/widget/）

- `NgaHtmlContentWidget` / `NgaHtmlCommentWidget`：使用 flutter_html 渲染解析后的 HTML
- `nga_html_extensions.dart`：自定义标签渲染器（`<album>`、`<collapse>`、`<nga_emoticon>`、`<nga_hr>`）
- 链接点击通过 `Routes.onLinkTap()` → `LinkRoute` 正则匹配链处理

### 路由（lib/utils/route.dart, lib/utils/linkroute/）

- `Routes` 类定义路由常量（SCREAMING_SNAKE_CASE），提供 `navigateTo()` 和 `pop()`
- `LinkRoute` 子类按正则匹配站内链接（Topic/User/Reply），未匹配的用 url_launcher 打开

### 编码处理

服务端返回 GBK 编码，在 Dio 拦截器层统一转 UTF-8（`fast_gbk` 包），业务层无感知。`code_utils.unescapeHtml()` 处理 HTML 实体。

## 代码风格

- Lint：`package:flutter_lints/flutter.yaml`
- 导入顺序：`dart:` → `package:flutter/` → 第三方包 → `package:flutter_nga/`
- 文件名 snake_case，类名 PascalCase，路由常量 SCREAMING_SNAKE_CASE
- Provider 命名：小驼峰 + `Provider` 后缀
- Repository 模式：抽象类定义接口，实现类 `XxxDataRepository`，通过 `Data()` 单例访问
- Entity 类：`factory fromJson()` + `toJson()`，字段 `final`
- 状态管理：Riverpod 3.x，复杂状态用 Notifier，简单状态用 StateProvider，异步用 FutureProvider
- Widget：优先 ConsumerWidget / HookConsumerWidget，用 `ref.watch` 监听、`ref.read` 一次性读取

## 注意事项

- 网络请求基础 URL 通过 `Data().baseUrl` 动态获取，支持运行时切换
- 用户认证通过 Cookie（uid + cid）管理，在 Dio 拦截器中注入
- CI：PR 触发 `check.yml`（三平台测试），Tag 推送触发 `build.yml`（发布构建）
