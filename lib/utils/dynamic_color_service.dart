import 'package:flutter/services.dart';

/// 从系统读取 Material You / 平台强调色作为动态种子色。
///
/// Android 12+（API 31+）返回系统壁纸主强调色 `system_accent1_500`，
/// macOS 返回系统偏好设置中的强调色 `controlAccentColor`，其余平台返回 null。
abstract final class DynamicColorService {
  static const MethodChannel channel = MethodChannel(
    'io.github.loshine.flutternga/dynamic_color',
  );

  /// 读取当前系统的动态强调色，平台不支持或调用失败时返回 null。
  static Future<Color?> getSystemAccentColor() async {
    try {
      final argb = await channel.invokeMethod<int>('getAccentColor');
      if (argb == null) return null;
      return Color(argb);
    } on MissingPluginException {
      return null;
    } on PlatformException {
      return null;
    }
  }
}
