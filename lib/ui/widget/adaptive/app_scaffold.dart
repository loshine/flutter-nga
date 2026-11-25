import 'package:cupertino_ui/cupertino_ui.dart'
    show CupertinoButton, CupertinoIcons;
import 'package:material_ui/material_ui.dart';

import 'package:flutter_nga/providers/settings/design_style_provider.dart';
import 'package:flutter_nga/ui/widget/adaptive/liquid_glass_surface.dart';
import 'package:flutter_nga/utils/motion.dart';

/// 页面的主要操作描述：
/// - Material You 风格下作为右下角 [FloatingActionButton] 呈现；
/// - Apple 风格下遵循 HIG 无 FAB 原则，自动收口至顶部导航栏/工具栏右侧。
class AppPrimaryAction {
  const AppPrimaryAction({
    this.key,
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    this.appleIcon,
    this.appleLabel,
    this.visible = true,
    this.loading = false,
  });

  final Key? key;
  final String tooltip;
  final Widget icon;
  final VoidCallback? onPressed;

  /// Apple 风格下替代 [icon] 的图标（如 CupertinoIcons）。
  final Widget? appleIcon;

  /// Apple 风格下优先展示文字操作按钮（如「发送」「完成」），更贴合 HIG。
  final String? appleLabel;

  /// 控制是否显示（Material 端会带缩放/淡入淡出过渡）。
  final bool visible;

  /// 提交中等加载态（禁用点击并显示进度指示）。
  final bool loading;
}

