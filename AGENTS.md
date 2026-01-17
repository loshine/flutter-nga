# AGENTS.md - Flutter NGA Project Guide

> 这是一个 Flutter 开发的 NGA (艾泽拉斯国家地理) 论坛客户端应用。

## 项目概览

- **Flutter 版本**: 3.38.5 (通过 FVM 管理)
- **Dart SDK**: >=3.0.0 <4.0.0
- **状态管理**: Riverpod 3.x + flutter_hooks
- **路由**: go_router
- **网络**: Dio
- **本地存储**: Sembast + MMKV
- **主题**: adaptive_theme (支持深色模式)

## 构建与测试命令

```bash
# 使用 FVM 确保正确的 Flutter 版本
fvm use 3.38.5

# 获取依赖
fvm flutter pub get

# 静态分析
fvm flutter analyze

# 运行所有测试
fvm flutter test

# 运行单个测试文件
fvm flutter test test/widget_test.dart

# 运行特定测试 (按名称匹配)
fvm flutter test --name "Substring test"

# 构建 APK
fvm flutter build apk

# 构建 App Bundle
fvm flutter build appbundle

# iOS 构建 (无签名)
fvm flutter build ios --no-codesign
```

## 项目结构

```
lib/
├── main.dart              # 应用入口
├── my_app.dart            # 根 Widget，主题配置，路由初始化
├── data/
│   ├── data.dart          # 单例数据管理器 (Dio, Database, Repositories)
│   ├── http.dart          # HTTP 客户端配置
│   ├── entity/            # 数据实体类
│   ├── repository/        # 数据仓库层
│   └── usecase/           # 用例层
├── providers/             # Riverpod Providers (状态管理)
├── ui/
│   ├── page/              # 页面组件
│   └── widget/            # 可复用组件
├── utils/
│   ├── route.dart         # 路由定义 (Routes 类)
│   ├── palette.dart       # 颜色调色板
│   ├── dimen.dart         # 尺寸常量
│   └── ...
└── plugins/               # 原生插件封装
```

## 代码风格规范

### Lint 配置

使用 `package:flutter_lints/flutter.yaml` 作为基础规则集。

### 导入顺序

1. Dart SDK 导入 (`dart:`)
2. Flutter 包 (`package:flutter/`)
3. 第三方包 (`package:xxx/`)
4. 项目内导入 (`package:flutter_nga/`)

```dart
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/utils/route.dart';
```

### 命名规范

- **文件名**: snake_case (`topic_list_item_widget.dart`)
- **类名**: PascalCase (`TopicListItemWidget`)
- **变量/方法**: camelCase (`getShowName()`)
- **常量**: SCREAMING_SNAKE_CASE 用于路由常量 (`Routes.TOPIC_DETAIL`)
- **私有成员**: 下划线前缀 (`_controller`, `_database`)
- **Provider 命名**: 小驼峰 + `Provider` 后缀 (`topicDetailProvider`)

### Widget 结构

```dart
class MyWidget extends StatelessWidget {
  const MyWidget({Key? key, required this.param}) : super(key: key);

  final String param;

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
```

### Riverpod Provider 模式

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Notifier 模式 (推荐用于复杂状态)
class CounterNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void increment() => state++;
  void setValue(int value) => state = value;
}

final counterProvider = NotifierProvider<CounterNotifier, int>(
  CounterNotifier.new,
);

// StateProvider 模式 (适合简单状态)
final simpleCounterProvider = StateProvider<int>((ref) => 0);

// FutureProvider 模式 (异步数据)
final userProvider = FutureProvider<User>((ref) async {
  final repository = ref.watch(userRepositoryProvider);
  return repository.fetchUser();
});
```

### flutter_hooks 使用

```dart
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class MyHookWidget extends HookConsumerWidget {
  const MyHookWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 使用 hooks
    final controller = useTextEditingController();
    final scrollController = useScrollController();

    // 使用 Riverpod
    final counter = ref.watch(counterProvider);

    return TextField(controller: controller);
  }
}
```

### Repository 模式

- 抽象类定义接口
- 实现类以 `DataRepository` 后缀命名
- 通过 `Data()` 单例访问

```dart
abstract class ForumRepository {
  Future<List<Forum>> getFavouriteList();
}

