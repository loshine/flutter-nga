# Flutter NGA

[![Flutter](https://img.shields.io/badge/Flutter-3.38.5-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)](https://dart.dev)
[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web%20%7C%20Desktop-lightgrey)]()
[![GitHub stars](https://img.shields.io/github/stars/loshine/flutter-nga?style=social)](https://github.com/loshine/flutter-nga)

> 一个使用 Flutter 开发的 [NGA](https://bbs.nga.cn) (艾泽拉斯国家地理) 论坛客户端。

## 截图

待补充

## 功能特性

### 已实现

- 版块列表与收藏
- 子版块与精华区
- 帖子列表与详情浏览
- 发帖与回复
- 用户登录/登出
- 多账号管理
- 个人资料查看
- 私信与通知
- 全局搜索（帖子/版块）
- 浏览历史
- 收藏帖子
- 深色模式
- 黑名单（用户/关键词）

### 待完善

- 帖子详情细节优化
- 界面设置

## 技术栈

| 分类     | 技术方案                     |
| -------- | ---------------------------- |
| 框架     | Flutter 3.38.5 (FVM)         |
| 状态管理 | Riverpod 3.x + flutter_hooks |
| 路由     | go_router                    |
| 网络     | Dio                          |
| 本地存储 | Sembast                      |
| 主题     | adaptive_theme               |
| 编码转换 | fast_gbk (GBK -> UTF-8)      |

## 快速开始

### 环境要求

- Flutter 3.38.5 (推荐使用 [FVM](https://fvm.app) 管理版本)
- Dart SDK >=3.0.0 <4.0.0
- Android SDK / Xcode (取决于目标平台)

### 安装与运行

```bash
# 克隆项目
git clone https://github.com/user/flutter-nga.git
cd flutter-nga

# 安装 FVM (如未安装)
dart pub global activate fvm

# 使用指定 Flutter 版本
fvm install 3.38.5
fvm use 3.38.5

# 获取依赖
fvm flutter pub get

# 运行应用
fvm flutter run
```

### 构建发布版本

```bash
# Android APK
fvm flutter build apk

# Android App Bundle
fvm flutter build appbundle

# iOS (无签名)
fvm flutter build ios --no-codesign
```

### 测试

```bash
# 运行所有测试
fvm flutter test

# 静态分析
fvm flutter analyze
```

## 项目结构

```
lib/
├── main.dart              # 应用入口
├── my_app.dart            # 根 Widget
├── data/
│   ├── data.dart          # 单例数据管理器
│   ├── http.dart          # HTTP 客户端配置
│   ├── entity/            # 数据实体
│   ├── repository/        # 数据仓库
│   └── usecase/           # 用例层
├── providers/             # Riverpod Providers
│   ├── core/              # 核心 Provider
│   ├── forum/             # 版块相关
│   ├── topic/             # 帖子相关
│   ├── user/              # 用户相关
│   ├── message/           # 消息相关
│   └── settings/          # 设置相关
├── ui/
│   ├── page/              # 页面组件
│   └── widget/            # 通用组件
└── utils/
    ├── route.dart         # 路由定义
    ├── palette.dart       # 调色板
    └── dimen.dart         # 尺寸常量
```

## 支持平台

- Android
- iOS
- macOS
- Linux
- Windows
- Web

## 开源协议

[Apache License 2.0](LICENSE)
