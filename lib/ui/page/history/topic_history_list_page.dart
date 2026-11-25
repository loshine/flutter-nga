import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_nga/data/entity/topic_history.dart';
import 'package:flutter_nga/providers/topic/topic_history_list_provider.dart';
import 'package:flutter_nga/ui/widget/adaptive/app_icons.dart';
import 'package:flutter_nga/ui/widget/adaptive/app_scaffold.dart';
import 'package:flutter_nga/ui/widget/adaptive_layout.dart';
import 'package:flutter_nga/ui/widget/list_status_view.dart';
import 'package:flutter_nga/ui/widget/m3_dialog.dart';
import 'package:flutter_nga/ui/widget/readable_width.dart';
import 'package:flutter_nga/ui/widget/topic_history_list_item_widget.dart';
import 'package:flutter_nga/utils/app_snack_bar.dart';
import 'package:flutter_nga/utils/app_toast.dart';
import 'package:flutter_nga/utils/haptics.dart';
import 'package:flutter_nga/utils/hooks/easy_refresh_hooks.dart';

class TopicHistoryListPage extends HookConsumerWidget {
  const TopicHistoryListPage({
    super.key,
    this.embedded = false,
    this.showAppBar = true,
    this.leading,
  });

  final bool embedded;
  final bool showAppBar;
  final Widget? leading;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final refreshController = useEasyRefreshController(controlFinishLoad: true);
    final selectedTopic = useState<SelectedTopic?>(null);
    final historyState = ref.watch(topicHistoryListProvider);
    final notifier = ref.read(topicHistoryListProvider.notifier);
    final messenger = ScaffoldMessenger.of(context);

    Future<void> onRefresh() async {
      try {
        await notifier.refresh();
        if (!context.mounted) return;
        refreshController.finishRefresh();
        refreshController.resetFooter();
      } catch (err) {
        if (!context.mounted) return;
        refreshController.finishRefresh(IndicatorResult.fail);
        AppToast.error(err);
      }
    }

    Future<void> onLoading() async {
      try {
        final next = await notifier.loadMore();
        if (!context.mounted) return;
        if (next.enablePullUp) {
          refreshController.finishLoad();
        } else {
          refreshController.finishLoad(IndicatorResult.noMore);
        }
      } catch (err) {
        if (!context.mounted) return;
        refreshController.finishLoad(IndicatorResult.fail);
        AppToast.error(err);
      }
    }

    useInitialRefresh(refreshController);

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

    void remove(TopicHistory history) {
      final id = history.id;
      if (id == null) return;
      notifier.removeLocally(history);
      AppSnackBar.undo(
        context,
        message: '已删除浏览记录',
        onUndo: () => notifier.undoDeletion(id),
        onCommit: () => notifier.commitDeletion(id).catchError((err) {
          AppToast.error(err);
        }),
      );
    }

    void selectHistory(TopicHistory history) {
      selectedTopic.value = SelectedTopic(
        tid: history.tid,
        fid: history.fid,
        subject: history.subject,
      );
    }

    return MasterDetailLayout(
      masterBuilder: (context, isTwoPane) => AppScaffold(
        embedded: embedded,
        showAppBar: showAppBar,
        leading: leading,
        title: const Text('浏览历史'),
        actions: [
          IconButton(
            icon: Icon(AppIcons.delete(context)),
            tooltip: '清空浏览历史',
            onPressed: historyState.list.isEmpty
                ? null
                : () => _showCleanDialog(
                    context,
                    notifier,
                    refreshController,
                    onCleaned: () => selectedTopic.value = null,
                  ),
          ),
        ],
        body: EasyRefresh(
          controller: refreshController,
          onRefresh: onRefresh,
          onLoad: historyState.enablePullUp ? onLoading : null,
          child: _buildChild(
            context,
            historyState,
            remove,
            selectedTid: isTwoPane ? selectedTopic.value?.tid : null,
            onSelect: isTwoPane ? selectHistory : null,
          ),
        ),
      ),
      detailBuilder: (context) => TopicDetailPane(
        selected: selectedTopic.value,
        emptySubtitle: '从左侧历史记录选择一篇帖子继续阅读',
        onClose: () => selectedTopic.value = null,
      ),
    );
  }

  Widget _buildListItem(
    BuildContext context,
    dynamic itemData,
    ValueChanged<TopicHistory> onRemove, {
    int? selectedTid,
    ValueChanged<TopicHistory>? onSelect,
  }) {
    if (itemData is TopicHistory) {
      return _HistoryDismissibleItem(
        key: ValueKey('history-${itemData.id}'),
        history: itemData,
        selected: selectedTid != null && selectedTid == itemData.tid,
        onTap: onSelect != null ? () => onSelect(itemData) : null,
        onRemove: () => onRemove(itemData),
      );
    } else {
      final theme = Theme.of(context);
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Text(
          itemData ?? "",
          style: theme.textTheme.titleSmall?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }
  }

  void _showCleanDialog(
    BuildContext context,
    TopicHistoryListNotifier notifier,
    EasyRefreshController refreshController, {
    VoidCallback? onCleaned,
  }) {
    showDialog(
      context: context,
      builder: (_) => M3ConfirmDialog(
        title: '清空浏览历史',
        content: '将删除本机保存的全部浏览历史，此操作不可恢复。',
        confirmText: '清空',
        destructive: true,
        onConfirm: () {
          notifier
              .clean()
              .then((_) => onCleaned?.call())
              .catchError((err) {
                AppToast.error(err);
                return 0;
              })
              .whenComplete(() {
                refreshController.callRefresh();
              });
        },
      ),
    );
  }

  Widget _buildChild(
    BuildContext context,
    TopicHistoryListState historyState,
    ValueChanged<TopicHistory> onRemove, {
    int? selectedTid,
    ValueChanged<TopicHistory>? onSelect,
  }) {
    if (historyState.list.isNotEmpty) {
      return ReadableListPadding(
        builder: (context, padding) => ListView.builder(
          padding: padding,
          itemCount: historyState.list.length,
          itemBuilder: (_, position) => _buildListItem(
            context,
            historyState.list[position],
            onRemove,
            selectedTid: selectedTid,
            onSelect: onSelect,
          ),
        ),
      );
    } else {
      return const CustomScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: ListStatusView(icon: Icons.history, message: '暂无浏览历史'),
          ),
        ],
      );
    }
  }
}

class _HistoryDismissibleItem extends StatefulWidget {
  const _HistoryDismissibleItem({
    super.key,
    required this.history,
    required this.onRemove,
    this.onTap,
    this.selected = false,
  });

  final TopicHistory history;
  final VoidCallback onRemove;
  final VoidCallback? onTap;
  final bool selected;

  @override
  State<_HistoryDismissibleItem> createState() =>
      _HistoryDismissibleItemState();
}

class _HistoryDismissibleItemState extends State<_HistoryDismissibleItem> {
  final _menuKey = GlobalKey<PopupMenuButtonState<String>>();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Dismissible(
      key: ValueKey('dismiss-history-${widget.history.id}'),
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
          semanticLabel: '删除记录',
        ),
      ),
      child: TopicHistoryListItemWidget(
        topicHistory: widget.history,
        selected: widget.selected,
        onTap: widget.onTap,
        onLongPress: () => _menuKey.currentState?.showButtonMenu(),
        trailing: PopupMenuButton<String>(
          key: _menuKey,
          tooltip: '更多操作',
          onSelected: (_) => widget.onRemove(),
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'delete', child: Text('删除记录')),
          ],
        ),
      ),
    );
  }
}
