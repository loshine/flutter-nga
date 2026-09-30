# Flutter NGA

[![Flutter](https://img.shields.io/badge/Flutter-3.47.5-02569B?logo=flutter)](https://flutter.dev)
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
| 框架     | Flutter stable 3.47.5 (FVM)  |
| 状态管理 | Riverpod 3.x + flutter_hooks |
| 路由     | go_router                    |
| 网络     | Dio                          |
| 本地存储 | Sembast                      |
| 主题     | adaptive_theme               |
| 编码转换 | fast_gbk (GBK -> UTF-8)      |

## 快速开始

### 环境要求

- Flutter stable 3.47.5 (推荐使用 [FVM](https://fvm.app) 管理版本)
- Dart SDK >=3.13.0 <4.0.0
- Android SDK / Xcode (取决于目标平台)

Android 构建使用 Gradle 9.3.1、AGP 9.1.0、Kotlin 2.4.0。
与 `missevan-kmp` 相同，通过 Foojay 和 `android/gradle/gradle-daemon-jvm.properties`
自动获取 Java 21 作为构建 JVM，无需手动安装或配置本机 JDK 21。首次构建需要联网，
下载的 JDK 缓存在 Gradle 用户目录的 `jdks/` 下。应用字节码目标保持 Java 17。
启动 Gradle Wrapper 仍需要可用的 Java 17+，可使用 Android Studio 自带的 JBR。

当前启用 AGP 内置 Kotlin，并保留 Flutter 3.47 所需的 `android.newDsl=false`。
`flutter_inappwebview_android 1.1.3` 尚未发布 AGP 9 修复的稳定版，
构建会在 `build/gradle-compat/` 中生成插件 Android 模块副本，替换已移除的默认 ProGuard 配置；
不会修改共享 pub 缓存。插件稳定版包含上游修复 #2765 后可移除该兼容逻辑。

更新构建 JDK 下载配置：

```bash
cd android
./gradlew updateDaemonJvm --jvm-version=21
```

### 安装与运行

```bash
# 克隆项目
git clone https://github.com/user/flutter-nga.git
cd flutter-nga

# 安装 FVM (如未安装)
dart pub global activate fvm

# 使用指定 Flutter stable 版本
fvm install

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

复制签名配置示例并填写实际值：

```bash
cp android/key.example.properties android/key.properties
```

`android/key.properties` 配置示例：

```properties
storeFile=/absolute/path/upload-keystore.jks
storePassword=your-store-password
keyAlias=upload
keyPassword=your-key-password
```

`storeFile` 支持绝对路径或相对于 `android/` 的路径。未填写或为空时，
Release 回退到 debug 签名；填写后必须提供其余三个字段，文件不存在或签名信息错误会报错，不回退。
`key.properties` 已被 Git 忽略；`key.example.properties` 仅保存示例，不要在其中填写真实密码或提交 keystore。
`key.properties` 不存在时也会回退到 debug 签名。

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
│   ├── entity/            # 数据实体
│   ├── repository/        # 数据仓库
│   └── core/              # Dio 配置与仓库装配
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