class ForumDataRepository implements ForumRepository {
  ForumDataRepository(this.database);
  final Database database;

  @override
  Future<List<Forum>> getFavouriteList() async { ... }
}
```

### Entity 类

- 使用 `factory` 构造函数处理 JSON 解析
- 提供 `toJson()` 方法用于序列化
- 字段使用 `final` 声明

```dart
class Forum {
  const Forum(this.fid, this.name, {this.type = 0});

  final int fid;
  final String name;
  final int type;

  factory Forum.fromJson(Map map) {
    return Forum(map['fid'], map['name'], type: map['type'] ?? 0);
  }

  Map<String, dynamic> toJson() {
    return {'fid': fid, 'name': name, 'type': type};
  }
}
```

### 路由使用

```dart
// 定义路由常量
static const String TOPIC_DETAIL = "/topic_detail";

// 导航
Routes.navigateTo(
  context,
  "${Routes.TOPIC_DETAIL}?tid=${topic.tid}&fid=${topic.fid}",
);

// 返回
Routes.pop(context);
```

### 主题与颜色

- 使用 `Palette` 类获取颜色
- 支持深色模式：`Palette.isDark(context)`
- 动态颜色获取：`Palette.getColorPrimary(context)`

### 尺寸常量

使用 `Dimen` 类定义统一尺寸：

- `Dimen.caption` (12) - 说明文字
- `Dimen.body` (14) - 正文
- `Dimen.subheading` (16) - 小标题
- `Dimen.title` (20) - 标题

### 错误处理

- 网络错误通过 Dio 拦截器统一处理
- 使用 `rethrow` 向上传递异常
- 业务错误通过 `DioException` 包装

```dart
try {
  final response = await Data().dio.get(...);
  return result;
} catch (err) {
  rethrow;
}
```

### 异步操作

- 使用 `async/await` 语法
- Provider 中的方法可返回 `Future<void>`
- FutureProvider/StreamProvider 处理异步数据流
- 使用 `AsyncValue` 处理加载、错误、数据状态

```dart
// AsyncValue 使用示例
final data = ref.watch(userProvider);
return data.when(
  loading: () => CircularProgressIndicator(),
  error: (err, stack) => Text('Error: $err'),
  data: (user) => Text(user.name),
);
```

### ConsumerWidget 使用

```dart
// 无状态 Consumer
class MyWidget extends ConsumerWidget {
  const MyWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final counter = ref.watch(counterProvider);
    return Text('$counter');
  }
}

// 有状态 Consumer
class MyStatefulWidget extends ConsumerStatefulWidget {
  const MyStatefulWidget({Key? key}) : super(key: key);

  @override
  ConsumerState<MyStatefulWidget> createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends ConsumerState<MyStatefulWidget> {
  @override
  Widget build(BuildContext context) {
    final counter = ref.watch(counterProvider);
    return GestureDetector(
      onTap: () => ref.read(counterProvider.notifier).increment(),
      child: Text('$counter'),
    );
  }
}

// 使用 Consumer builder
Consumer(
  builder: (context, ref, child) {
    final counter = ref.watch(counterProvider);
    return Text('$counter');
  },
)
```

## 特殊编码处理

- 服务端返回 GBK 编码，需转换为 UTF-8
- 使用 `fast_gbk` 包处理编码转换
- `codeUtils.unescapeHtml()` 处理 HTML 实体

## 测试规范

- 测试文件放置在 `test/` 目录
- 使用 `flutter_test` 包
- 测试名称使用描述性文字

```dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('描述测试目的', () {
    expect(actual, expected);
  });
}
```

## CI/CD

- GitHub Actions 用于自动化构建
- PR 触发测试 (check.yml)
- Tag 推送触发发布构建 (build.yml)

## 注意事项

1. 网络请求基础 URL 定义在 `utils/constant.dart`
2. 用户认证通过 Cookie (uid + cid) 管理
3. 项目使用 FVM 管理 Flutter 版本，确保使用正确版本
4. `ref.watch` 用于监听状态变化，`ref.read` 用于一次性读取
5. `ref.listen` 用于副作用处理（如显示 SnackBar）
