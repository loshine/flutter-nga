import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_nga/providers/settings/blocklist_settings_provider.dart';
import 'package:flutter_nga/ui/widget/adaptive/app_icons.dart';
import 'package:flutter_nga/ui/widget/adaptive/app_scaffold.dart';
import 'package:flutter_nga/ui/widget/list_status_view.dart';
import 'package:flutter_nga/ui/widget/m3_dialog.dart';
import 'package:flutter_nga/ui/widget/readable_width.dart';
import 'package:flutter_nga/utils/app_snack_bar.dart';
import 'package:flutter_nga/utils/app_toast.dart';
import 'package:flutter_nga/utils/code_utils.dart' as code_utils;
import 'package:flutter_nga/utils/haptics.dart';
import 'package:flutter_nga/utils/hooks/easy_refresh_hooks.dart';

import 'blocklist_edit_dialog.dart';

class BlocklistKeywordsPage extends HookConsumerWidget {
  const BlocklistKeywordsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    usePostFrameEffect(() {
      ref.read(blocklistSettingsProvider.notifier).load();
    });

    final state = ref.watch(blocklistSettingsProvider);
    final notifier = ref.read(blocklistSettingsProvider.notifier);
    final activeUndo = useRef<UndoSnackBarHandle?>(null);
    final colorScheme = Theme.of(context).colorScheme;

    useEffect(() {
      return () {
        if (!notifier.hasPendingWordDeletion) return;
        activeUndo.value?.dismiss();
        activeUndo.value = null;
        notifier.commitAllPendingWordDeletions().then((err) {
          if (err != null) AppToast.error(err);
        });
      };
    }, [notifier]);

    useOnAppLifecycleStateChange((_, lifecycle) {
      if ((lifecycle == AppLifecycleState.paused ||
              lifecycle == AppLifecycleState.hidden) &&
          notifier.hasPendingWordDeletion) {
        activeUndo.value?.dismiss();
        activeUndo.value = null;
      }
    });

    void remove(String word) {
      final displayWord = code_utils.unescapeHtml(word);
      notifier.removeWordLocally(word);
      activeUndo.value = AppSnackBar.undo(
        context,
        message: '已移除屏蔽关键词「$displayWord」',
        onUndo: () => notifier.undoWordDeletion(word),
        onCommit: () => notifier.commitWordDeletion(word).catchError((err) {
          AppToast.error(err);
          return null;
        }),
      );
    }

    return AppScaffold(
      title: const Text("屏蔽关键词"),
      actions: [
        IconButton(
          onPressed: state.blockWordList.isEmpty
              ? null
              : () => _confirmDeleteAll(context, notifier),
          icon: Icon(AppIcons.delete(context)),
          tooltip: "删除所有屏蔽关键词",
        ),
      ],
      body: state.blockWordList.isEmpty
          ? const ListStatusView(icon: Icons.block_outlined, message: '暂无屏蔽关键词')
          : ReadableListPadding(
              builder: (context, padding) => ListView.builder(
                padding: padding,
                itemCount: state.blockWordList.length,
                itemBuilder: (context, index) {
                  final word = state.blockWordList[index];
                  final displayWord = code_utils.unescapeHtml(word);
                  return Dismissible(
                    key: ValueKey('block-word-$word'),
                    direction: DismissDirection.endToStart,
                    onUpdate: AppHaptics.onDismissUpdate,
                    onDismissed: (_) => remove(word),
                    background: Container(
                      color: colorScheme.errorContainer,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Icon(
                        Icons.delete_outline,
                        color: colorScheme.onErrorContainer,
                        semanticLabel: '移除屏蔽',
                      ),
                    ),
                    child: ListTile(
                      title: Text(displayWord),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        tooltip: '移除屏蔽',
                        onPressed: () => remove(word),
                      ),
                    ),
                  );
                },
              ),
            ),
      primaryAction: AppPrimaryAction(
        tooltip: "添加屏蔽关键词",
        onPressed: () => _showAddDialog(context, notifier),
        icon: const Icon(Icons.add),
        appleIcon: Icon(AppIcons.add(context)),
      ),
    );
  }

  void _confirmDeleteAll(
    BuildContext context,
    BlocklistSettingsNotifier notifier,
  ) {
    showDialog(
      context: context,
      builder: (_) => M3ConfirmDialog(
        title: "删除所有屏蔽关键词",
        content: "将清空全部屏蔽关键词并同步到账号，此操作不可恢复。",
        confirmText: "全部删除",
        destructive: true,
        onConfirm: () => _deleteAll(notifier),
      ),
    );
  }

  Future<void> _deleteAll(BlocklistSettingsNotifier notifier) async {
    try {
      AppToast.success(await notifier.deleteAllWords());
    } catch (e) {
      AppToast.error(e);
    }
  }

  Future<void> _add(BlocklistSettingsNotifier notifier, String word) async {
    try {
      AppToast.success(await notifier.addWord(word));
    } catch (e) {
      AppToast.error(e);
    }
  }

  void _showAddDialog(
    BuildContext context,
    BlocklistSettingsNotifier notifier,
  ) {
    showDialog(
      context: context,
      builder: (_) {
        return BlocklistEditDialog(
          title: "添加屏蔽词语",
          inputHint: "需要屏蔽的关键词",
          callback: (word) => _add(notifier, word),
        );
      },
    );
  }
}
