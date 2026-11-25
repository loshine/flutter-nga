import 'package:material_ui/material_ui.dart';

import 'package:flutter_nga/providers/settings/design_style_provider.dart';
import 'package:flutter_nga/ui/page/topic_detail/topic_detail_page.dart';
import 'package:flutter_nga/ui/widget/adaptive/app_icons.dart';
import 'package:flutter_nga/utils/dimen.dart';

/// Material 3 Medium 断点：平板竖屏 / 折叠屏展开态，启用 NavigationRail
const double kCompactBreakpoint = 600.0;

/// Material 3 Expanded 断点：平板横屏 / 桌面窗口，启用展开式侧边导航与左右双栏
const double kExpandedBreakpoint = 840.0;

/// Material 3 Large 断点：宽屏桌面窗口，允许更宽的主栏与更多列数
const double kLargeBreakpoint = 1200.0;

/// 大屏永久展开侧边导航栏宽度
const double kExpandedNavDrawerWidth = 240.0;

/// Material 3 窗口尺寸分级
enum WindowSizeClass {
  compact,
  medium,
  expanded,
  large;

  static WindowSizeClass fromWidth(double width) {
    if (width >= kLargeBreakpoint) return WindowSizeClass.large;
    if (width >= kExpandedBreakpoint) return WindowSizeClass.expanded;
    if (width >= kCompactBreakpoint) return WindowSizeClass.medium;
    return WindowSizeClass.compact;
  }

  static WindowSizeClass of(BuildContext context) =>
      fromWidth(MediaQuery.sizeOf(context).width);

  bool get isCompact => this == WindowSizeClass.compact;
  bool get isMediumOrLarger => index >= WindowSizeClass.medium.index;
  bool get isExpandedOrLarger => index >= WindowSizeClass.expanded.index;
  bool get isLarge => this == WindowSizeClass.large;
}

/// 根据容器可用宽度计算双栏布局中左侧列表栏的合适宽度。
double masterPaneWidthFor(double availableWidth) {
  if (availableWidth >= kLargeBreakpoint) {
    return (availableWidth * 0.34).clamp(380.0, 440.0);
  }
  return (availableWidth * 0.42).clamp(340.0, 380.0);
}

/// 双栏布局中当前选中的帖子描述信息。
class SelectedTopic {
  const SelectedTopic({
    required this.tid,
    this.fid,
    this.subject,
    this.authorid,
  });

  final int tid;
  final int? fid;
  final String? subject;
  final int? authorid;

  @override
  bool operator ==(Object other) =>
      other is SelectedTopic &&
      other.tid == tid &&
      other.fid == fid &&
      other.subject == subject &&
      other.authorid == authorid;

  @override
  int get hashCode => Object.hash(tid, fid, subject, authorid);
}

/// 通用响应式左右双栏（List-Detail / Master-Detail）布局容器。
///
/// 当可用宽度小于 [breakpoint] 时仅渲染 [masterBuilder]（`isTwoPane = false`）；
/// 大于等于 [breakpoint] 时左侧固定宽度展示列表、右侧展开展示详情。
class MasterDetailLayout extends StatelessWidget {
  const MasterDetailLayout({
    super.key,
    required this.masterBuilder,
    required this.detailBuilder,
    this.breakpoint = kExpandedBreakpoint,
    this.masterWidth,
  });

  final Widget Function(BuildContext context, bool isTwoPane) masterBuilder;
  final WidgetBuilder detailBuilder;
  final double breakpoint;
  final double? masterWidth;

  @override
  Widget build(BuildContext context) {
    final isMacApple = context.isMacDesktopAppleStyle;
    // 在 macOS 三栏工作区中，外层侧边栏已占用 244pt，允许在稍窄的剩余宽度（700pt）
    // 即展开中栏列表 + 右栏详情，确保常规 1000~1280pt 桌面窗口完整呈现三栏。
    final effectiveBreakpoint = isMacApple && breakpoint == kExpandedBreakpoint
        ? 680.0
        : breakpoint;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isTwoPane = constraints.maxWidth >= effectiveBreakpoint;
        if (!isTwoPane) {
          return masterBuilder(context, false);
        }

        final paneWidth =
            masterWidth ??
            (isMacApple
                ? (constraints.maxWidth * 0.36).clamp(300.0, 380.0)
                : masterPaneWidthFor(constraints.maxWidth));
        return Row(
          children: [
            SizedBox(
              width: paneWidth,
              child: MediaQuery.removePadding(
                context: context,
                removeRight: true,
                child: masterBuilder(context, true),
              ),
            ),
            VerticalDivider(
              width: isMacApple ? 0.5 : 1,
              thickness: isMacApple ? 0.5 : 1,
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
            Expanded(
              child: MediaQuery.removePadding(
                context: context,
                removeLeft: true,
                child: detailBuilder(context),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// 双栏布局中右侧的帖子详情槽位：有选中项时内嵌 [TopicDetailPage]，否则展示空态。
class TopicDetailPane extends StatelessWidget {
  const TopicDetailPane({
    super.key,
    required this.selected,
    this.onClose,
    this.emptyTitle = '选择一篇帖子开始阅读',
    this.emptySubtitle,
  });

  final SelectedTopic? selected;
  final VoidCallback? onClose;
  final String emptyTitle;
  final String? emptySubtitle;

  @override
  Widget build(BuildContext context) {
    final topic = selected;
    if (topic == null) {
      return MasterDetailEmptyPlaceholder(
        icon: Icons.article_outlined,
        title: emptyTitle,
        subtitle: emptySubtitle,
      );
    }
    return TopicDetailPage(
      topic.tid,
      topic.fid,
      key: ValueKey('embedded-topic-${topic.tid}'),
      subject: topic.subject,
      authorid: topic.authorid,
      embedded: true,
      onClose: onClose,
    );
  }
}

/// 双栏布局中右侧尚未选中条目时的空态占位视图。
class MasterDetailEmptyPlaceholder extends StatelessWidget {
  const MasterDetailEmptyPlaceholder({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isApple = context.isAppleStyle;

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(Dimen.spacingXXL),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isApple)
                Icon(
                  AppIcons.resolve(context, icon),
                  size: 40,
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.45),
                )
              else
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(Dimen.radiusXL),
                  ),
                  child: Icon(icon, size: 32, color: colorScheme.primary),
                ),
              const SizedBox(height: Dimen.spacingL),
              Text(
                title,
                style: textTheme.titleMedium?.copyWith(
                  color: isApple
                      ? colorScheme.onSurfaceVariant
                      : colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: Dimen.spacingS),
                Text(
                  subtitle!,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant.withValues(
                      alpha: isApple ? 0.8 : 1.0,
                    ),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
