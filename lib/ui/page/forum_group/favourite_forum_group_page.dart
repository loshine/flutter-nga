import 'dart:math' as math;

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:flutter_nga/data/entity/forum.dart';
import 'package:flutter_nga/providers/forum/favourite_forum_list_provider.dart';
import 'package:flutter_nga/providers/forum/favourite_forum_provider.dart';
import 'package:flutter_nga/providers/settings/design_style_provider.dart';
import 'package:flutter_nga/ui/widget/adaptive/adaptive_controls.dart';
import 'package:flutter_nga/ui/widget/adaptive_layout.dart';
import 'package:flutter_nga/ui/widget/forum_grid_item_widget.dart';
import 'package:flutter_nga/ui/widget/m3_dialog.dart';
import 'package:flutter_nga/utils/app_toast.dart';
import 'package:flutter_nga/utils/dimen.dart';
import 'package:flutter_nga/utils/hooks/easy_refresh_hooks.dart';
import 'package:flutter_nga/utils/hooks/scroll_to_top.dart';

class FavouriteForumGroupPage extends StatefulHookConsumerWidget {
  const FavouriteForumGroupPage({super.key, this.scrollToTop, this.onForumTap});

  final ScrollToTopSignal? scrollToTop;
  final ValueChanged<Forum>? onForumTap;

  @override
  ConsumerState<FavouriteForumGroupPage> createState() =>
      _FavouriteForumGroupState();
}

class _FavouriteForumGroupState extends ConsumerState<FavouriteForumGroupPage> {
  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(favouriteForumListProvider.notifier);
    final scrollController = useScrollToTopController(widget.scrollToTop);
    usePostFrameEffect(() {
      notifier.refresh().catchError(AppToast.error);
    });

    final state = ref.watch(favouriteForumListProvider);
    final forums = state.forums;
    final mediaPadding = MediaQuery.paddingOf(context);

    final isAppleDesktop = context.isMacDesktopAppleStyle;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= kCompactBreakpoint;
        final baseHorizontal = isAppleDesktop
            ? 20.0
            : (isWide ? Dimen.spacingL : 0.0);
        return Stack(
          children: [
            RefreshIndicator.adaptive(
              onRefresh: () async {
                try {
                  await notifier.refresh();
                } catch (error) {
                  AppToast.error(error);
                }
              },
              child: GridView.builder(
                controller: scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  math.max(baseHorizontal, mediaPadding.left),
                  isAppleDesktop ? 16 : (isWide ? Dimen.spacingS : 0),
                  math.max(baseHorizontal, mediaPadding.right),
                  mediaPadding.bottom + (context.isAppleStyle ? 16 : 88),
                ),
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: isAppleDesktop
                      ? 156
                      : (isWide ? 136 : 120),
                  mainAxisExtent: isAppleDesktop ? 104 : (isWide ? 112 : 108),
                  crossAxisSpacing: isAppleDesktop ? 12 : 0,
                  mainAxisSpacing: isAppleDesktop ? 12 : 0,
                ),
                itemCount: forums.length,
                itemBuilder: (_, index) => ForumGridItemWidget(
                  forums[index],
                  onTap: widget.onForumTap != null
                      ? () => widget.onForumTap!(forums[index])
                      : null,
                  onLongPress: () => _showDeleteDialog(notifier, forums[index]),
                  onSecondaryTapDown: (_) =>
                      _showDeleteDialog(notifier, forums[index]),
                ),
              ),
            ),
            if (state.isSyncing && forums.isEmpty)
              const Center(child: AppActivityIndicator()),
          ],
        );
      },
    );
  }

  void _showDeleteDialog(FavouriteForumListNotifier notifier, Forum forum) {
    showDialog(
      context: context,
      builder: (dialogContext) => Consumer(
        builder: (context, ref, _) {
          final isBusy = ref.watch(favouriteForumBusyProvider(forum.identity));
          final colorScheme = Theme.of(context).colorScheme;
          return M3Dialog(
            title: '移除收藏版面',
            content: Text(
              '确定从我的收藏中移除「${forum.name}」吗？',
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
            actions: [
              TextButton(
                onPressed: isBusy
                    ? null
                    : () => Navigator.of(dialogContext).pop(),
                child: const Text('取消'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: colorScheme.error,
                  foregroundColor: colorScheme.onError,
                ),
                onPressed: isBusy
                    ? null
                    : () async {
                        try {
                          await notifier.delete(forum);
                          if (dialogContext.mounted) {
                            Navigator.of(dialogContext).pop();
                          }
                        } catch (error) {
                          AppToast.error(error);
                        }
                      },
                child: const Text('移除'),
              ),
            ],
          );
        },
      ),
    );
  }
}
