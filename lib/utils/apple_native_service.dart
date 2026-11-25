import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// 封装 iOS / macOS 专属原生能力（Liquid Glass 检测、macOS 融合标题栏控制）。
///
/// 非 Apple 平台或原生侧未注册通道时均安全降级，不抛异常。
abstract final class AppleNativeService {
  static const MethodChannel channel = MethodChannel(
    'io.github.loshine.flutternga/apple_native',
  );

  /// 原生液态玻璃 PlatformView 注册类型（iOS `UiKitView` / macOS `AppKitView`）。
  static const String liquidGlassViewType =
      'io.github.loshine.flutternga/liquid_glass_view';

  static bool? _cachedLiquidGlassSupported;
  static ValueChanged<double>? _trafficLightInsetListener;
  static ValueChanged<String>? _menuNavigateListener;

  @visibleForTesting
  static bool? debugOverrideLiquidGlassSupported;

  /// 监听 macOS 窗口进入/退出全屏导致的红绿灯水平安全区宽度变化。
  static void setTrafficLightInsetListener(ValueChanged<double>? listener) {
    _trafficLightInsetListener = listener;
    _syncMethodCallHandler();
  }

  /// 监听 macOS 原生系统菜单栏触发的页面跳转路径。
  static void setMenuNavigateListener(ValueChanged<String>? listener) {
    _menuNavigateListener = listener;
    _syncMethodCallHandler();
  }

  static void _syncMethodCallHandler() {
    if (!isRealMacOS) return;
    final hasListener =
        _trafficLightInsetListener != null || _menuNavigateListener != null;
    channel.setMethodCallHandler(
      hasListener
          ? (call) async {
              switch (call.method) {
                case 'onTrafficLightInsetChanged':
                  final inset = (call.arguments as num?)?.toDouble() ?? 0.0;
                  _trafficLightInsetListener?.call(inset);
                case 'onMenuNavigate':
                  final path = call.arguments as String?;
                  if (path != null && path.isNotEmpty) {
                    _menuNavigateListener?.call(path);
                  }
              }
            }
          : null,
    );
  }

  /// 当前运行宿主是否为真实 Apple 平台（排除 Web）。
  static bool get isRealApplePlatform =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.macOS);

  /// 当前运行宿主是否为真实 macOS。
  static bool get isRealMacOS =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.macOS;

  /// 当前运行宿主是否为真实 iOS / iPadOS。
  static bool get isRealIOS =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  /// 检测宿主系统是否支持原生 Liquid Glass（iOS 26+ / macOS 26+）。
  static Future<bool> isLiquidGlassSupported() async {
    if (debugOverrideLiquidGlassSupported != null) {
      return debugOverrideLiquidGlassSupported!;
    }
    if (_cachedLiquidGlassSupported != null) {
      return _cachedLiquidGlassSupported!;
    }
    if (!isRealApplePlatform) {
      _cachedLiquidGlassSupported = false;
      return false;
    }
    try {
      final supported = await channel.invokeMethod<bool>(
        'isLiquidGlassSupported',
      );
      _cachedLiquidGlassSupported = supported ?? false;
      return _cachedLiquidGlassSupported!;
    } on MissingPluginException {
      _cachedLiquidGlassSupported = false;
      return false;
    } on PlatformException {
      _cachedLiquidGlassSupported = false;
      return false;
    }
  }

  /// 动态同步 macOS 窗口标题栏形态：
  /// - [appleStyle] 为 true 时开启融合透明标题栏并返回顶部红绿灯安全区高度；
  /// - 为 false 时恢复标准标题栏并返回 0。
  ///
  /// 非 macOS 平台直接返回 0。
  static Future<double> setMacWindowStyle({required bool appleStyle}) async {
    if (!isRealMacOS) return 0;
    try {
      final inset = await channel.invokeMethod<num>('setWindowStyle', {
        'appleStyle': appleStyle,
      });
      return inset?.toDouble() ?? (appleStyle ? 28.0 : 0.0);
    } on MissingPluginException {
      return 0;
    } on PlatformException {
      return 0;
    }
  }

  @visibleForTesting
  static void resetForTesting() {
    _cachedLiquidGlassSupported = null;
    _trafficLightInsetListener = null;
    _menuNavigateListener = null;
    debugOverrideLiquidGlassSupported = null;
  }
}
