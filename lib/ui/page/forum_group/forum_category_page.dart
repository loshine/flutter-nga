import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:flutter_nga/data/entity/forum.dart';
import 'package:flutter_nga/providers/forum/forum_category_list_provider.dart';
import 'package:flutter_nga/ui/widget/forum_grid_item_widget.dart';
import 'package:flutter_nga/utils/app_toast.dart';
import 'package:flutter_nga/utils/dimen.dart';

/// 单个版块分类页：按版块组分段展示，组标题下为三列网格，点击组标题可折叠
class ForumCategoryPage extends HookConsumerWidget {
  const ForumCategoryPage({required this.category, super.key});

  final ForumCategory category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collapsedGroups = useState(<int>{});

    final double itemHeight = 108;
    final double itemWidth = MediaQuery.sizeOf(context).width / 3;
    final gridDelegate = SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 3,
      childAspectRatio: itemWidth / itemHeight,
    );
    // 只有一个组时组名通常与分类名相同，不再重复展示，也无需折叠
    final showGroupName = category.groups.length > 1;

    void toggleGroup(int index) {
      final groups = {...collapsedGroups.value};
      if (!groups.remove(index)) groups.add(index);
      collapsedGroups.value = groups;
    }

    return RefreshIndicator(
      onRefresh: () async {
        try {
          await ref.read(forumCategoryListProvider.notifier).refresh();
        } catch (error) {
          AppToast.error(error);
        }
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          for (final (index, group) in category.groups.indexed)
            // 组内标题吸顶，滚动到长分组中间也能直接折叠
            SliverMainAxisGroup(
              slivers: [
                if (showGroupName)
                  PinnedHeaderSliver(
                    child: _ForumGroupHeader(
                      group: group,
                      expanded: !collapsedGroups.value.contains(index),
                      onTap: () => toggleGroup(index),
                    ),
                  ),
                SliverVisibility(
                  visible: !collapsedGroups.value.contains(index),
                  sliver: SliverGrid.builder(
                    gridDelegate: gridDelegate,
                    itemCount: group.forumList.length,
                    itemBuilder: (_, i) =>
                        ForumGridItemWidget(group.forumList[i]),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _ForumGroupHeader extends StatelessWidget {
  const _ForumGroupHeader({
    required this.group,
    required this.expanded,
    required this.onTap,
  });

  final ForumGroup group;
  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // 吸顶时需要不透明背景遮住下方滚动的网格
    return Material(
      color: colorScheme.surface,
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: Dimen.spacingL),
        title: Text(
          group.name,
          style: textTheme.titleSmall?.copyWith(color: colorScheme.primary),
        ),
        trailing: AnimatedRotation(
          turns: expanded ? 0 : -0.25,
          duration: const Duration(milliseconds: 200),
          child: Icon(Icons.expand_more, color: colorScheme.onSurfaceVariant),
        ),
        onTap: onTap,
      ),
    );
  }
}
