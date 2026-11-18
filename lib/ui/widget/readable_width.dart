import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

/// 阅读型内容的默认最大宽度，对应 Material 3 的 expanded 断点。
const double kReadableMaxWidth = 840;

/// 把内容水平居中并限制最大宽度，用于非滚动或整体包裹的页面内容。
///
/// 滚动列表请改用 [ReadableListPadding]：滚动视图保持全宽，只把内容收窄，
/// 下拉刷新和滚动条仍可在整个宽度内操作。
class ReadableWidth extends StatelessWidget {
  const ReadableWidth({
    super.key,
    required this.child,
    this.maxWidth = kReadableMaxWidth,
  });

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}

/// 计算让 [viewportWidth] 宽的滚动视图把内容收窄到 [maxWidth] 所需的内边距。
///
/// 结果在 [base] 的基础上，左右各补上超出部分的一半；视口不超过 [maxWidth] 时
/// 原样返回 [base]。
EdgeInsets readableListPadding(
  double viewportWidth, {
  EdgeInsets base = EdgeInsets.zero,
  double maxWidth = kReadableMaxWidth,
}) {
  final inset = math.max(0.0, (viewportWidth - maxWidth) / 2);
  if (inset == 0) return base;
  return base + EdgeInsets.symmetric(horizontal: inset);
}

/// 为滚动列表提供收窄内容用的 [EdgeInsets]，交给 `ListView.padding` 或
/// `SliverPadding` 使用。
///
/// 滚动视图本身仍占满全宽，所以下拉刷新、滚动条和拖动区域不变；列表项、
/// 分隔线和列表项背景一起收窄，不会出现内容收窄而分隔线撑满的情况。
///
/// [padding] 为空时沿用 [ListView] 默认行为，把 [MediaQuery] 的上下安全区
/// 作为基础内边距，避免因显式传入 padding 而丢掉底部安全区。
class ReadableListPadding extends StatelessWidget {
  const ReadableListPadding({
    super.key,
    required this.builder,
    this.padding,
    this.maxWidth = kReadableMaxWidth,
  });

  final Widget Function(BuildContext context, EdgeInsets padding) builder;
  final EdgeInsets? padding;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final base =
        padding ??
        MediaQuery.paddingOf(context).copyWith(left: 0.0, right: 0.0);
    return LayoutBuilder(
      builder: (context, constraints) => builder(
        context,
        readableListPadding(
          constraints.maxWidth,
          base: base,
          maxWidth: maxWidth,
        ),
      ),
    );
  }
}
