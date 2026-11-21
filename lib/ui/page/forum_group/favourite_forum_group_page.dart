import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:flutter_nga/data/entity/forum.dart';
import 'package:flutter_nga/providers/forum/favourite_forum_list_provider.dart';
import 'package:flutter_nga/providers/forum/favourite_forum_provider.dart';
import 'package:flutter_nga/ui/widget/forum_grid_item_widget.dart';
import 'package:flutter_nga/utils/app_toast.dart';
import 'package:flutter_nga/utils/hooks/easy_refresh_hooks.dart';
import 'package:flutter_nga/utils/hooks/scroll_to_top.dart';
import 'package:flutter_nga/utils/route.dart';

class FavouriteForumGroupPage extends StatefulHookConsumerWidget {
  const FavouriteForumGroupPage({super.key, this.scrollToTop});

  final ScrollToTopSignal? scrollToTop;

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
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return Stack(
      children: [
        RefreshIndicator(
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
            padding: EdgeInsets.only(bottom: bottomPadding + 88),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 120,
              mainAxisExtent: 108,
            ),
            itemCount: forums.length,
            itemBuilder: (_, index) => ForumGridItemWidget(
              forums[index],
              onLongPress: () => _showDeleteDialog(notifier, forums[index]),
            ),
          ),
        ),
        if (state.isSyncing && forums.isEmpty)
          const Center(child: CircularProgressIndicator()),
      ],
    );
  }

  void _showDeleteDialog(FavouriteForumListNotifier notifier, Forum forum) {
    showDialog(
      context: context,
      builder: (dialogContext) => Consumer(
        builder: (context, ref, _) {
          final isBusy = ref.watch(favouriteForumBusyProvider(forum.identity));
          return AlertDialog(
            title: const Text('提示'),
            content: const Text('是否删除该版面'),
            actions: <Widget>[
              TextButton(
                onPressed: isBusy ? null : () => Routes.pop(dialogContext),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: isBusy
                    ? null
                    : () async {
                        try {
                          await notifier.delete(forum);
                          if (dialogContext.mounted) {
                            Routes.pop(dialogContext);
                          }
                        } catch (error) {
                          AppToast.error(error);
                        }
                      },
                child: const Text('确认'),
              ),
            ],
          );
        },
      ),
    );
  }
}