/// 平台自适应页面骨架：
/// - Material You：标准 [Scaffold] + [AppBar] + 可选 [FloatingActionButton]；
/// - Apple 风格：融合 [LiquidGlassSurface] 材质顶栏 + iOS/macOS 返回按钮 + 无 FAB 工具栏动作。
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    this.title,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.centerTitle,
    this.actions,
    this.bottom,
    this.scrolledUnderElevation,
    this.toolbarHeight,
    this.titleSpacing,
    required this.body,
    this.bottomNavigationBar,
    this.primaryAction,
    this.backgroundColor,
    this.extendBody = false,
    this.showAppBar = true,
    this.embedded = false,
    this.includeMacTitlebarInset = true,
  });

  final Widget? title;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final bool? centerTitle;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final double? scrolledUnderElevation;
  final double? toolbarHeight;
  final double? titleSpacing;
  final Widget body;
  final Widget? bottomNavigationBar;
  final AppPrimaryAction? primaryAction;
  final Color? backgroundColor;
  final bool extendBody;
  final bool showAppBar;
  final bool embedded;
  final bool includeMacTitlebarInset;

  @override
  Widget build(BuildContext context) {
    final isApple = context.isAppleStyle;

    if (!isApple) {
      return Scaffold(
        backgroundColor: backgroundColor,
        extendBody: extendBody,
        appBar: showAppBar
            ? AppBar(
                leading: leading,
                automaticallyImplyLeading:
                    automaticallyImplyLeading && !embedded,
                centerTitle: centerTitle ?? (embedded ? false : null),
                title: title,
                actions: actions,
                bottom: bottom,
                scrolledUnderElevation: scrolledUnderElevation,
                toolbarHeight: toolbarHeight,
                titleSpacing: titleSpacing,
              )
            : null,
        body: body,
        bottomNavigationBar: bottomNavigationBar,
        floatingActionButton: _buildMaterialFab(context, primaryAction),
      );
    }

    final mergedActions = <Widget>[
      ...?actions,
      if (primaryAction != null && primaryAction!.visible)
        _buildApplePrimaryAction(context, primaryAction!),
    ];

    final isMacDesktop = context.isMacDesktopAppleStyle;
    final trafficLightInset = includeMacTitlebarInset && !embedded
        ? context.macTitlebarInset
        : 0.0;
    final resolvedHeight = toolbarHeight ?? (isMacDesktop ? 52.0 : 48.0);

    return Scaffold(
      backgroundColor: backgroundColor,
      extendBody: extendBody,
      appBar: showAppBar
          ? AppTopBar(
              title: title,
              leading: leading,
              automaticallyImplyLeading: automaticallyImplyLeading && !embedded,
              centerTitle: centerTitle ?? !(embedded || isMacDesktop),
              actions: mergedActions,
              bottom: bottom,
              toolbarHeight: resolvedHeight,
              trafficLightInset: trafficLightInset,
            )
          : null,
      body: body,
      bottomNavigationBar: bottomNavigationBar,
    );
  }

  Widget? _buildMaterialFab(BuildContext context, AppPrimaryAction? action) {
    if (action == null) return null;
    final Widget? fab = action.visible
        ? FloatingActionButton(
            key: action.key,
            tooltip: action.tooltip,
            onPressed: action.loading ? null : action.onPressed,
            child: action.loading
                ? const SizedBox.square(
                    dimension: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : action.icon,
          )
        : null;

    return AnimatedSwitcher(
      duration: Motion.resolveDuration(context, Motion.durationShort4),
      switchInCurve: Motion.emphasizedDecelerate,
      switchOutCurve: Motion.emphasizedAccelerate,
      transitionBuilder: (child, animation) => ScaleTransition(
        scale: animation,
        child: FadeTransition(opacity: animation, child: child),
      ),
      child: fab,
    );
  }

  Widget _buildApplePrimaryAction(
    BuildContext context,
    AppPrimaryAction action,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    if (action.loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 12),
        child: SizedBox.square(
          dimension: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }
    if (action.appleLabel != null) {
      return Tooltip(
        message: action.tooltip,
        child: CupertinoButton(
          key: action.key,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          minimumSize: const Size(44, 36),
          onPressed: action.onPressed,
          child: Text(
            action.appleLabel!,
            style: TextStyle(
              color: action.onPressed == null
                  ? colorScheme.onSurfaceVariant.withValues(alpha: 0.4)
                  : colorScheme.primary,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ),
      );
    }

    return IconButton(
      key: action.key,
      tooltip: action.tooltip,
      color: colorScheme.primary,
      icon: action.appleIcon ?? action.icon,
      onPressed: action.onPressed,
    );
  }
}

/// Apple 风格的顶部导航栏 / macOS 52pt 单行统一工具栏。
class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  const AppTopBar({
    super.key,
    this.title,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.centerTitle = true,
    this.actions,
    this.bottom,
    this.toolbarHeight,
    this.trafficLightInset = 0.0,
  });

  final Widget? title;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final bool centerTitle;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final double? toolbarHeight;

  /// 非零时在左侧预留 macOS 窗口红绿灯（关闭/最小化/缩放）水平安全区宽度；
  /// 全屏模式下自动为 0。
  final double trafficLightInset;

  double get _baseHeight => toolbarHeight ?? 48.0;

  @override
  Size get preferredSize =>
      Size.fromHeight(_baseHeight + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final canPop = ModalRoute.of(context)?.impliesAppBarDismissal ?? false;
    final isMacDesktop = context.isMacDesktopAppleStyle;
    final topPadding = MediaQuery.paddingOf(context).top;

    Widget? resolvedLeading = leading;
    if (resolvedLeading == null && automaticallyImplyLeading && canPop) {
      resolvedLeading = Tooltip(
        message: '返回',
        child: isMacDesktop
            ? IconButton(
                icon: Icon(
                  CupertinoIcons.back,
                  size: 16,
                  color: colorScheme.onSurfaceVariant,
                ),
                onPressed: () => Navigator.of(context).maybePop(),
              )
            : CupertinoButton(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                minimumSize: const Size(34, 34),
                onPressed: () => Navigator.of(context).maybePop(),
                child: Icon(
                  CupertinoIcons.back,
                  size: 22,
                  color: colorScheme.primary,
                ),
              ),
      );
    }

    if (trafficLightInset > 0) {
      resolvedLeading = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(width: trafficLightInset),
          if (resolvedLeading != null) ...[
            const SizedBox(width: 4),
            resolvedLeading,
          ],
        ],
      );
    }

    final titleStyle =
        (isMacDesktop
                ? theme.textTheme.titleSmall
                : theme.textTheme.titleMedium)
            ?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
              fontSize: isMacDesktop ? 14 : 17,
              letterSpacing: isMacDesktop ? -0.1 : null,
            );

    final actionRow = actions != null && actions!.isNotEmpty
        ? Row(
            mainAxisSize: MainAxisSize.min,
            spacing: isMacDesktop ? 2 : 0,
            children: actions!,
          )
        : null;

    final styledTitle = title != null
        ? DefaultTextStyle.merge(
            style: titleStyle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            child: title!,
          )
        : null;

    final Widget toolbarContent;
    if (isMacDesktop && !centerTitle) {
      toolbarContent = Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (resolvedLeading != null) ...[
            resolvedLeading,
            const SizedBox(width: 6),
          ],
          Expanded(
            child: styledTitle != null
                ? Align(alignment: Alignment.centerLeft, child: styledTitle)
                : const SizedBox.shrink(),
          ),
          if (actionRow != null) ...[const SizedBox(width: 6), actionRow],
        ],
      );
    } else {
      toolbarContent = NavigationToolbar(
        leading: resolvedLeading,
        middle: styledTitle,
        trailing: actionRow,
        centerMiddle: centerTitle,
        middleSpacing: 8,
      );
    }

    return LiquidGlassSurface(
      variant: LiquidGlassVariant.bar,
      borderRadius: BorderRadius.zero,
      showShadow: false,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: colorScheme.outlineVariant, width: 0.5),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.only(top: topPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: _baseHeight,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMacDesktop ? 10 : 8,
                  ),
                  child: toolbarContent,
                ),
              ),
              ?bottom,
            ],
          ),
        ),
      ),
    );
  }
}
