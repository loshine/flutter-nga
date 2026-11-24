import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/services.dart';

/// 将应用内选择的主题模式同步到原生宿主。
///
/// Android 12+（API 31+）通过 `UiModeManager.setApplicationNightMode`
/// 持久化应用级深浅色模式，使冷启动原生启动页也能匹配用户在应用内选择的
/// 亮色 / 暗色 / 跟随系统设置；其余平台忽略。
abstract final class NativeThemeService {
  static const MethodChannel channel = MethodChannel(
    'io.github.loshine.flutternga/native_theme',
  );

  /// 同步主题模式到原生层，平台不支持或调用失败时静默忽略。
  static Future<void> setNightMode(AdaptiveThemeMode? mode) async {
    final value = switch (mode) {
      AdaptiveThemeMode.light => 'light',
      AdaptiveThemeMode.dark => 'dark',
      AdaptiveThemeMode.system || null => 'system',
    };
    try {
      await channel.invokeMethod<void>('setNightMode', value);
    } on MissingPluginException {
      // 单元测试或未注册通道的平台直接忽略
    } on PlatformException {
      // 系统调用失败不影响应用内主题切换
    }
  }
}
