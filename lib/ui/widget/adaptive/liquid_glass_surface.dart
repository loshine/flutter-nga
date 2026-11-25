import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import 'package:flutter_nga/providers/settings/design_style_provider.dart';
import 'package:flutter_nga/utils/apple_native_service.dart';

/// Liquid Glass 表面形态，对应 Apple HIG 不同层级的悬浮材质。
enum LiquidGlassVariant {
  /// 常规悬浮控件（工具栏按钮组、底部浮动 TabBar、弹窗卡片）。
  regular,

  /// 透明感更强的浮层（覆盖在图片或富媒体上方）。
  clear,

  /// 侧边栏材质（iPadOS / macOS Sidebar）。
  sidebar,

  /// 顶栏 / 底栏通栏材质。
  bar,
}

/// 跨平台分级 Liquid Glass 材质容器：
/// 1. 高对比度无障碍模式 → 实色高对比度表面；
/// 2. iOS 26+ / macOS 26+ 原生宿主且允许原生视图 → 底层嵌入 `UIGlassEffect` / `NSGlassEffectView`；
/// 3. iOS 15–18 / macOS 12–15 或非 Apple 平台手动切 Apple 风格 →
///    通过 `BackdropFilter` + 镜面高光描边 + 柔和投影模拟液态玻璃。
class LiquidGlassSurface extends StatelessWidget {
  const LiquidGlassSurface({
    super.key,
    required this.child,
    this.variant = LiquidGlassVariant.regular,
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
    this.padding,
    this.tintColor,
    this.interactive = false,
    this.useNativeView = true,
    this.showShadow = true,
  });

  final Widget child;
  final LiquidGlassVariant variant;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry? padding;
  final Color? tintColor;
  final bool interactive;

  /// 是否在支持原生 Liquid Glass 的设备上启用 PlatformView 底层渲染。
  /// 频繁滚动的列表项内建议设为 false，仅在导航栏、TabBar、Sidebar 等壳层开启。
  final bool useNativeView;
  final bool showShadow;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final highContrast = MediaQuery.highContrastOf(context);
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    final content = padding != null
        ? Padding(padding: padding!, child: child)
        : child;

    // 高对比度无障碍模式下退回清晰不透明表面，确保可读性。
    if (highContrast) {
      return DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHigh,
          borderRadius: borderRadius,
          border: Border.all(color: theme.colorScheme.outline, width: 1),
        ),
        child: ClipRRect(borderRadius: borderRadius, child: content),
      );
    }

    // 仅在真正悬浮于滚动内容或底层视图之上的容器（regular / clear）启用原生
    // PlatformView，避免把 AppKitView/UiKitView 铺满在纯色背景的通栏顶栏/侧边栏上
    // 产生发灰割裂感。
    final supportsNativeVariant =
        variant == LiquidGlassVariant.regular ||
        variant == LiquidGlassVariant.clear;
    final useNative =
        useNativeView &&
        supportsNativeVariant &&
        AppleNativeService.isRealApplePlatform &&
        context.supportsNativeLiquidGlass;

    if (useNative) {
      return _NativeLiquidGlassContainer(
        borderRadius: borderRadius,
        variant: variant,
        isDark: isDark,
        interactive: interactive && !disableAnimations,
        tintColor: tintColor,
        child: content,
      );
    }

    return _FlutterLiquidGlassContainer(
      borderRadius: borderRadius,
      variant: variant,
      isDark: isDark,
      tintColor: tintColor,
      showShadow: showShadow,
      child: content,
    );
  }
}

class _NativeLiquidGlassContainer extends StatelessWidget {
  const _NativeLiquidGlassContainer({
    required this.borderRadius,
    required this.variant,
    required this.isDark,
    required this.interactive,
    required this.tintColor,
    required this.child,
  });

