import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:flutter_nga/data/core/app_preferences.dart';
import 'package:flutter_nga/utils/apple_native_service.dart';

/// 用户在设置中选择的界面设计风格偏好。
enum DesignStylePreference {
  /// 跟随当前平台：iOS / iPadOS / macOS 默认 Apple 规范，其余平台默认 Material You。
  auto('auto', '跟随平台', 'Apple 设备使用 Apple 规范，其余平台使用 Material You'),

  /// 强制使用 Material You (M3) 规范。
  material('material', 'Material You', '始终使用 Material 3 设计规范'),

  /// 强制使用 Apple HIG（含 Liquid Glass 视觉风格）。
  apple('apple', 'Apple 风格', '始终使用 Apple 人机界面规范（支持 Liquid Glass）');

  const DesignStylePreference(this.storageValue, this.label, this.subtitle);

  final String storageValue;
  final String label;
  final String subtitle;

  static DesignStylePreference fromStorage(String? value) {
    for (final item in values) {
      if (item.storageValue == value) return item;
    }
    return DesignStylePreference.auto;
  }
}

/// 实际生效的设计语言。
enum AppDesignStyle { material, apple }

class DesignStyleState {
  const DesignStyleState({
    this.preference = DesignStylePreference.auto,
    this.nativeLiquidGlassSupported = false,
    this.macTitlebarInset = 0,
  });

  final DesignStylePreference preference;

  /// 当前运行宿主是否支持原生 Liquid Glass（iOS 26+ / macOS 26+）。
  final bool nativeLiquidGlassSupported;

  /// macOS 启用融合标题栏时左上角红绿灯预留的水平安全区宽度（全屏、非 macOS 或 Material 模式为 0）。
  final double macTitlebarInset;

  /// 按指定平台解析生效的设计风格。
  AppDesignStyle resolveFor(TargetPlatform platform) {
    return switch (preference) {
      DesignStylePreference.material => AppDesignStyle.material,
      DesignStylePreference.apple => AppDesignStyle.apple,
      DesignStylePreference.auto =>
        platform == TargetPlatform.iOS || platform == TargetPlatform.macOS
            ? AppDesignStyle.apple
            : AppDesignStyle.material,
    };
  }

  /// 当前宿主平台的生效风格。
  AppDesignStyle get effectiveStyle => resolveFor(defaultTargetPlatform);

  bool get isAppleStyle => effectiveStyle == AppDesignStyle.apple;

  /// 设置页副标题展示文本。
  String displaySummary(TargetPlatform platform) {
    final resolved = resolveFor(platform);
    final resolvedName = resolved == AppDesignStyle.apple
        ? 'Apple 风格'
        : 'Material You';
    if (preference == DesignStylePreference.auto) {
      return '跟随平台 · $resolvedName';
    }
    return resolvedName;
  }

  DesignStyleState copyWith({
    DesignStylePreference? preference,
    bool? nativeLiquidGlassSupported,
    double? macTitlebarInset,
  }) {
    return DesignStyleState(
      preference: preference ?? this.preference,
      nativeLiquidGlassSupported:
          nativeLiquidGlassSupported ?? this.nativeLiquidGlassSupported,
      macTitlebarInset: macTitlebarInset ?? this.macTitlebarInset,
    );
  }
}

class DesignStyleNotifier extends Notifier<DesignStyleState> {
  DesignStyleNotifier([this._initialState]);

  final DesignStyleState? _initialState;

  @override
  DesignStyleState build() {
    AppleNativeService.setTrafficLightInsetListener((inset) {
      if (state.macTitlebarInset != inset) {
        state = state.copyWith(macTitlebarInset: inset);
      }
    });
    ref.onDispose(() {
      AppleNativeService.setTrafficLightInsetListener(null);
    });
    return _initialState ?? const DesignStyleState();
  }

