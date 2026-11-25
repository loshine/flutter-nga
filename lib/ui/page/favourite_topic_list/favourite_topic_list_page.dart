import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_nga/data/entity/topic.dart';
import 'package:flutter_nga/providers/topic/favourite_topic_list_provider.dart';
import 'package:flutter_nga/ui/widget/adaptive_layout.dart';
import 'package:flutter_nga/ui/widget/list_status_view.dart';
import 'package:flutter_nga/ui/widget/readable_width.dart';
import 'package:flutter_nga/ui/widget/topic_list_item_widget.dart';
import 'package:flutter_nga/utils/app_snack_bar.dart';
import 'package:flutter_nga/utils/app_toast.dart';
import 'package:flutter_nga/utils/haptics.dart';
import 'package:flutter_nga/utils/hooks/easy_refresh_hooks.dart';
import 'package:flutter_nga/utils/hooks/list_load_status.dart';

class FavouriteTopicListPage extends HookConsumerWidget {
  const FavouriteTopicListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final refreshController = useEasyRefreshController(controlFinishLoad: true);
    final loadStatus = useListLoadStatus();
    final selectedTopic = useState<SelectedTopic?>(null);
    final state = ref.watch(favouriteTopicListProvider);
    final notifier = ref.read(favouriteTopicListProvider.notifier);

    Future<void> onRefresh() async {
      try {
        await notifier.refresh();
        if (!context.mounted) return;
        loadStatus.succeed();
        refreshController.finishRefresh();
        refreshController.resetFooter();
      } catch (err) {
        if (!context.mounted) return;
        refreshController.finishRefresh(IndicatorResult.fail);
        final hasData = ref.read(favouriteTopicListProvider).list.isNotEmpty;
        if (!loadStatus.fail(err, hasData: hasData)) AppToast.error(err);
      }
    }

    Future<void> onLoading() async {
      try {
        final next = await notifier.loadMore();
        if (!context.mounted) return;
        if (next.page + 1 < next.maxPage) {
          refreshController.finishLoad();
        } else {
          refreshController.finishLoad(IndicatorResult.noMore);
        }
      } catch (_) {
        if (!context.mounted) return;
        refreshController.finishLoad(IndicatorResult.fail);
      }
    }

    useInitialRefresh(refreshController);

    final messenger = ScaffoldMessenger.of(context);

    // 离开页面、App 退到后台时关掉撤销提示，使待删条目立即提交
    useEffect(() {
      return () {
        if (!notifier.hasPendingDeletion) return;
        messenger.hideCurrentSnackBar();
        notifier.commitAllDeletions().then((err) {
          if (err != null) AppToast.error(err);
        });
      };
    }, [notifier, messenger]);
    useOnAppLifecycleStateChange((_, lifecycle) {
      if (lifecycle == AppLifecycleState.paused &&
          notifier.hasPendingDeletion) {
        messenger.hideCurrentSnackBar();
      }
    });

    void remove(Topic topic) {
      final tid = topic.tid;
      if (tid == null) return;
      notifier.removeLocally(topic);
      AppSnackBar.undo(
        context,
        message: '已取消收藏',
        onUndo: () => notifier.undoDeletion(tid),
        onCommit: () => notifier.commitDeletion(tid).catchError((err) {
          AppToast.error(err);
          return null;
        }),
      );
    }

    void selectTopic(Topic topic) {
      final tid = topic.tid;
      if (tid == null) return;
      selectedTopic.value = SelectedTopic(
        tid: tid,
        fid: topic.fid,
        subject: topic.subject,
      );
    }

    return MasterDetailLayout(
      masterBuilder: (context, isTwoPane) => Scaffold(
        appBar: AppBar(title: const Text('贴子收藏')),
        body: EasyRefresh(
          controller: refreshController,
          onRefresh: onRefresh,
          onLoad: state.enablePullUp ? onLoading : null,
          child: ListStatusSwitcher(
            status: loadStatus,
            isEmpty: state.list.isEmpty,
            emptyMessage: '暂无收藏',
            emptyIcon: Icons.favorite_border,
            onRetry: refreshController.callRefresh,
            child: ReadableListPadding(
              builder: (context, padding) => ListView.builder(
                padding: padding,
                itemCount: state.list.length,
                itemBuilder: (context, index) {
                  final topic = state.list[index];
                  return _FavouriteTopicItem(
                    key: ValueKey(topic.tid),
                    topic: topic,
                    selected:
                        isTwoPane && selectedTopic.value?.tid == topic.tid,
                    onTap: isTwoPane ? () => selectTopic(topic) : null,
                    onRemove: () => remove(topic),
                  );
                },
              ),
            ),
          ),
        ),
      ),
      detailBuilder: (context) => TopicDetailPane(
        selected: selectedTopic.value,
        emptySubtitle: '从左侧收藏列表选择一篇帖子查看详情',
        onClose: () => selectedTopic.value = null,
      ),
    );
  }
}

/// 收藏条目：行尾菜单是主入口，左滑和长按是快捷方式。
class _FavouriteTopicItem extends StatefulWidget {
  const _FavouriteTopicItem({
    super.key,
    required this.topic,
    required this.onRemove,
    this.onTap,
    this.selected = false,
  });

  final Topic topic;
  final VoidCallback onRemove;
  final VoidCallback? onTap;
  final bool selected;

  @override
  State<_FavouriteTopicItem> createState() => _FavouriteTopicItemState();
}

class _FavouriteTopicItemState extends State<_FavouriteTopicItem> {
  final _menuKey = GlobalKey<PopupMenuButtonState<String>>();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Dismissible(
      key: ValueKey('dismiss-${widget.topic.tid}'),
      direction: DismissDirection.endToStart,
      onUpdate: AppHaptics.onDismissUpdate,
      onDismissed: (_) => widget.onRemove(),
      background: Container(
        color: colorScheme.errorContainer,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Icon(
          Icons.delete_outline,
          color: colorScheme.onErrorContainer,
          semanticLabel: '取消收藏',
        ),
      ),
      child: TopicListItemWidget(
        topic: widget.topic,
        selected: widget.selected,
        onTap: widget.onTap,
        // 长按弹出与行尾按钮相同的菜单
        onLongPress: () => _menuKey.currentState?.showButtonMenu(),
        trailing: PopupMenuButton<String>(
          key: _menuKey,
          tooltip: '更多操作',
          onSelected: (_) => widget.onRemove(),
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'remove', child: Text('取消收藏')),
          ],
        ),
      ),
    );
  }
}