  final BorderRadius borderRadius;
  final LiquidGlassVariant variant;
  final bool isDark;
  final bool interactive;
  final Color? tintColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius.topLeft.x;
    final tintArgb = tintColor?.toARGB32();
    final creationParams = <String, Object?>{
      'cornerRadius': radius,
      'variant': variant.name,
      'isDark': isDark,
      'interactive': interactive,
      'tintColor': ?tintArgb,
    };
    // 原生 PlatformView 仅在创建时读取 creationParams，明暗模式、材质或着色变化时
    // 通过 ValueKey 强制重建以同步原生外观。
    final viewKey = ValueKey((isDark, variant, tintArgb, radius, interactive));

    final platformView = switch (defaultTargetPlatform) {
      TargetPlatform.iOS => UiKitView(
        key: viewKey,
        viewType: AppleNativeService.liquidGlassViewType,
        creationParams: creationParams,
        creationParamsCodec: const StandardMessageCodec(),
      ),
      TargetPlatform.macOS => AppKitView(
        key: viewKey,
        viewType: AppleNativeService.liquidGlassViewType,
        creationParams: creationParams,
        creationParamsCodec: const StandardMessageCodec(),
      ),
      _ => const SizedBox.shrink(),
    };

    return ClipRRect(
      borderRadius: borderRadius,
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          Positioned.fill(child: IgnorePointer(child: platformView)),
          child,
        ],
      ),
    );
  }
}

class _FlutterLiquidGlassContainer extends StatelessWidget {
  const _FlutterLiquidGlassContainer({
    required this.borderRadius,
    required this.variant,
    required this.isDark,
    required this.tintColor,
    required this.showShadow,
    required this.child,
  });

  final BorderRadius borderRadius;
  final LiquidGlassVariant variant;
  final bool isDark;
  final Color? tintColor;
  final bool showShadow;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final sigma = switch (variant) {
      LiquidGlassVariant.regular => 24.0,
      LiquidGlassVariant.clear => 16.0,
      LiquidGlassVariant.sidebar => 20.0,
      LiquidGlassVariant.bar => 18.0,
    };

    final baseAlpha = switch (variant) {
      LiquidGlassVariant.regular => isDark ? 0.72 : 0.84,
      LiquidGlassVariant.clear => isDark ? 0.42 : 0.56,
      LiquidGlassVariant.sidebar => isDark ? 0.94 : 0.94,
      LiquidGlassVariant.bar => isDark ? 0.88 : 0.90,
    };

    final baseFill =
        tintColor ??
        switch (variant) {
          LiquidGlassVariant.sidebar =>
            isDark ? const Color(0xFF232326) : const Color(0xFFF4F4F6),
          LiquidGlassVariant.bar =>
            isDark ? const Color(0xFF1D1D20) : const Color(0xFFFAFAFC),
          _ => isDark ? const Color(0xFF242427) : const Color(0xFFFFFFFF),
        };
    final rimLight = isDark
        ? Colors.white.withValues(alpha: 0.14)
        : Colors.white.withValues(alpha: 0.85);
    final rimBottom = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.09);

    final isFullBleed =
        variant == LiquidGlassVariant.sidebar ||
        variant == LiquidGlassVariant.bar;

    final glass = ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            color: isFullBleed ? baseFill.withValues(alpha: baseAlpha) : null,
            gradient: isFullBleed
                ? null
                : LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      baseFill.withValues(
                        alpha: (baseAlpha + 0.06).clamp(0.0, 1.0),
                      ),
                      baseFill.withValues(alpha: baseAlpha),
                    ],
                  ),
            border: isFullBleed
                ? null
                : Border.all(color: isDark ? rimLight : rimBottom, width: 0.75),
          ),
          child: isFullBleed
              ? child
              : DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: borderRadius,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.0, 0.20, 1.0],
                      colors: [
                        rimLight.withValues(alpha: isDark ? 0.09 : 0.45),
                        Colors.transparent,
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: child,
                ),
        ),
      ),
    );

    if (!showShadow || variant == LiquidGlassVariant.sidebar) {
      return glass;
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.10),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: glass,
    );
  }
}