  /// 启动前预读已保存的界面风格和原生能力，并同步 macOS 窗口标题栏形态。
  static Future<DesignStyleState> loadSaved() async {
    final prefs = await AppPreferences.instance();
    final preference = DesignStylePreference.fromStorage(
      prefs.getString(PrefsKeys.designStyle),
    );
    final nativeLiquidGlassSupported =
        await AppleNativeService.isLiquidGlassSupported();
    final initial = DesignStyleState(
      preference: preference,
      nativeLiquidGlassSupported: nativeLiquidGlassSupported,
    );
    final macInset = await AppleNativeService.setMacWindowStyle(
      appleStyle: initial.isAppleStyle,
    );
    return initial.copyWith(macTitlebarInset: macInset);
  }

  Future<void> setPreference(DesignStylePreference preference) async {
    if (state.preference == preference) return;
    final prefs = await AppPreferences.instance();
    await prefs.setString(PrefsKeys.designStyle, preference.storageValue);
    final next = state.copyWith(preference: preference);
    state = next;
    final macInset = await AppleNativeService.setMacWindowStyle(
      appleStyle: next.isAppleStyle,
    );
    if (state.macTitlebarInset != macInset) {
      state = state.copyWith(macTitlebarInset: macInset);
    }
  }
}

final designStyleProvider =
    NotifierProvider<DesignStyleNotifier, DesignStyleState>(
      DesignStyleNotifier.new,
    );

/// 通过 InheritedWidget 向整棵组件树透传当前生效的设计风格与原生能力，
/// 使普通 StatelessWidget 也能响应风格热切换而不必全部改为 ConsumerWidget。
class AppDesignStyleScope extends InheritedWidget {
  const AppDesignStyleScope({
    super.key,
    required this.style,
    required this.nativeLiquidGlassSupported,
    required this.macTitlebarInset,
    required super.child,
  });

  final AppDesignStyle style;
  final bool nativeLiquidGlassSupported;
  final double macTitlebarInset;

  static AppDesignStyleScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppDesignStyleScope>();
  }

  /// 读取当前上下文生效的风格。测试中若未包裹 [AppDesignStyleScope]，
  /// 自动回退为按 `Theme.of(context).platform` 解析的默认平台风格。
  static AppDesignStyle styleOf(BuildContext context) {
    final scope = maybeOf(context);
    if (scope != null) return scope.style;
    final platform = Theme.of(context).platform;
    return platform == TargetPlatform.iOS || platform == TargetPlatform.macOS
        ? AppDesignStyle.apple
        : AppDesignStyle.material;
  }

  static bool nativeLiquidGlassOf(BuildContext context) {
    return maybeOf(context)?.nativeLiquidGlassSupported ?? false;
  }

  static double macTitlebarInsetOf(BuildContext context) {
    return maybeOf(context)?.macTitlebarInset ?? 0;
  }

  @override
  bool updateShouldNotify(AppDesignStyleScope oldWidget) {
    return style != oldWidget.style ||
        nativeLiquidGlassSupported != oldWidget.nativeLiquidGlassSupported ||
        macTitlebarInset != oldWidget.macTitlebarInset;
  }
}

extension AppDesignStyleContext on BuildContext {
  AppDesignStyle get designStyle => AppDesignStyleScope.styleOf(this);

  bool get isAppleStyle => designStyle == AppDesignStyle.apple;

  /// 是否处于桌面形态的 Apple 风格（macOS 真机，或在大屏桌面平台手动启用 Apple 风格）。
  bool get isMacDesktopAppleStyle {
    if (!isAppleStyle) return false;
    final platform = Theme.of(this).platform;
    return platform == TargetPlatform.macOS ||
        platform == TargetPlatform.windows ||
        platform == TargetPlatform.linux;
  }

  bool get supportsNativeLiquidGlass =>
      AppDesignStyleScope.nativeLiquidGlassOf(this);

  /// macOS 融合标题栏顶部安全区高度（供侧边栏和顶栏避让红绿灯）。
  double get macTitlebarInset => AppDesignStyleScope.macTitlebarInsetOf(this);
}
