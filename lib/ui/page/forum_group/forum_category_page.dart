import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:flutter_nga/data/entity/forum.dart';
import 'package:flutter_nga/providers/forum/forum_category_list_provider.dart';
import 'package:flutter_nga/providers/settings/design_style_provider.dart';
import 'package:flutter_nga/ui/widget/adaptive/app_icons.dart';
import 'package:flutter_nga/ui/widget/adaptive_layout.dart';
import 'package:flutter_nga/ui/widget/forum_grid_item_widget.dart';
import 'package:flutter_nga/utils/app_toast.dart';
import 'package:flutter_nga/utils/dimen.dart';
import 'package:flutter_nga/utils/hooks/scroll_to_top.dart';
import 'package:flutter_nga/utils/motion.dart';

/// 单个版块分类页：按版块组分段展示，组标题下为自适应列数网格，点击组标题可折叠
class ForumCategoryPage extends HookConsumerWidget {
  const ForumCategoryPage({
    required this.category,
    super.key,
    this.scrollToTop,
    this.onForumTap,
  });

  final ForumCategory category;
  final ScrollToTopSignal? scrollToTop;
  final ValueChanged<Forum>? onForumTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collapsedGroups = useState(<int>{});
    final scrollController = useScrollToTopController(scrollToTop);
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    // 只有一个组时组名通常与分类名相同，不再重复展示，也无需折叠
    final showGroupName = category.groups.length > 1;

    void toggleGroup(int index) {
      final groups = {...collapsedGroups.value};
      if (!groups.remove(index)) groups.add(index);
      collapsedGroups.value = groups;
    }

    final isAppleDesktop = context.isMacDesktopAppleStyle;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= kCompactBreakpoint;
        final horizontalPadding = isAppleDesktop
            ? 20.0
            : (isWide ? Dimen.spacingL : 0.0);
        final gridDelegate = SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: isAppleDesktop ? 156 : (isWide ? 136 : 120),
          mainAxisExtent: isAppleDesktop ? 104 : (isWide ? 112 : 108),
          crossAxisSpacing: isAppleDesktop ? 12 : 0,
          mainAxisSpacing: isAppleDesktop ? 12 : 0,
        );

        return RefreshIndicator.adaptive(
          onRefresh: () async {
            try {
              await ref.read(forumCategoryListProvider.notifier).refresh();
            } catch (error) {
              AppToast.error(error);
            }
          },
          child: CustomScrollView(
            controller: scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              if (isAppleDesktop && !showGroupName)
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
              for (final (index, group) in category.groups.indexed)
                // 组内标题吸顶，滚动到长分组中间也能直接折叠
                SliverMainAxisGroup(
                  slivers: [
                    if (showGroupName)
                      PinnedHeaderSliver(
                        child: _ForumGroupHeader(
                          group: group,
                          expanded: !collapsedGroups.value.contains(index),
                          horizontalPadding: isAppleDesktop
                              ? 20
                              : (isWide ? Dimen.spacingXL : Dimen.spacingL),
                          onTap: () => toggleGroup(index),
                        ),
                      ),
                    SliverVisibility(
                      visible: !collapsedGroups.value.contains(index),
                      sliver: SliverPadding(
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          isAppleDesktop ? 4 : 0,
                          horizontalPadding,
                          isAppleDesktop ? 18 : 0,
                        ),
                        sliver: SliverGrid.builder(
                          gridDelegate: gridDelegate,
                          itemCount: group.forumList.length,
                          itemBuilder: (_, i) => ForumGridItemWidget(
                            group.forumList[i],
                            onTap: onForumTap != null
                                ? () => onForumTap!(group.forumList[i])
                                : null,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              SliverToBoxAdapter(
                child: SizedBox(height: bottomPadding > 0 ? bottomPadding : 16),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ForumGroupHeader extends StatelessWidget {
  const _ForumGroupHeader({
    required this.group,
    required this.expanded,
    required this.horizontalPadding,
    required this.onTap,
  });

  final ForumGroup group;
  final bool expanded;
  final double horizontalPadding;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isApple = context.isAppleStyle;

    // 吸顶时需要不透明背景遮住下方滚动的网格
    return Material(
      color: colorScheme.surface,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            isApple ? 14 : 12,
            horizontalPadding,
            isApple ? 8 : 12,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  group.name,
                  style: isApple
                      ? TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurfaceVariant,
                          letterSpacing: 0.1,
                        )
                      : textTheme.titleSmall?.copyWith(
                          color: colorScheme.primary,
                        ),
                ),
              ),
              AnimatedRotation(
                turns: expanded ? 0 : -0.25,
                duration: Motion.resolveDuration(
                  context,
                  Motion.durationShort4,
                ),
                curve: Motion.emphasized,
                child: Icon(
                  AppIcons.expandMore(context),
                  size: isApple ? 14 : 22,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
