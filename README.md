# Flutter NGA

[![Flutter](https://img.shields.io/badge/Flutter-3.50.0-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)](https://dart.dev)
[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Desktop-lightgrey)]()
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
| 框架     | Flutter stable 3.50.0 (FVM)  |
| 状态管理 | Riverpod 3.x + flutter_hooks |
| 路由     | go_router                    |
| 网络     | Dio                          |
| 本地存储 | Sembast                      |
| 主题     | adaptive_theme               |
| 编码转换 | fast_gbk (GBK -> UTF-8)      |

## 快速开始

### 环境要求

- [mise](https://mise.jdx.dev/installing-mise.html)，用于安装 `.tool-versions` 固定的 Flutter SDK（当前 3.50.0）
- Dart SDK >=3.13.0 <4.0.0
- Android SDK / Xcode (取决于目标平台)

Android 构建使用 Gradle 9.9.1、AGP 9.5.1、Kotlin 2.4.21。
通过 Foojay 和 `android/gradle/gradle-daemon-jvm.properties`
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
git clone https://github.com/loshine/flutter-nga.git
cd flutter-nga

# 安装 .tool-versions 指定的 Flutter SDK
mise install

# 获取依赖
mise exec -- flutter pub get

# 运行应用
mise exec -- flutter run
```

### 构建发布版本

```bash
# Android APK
mise exec -- flutter build apk

# Android App Bundle
mise exec -- flutter build appbundle

# iOS (无签名)
mise exec -- flutter build ios --no-codesign
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

### 发布新版本

改动构建配置、SDK 版本、依赖或平台工程的 PR 会触发 `.github/workflows/build.yml` 验证各平台构建。
推送 `v*.*.*` tag 后，Android 正式签名构建通过才会创建 GitHub Release 并上传 APK 和 AAB。更新说明根据合并的 PR 自动生成。

| 平台 | PR 构建产物 |
| --- | --- |
| macOS | 包含 `FNGA.app` 的 ZIP，使用临时签名，未做 Apple 公证 |
| Windows | x64 程序目录 ZIP，解压后运行 `flutter_nga.exe` |
| Linux | x64 程序目录 tar.gz，解压后运行 `flutter_nga` |

iOS 只在发版相关 PR 中做无签名编译检查。Web 只在同类 PR 中生成预览产物，浏览器存储适配完成后再纳入正式发布。

1. 签名 Secrets 配置在仓库 Settings → Environments →「Android Build」中（只需一次）：

   | Secret | 内容 |
   | --- | --- |
   | `JKS` | keystore 文件的 base64，可用 `base64 -i upload-keystore.jks \| pbcopy` 获取 |
   | `STORE_PASSWORD` | 对应 `storePassword` |
   | `KEY_ALIAS` | 对应 `keyAlias` |
   | `KEY_PASSWORD` | 对应 `keyPassword` |

   缺少任一 Secret、JKS 无法解码或密码 / 别名不匹配时构建直接失败，不会发布 debug 签名的包。
   构建日志会打印证书 SHA-1 / SHA-256 指纹，可与本地 `keytool -list -v -keystore <jks>` 的结果对照。
   Release 上传使用内置 `GITHUB_TOKEN`。
2. 修改 `pubspec.yaml` 的 `version`（如 `1.1.0+10100`，构建号为 `主*10000 + 次*100 + 修订`），合入 `main`。
3. 在 `main` 上打 tag 并推送，tag 必须与 `version` 的版本名一致，否则构建失败：

   ```bash
   git tag v1.1.0
   git push origin v1.1.0
   ```

### 测试

```bash
# 运行所有测试
mise exec -- flutter test

# 静态分析
mise exec -- flutter analyze
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
│   ├── common/            # 通用 Provider
│   ├── core/              # 核心 Provider
│   ├── home/              # 首页相关
│   ├── forum/             # 版块相关
│   ├── topic/             # 帖子相关
│   ├── user/              # 用户相关
│   ├── message/           # 私信相关
│   ├── notification/      # 通知相关
│   ├── search/            # 搜索相关
│   └── settings/          # 设置相关
├── ui/
│   ├── page/              # 页面组件
│   └── widget/            # 通用组件
└── utils/
    ├── parser/            # UBB 内容解析
    ├── linkroute/         # 站内链接路由
    ├── route.dart         # 路由定义
    ├── palette.dart       # 调色板
    └── dimen.dart         # 尺寸常量
```

## 支持平台

- Android
- iOS（15.0+）
- macOS
- Linux
- Windows

鸿蒙（HarmonyOS）适配在 [`feature/ohos`](https://github.com/loshine/flutter-nga/tree/feature/ohos) 分支维护。

## 开源协议

[Apache License 2.0](LICENSE)
