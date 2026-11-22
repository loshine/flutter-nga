import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:material_ui/material_ui.dart';
import 'package:timeago/timeago.dart' as time_ago;
import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/utils/custom_time_messages.dart';
import 'package:flutter_nga/utils/route.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key, @visibleForTesting this.initData});

  /// 仅用于测试注入初始化过程，默认执行 [Data.init]。
  final Future<void> Function()? initData;

  /// 亮色启动页背景色，需与 `flutter_native_splash.yaml` 的 `color` 保持一致。
  static const lightBackground = Color(0xFFFFF9E3);

  /// 暗色启动页背景色，需与 `flutter_native_splash.yaml` 的 `color_dark` 保持一致。
  static const darkBackground = Color(0xFF181210);

  /// 亮色启动页图标资源路径。
  static const lightIconAsset = 'images/launcher/splash_icon_1024.png';

  /// 暗色启动页图标资源路径。
  static const darkIconAsset = 'images/launcher/splash_icon_dark_1024.png';

  @override
  State<SplashPage> createState() => _SplashState();
}

class _SplashState extends State<SplashPage> {
  @override
  void initState() {
    time_ago.setLocaleMessages('en', CustomTimeMessages());
    final init = widget.initData ?? () => Data().init();
    init().then((_) {
      if (!mounted) return;
      FlutterNativeSplash.remove();
      Routes.navigateTo(context, Routes.HOME, replace: true);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final overlayStyle =
        (isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark)
            .copyWith(
              statusBarColor: Colors.transparent,
              systemNavigationBarColor: Colors.transparent,
              systemNavigationBarContrastEnforced: false,
            );
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyle,
      child: Scaffold(
        backgroundColor: isDark
            ? SplashPage.darkBackground
            : SplashPage.lightBackground,
        body: Center(
          child: Image.asset(
            isDark ? SplashPage.darkIconAsset : SplashPage.lightIconAsset,
            width: 200,
            height: 200,
          ),
        ),
      ),
    );
  }
}
