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

class BlocklistUsersPage extends HookConsumerWidget {
  const BlocklistUsersPage({super.key});

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
        if (!notifier.hasPendingUserDeletion) return;
        activeUndo.value?.dismiss();
        activeUndo.value = null;
        notifier.commitAllPendingUserDeletions().then((err) {
          if (err != null) AppToast.error(err);
        });
      };
    }, [notifier]);

    useOnAppLifecycleStateChange((_, lifecycle) {
      if ((lifecycle == AppLifecycleState.paused ||
              lifecycle == AppLifecycleState.hidden) &&
          notifier.hasPendingUserDeletion) {
        activeUndo.value?.dismiss();
        activeUndo.value = null;
      }
    });

    void remove(String user) {
      final displayName = code_utils.unescapeHtml(user);
      notifier.removeUserLocally(user);
      activeUndo.value = AppSnackBar.undo(
        context,
        message: '已移除屏蔽用户「$displayName」',
        onUndo: () => notifier.undoUserDeletion(user),
        onCommit: () => notifier.commitUserDeletion(user).catchError((err) {
          AppToast.error(err);
          return null;
        }),
      );
    }

    return AppScaffold(
      title: const Text("屏蔽用户"),
      actions: [
        IconButton(
          onPressed: state.blockUserList.isEmpty
              ? null
              : () => _confirmDeleteAll(context, notifier),
          icon: Icon(AppIcons.delete(context)),
          tooltip: "删除所有屏蔽用户",
        ),
      ],
      body: state.blockUserList.isEmpty
          ? const ListStatusView(
              icon: Icons.person_off_outlined,
              message: '暂无屏蔽用户',
            )
          : ReadableListPadding(
              builder: (context, padding) => ListView.builder(
                padding: padding,
                itemCount: state.blockUserList.length,
                itemBuilder: (context, index) {
                  final user = state.blockUserList[index];
                  final displayName = code_utils.unescapeHtml(user);
                  return Dismissible(
                    key: ValueKey('block-user-$user'),
                    direction: DismissDirection.endToStart,
                    onUpdate: AppHaptics.onDismissUpdate,
                    onDismissed: (_) => remove(user),
                    background: Container(
                      color: colorScheme.errorContainer,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Icon(
                        AppIcons.delete(context),
                        color: colorScheme.onErrorContainer,
                        semanticLabel: '移除屏蔽',
                      ),
                    ),
                    child: ListTile(
                      title: Text(displayName),
                      trailing: IconButton(
                        icon: Icon(AppIcons.delete(context)),
                        tooltip: '移除屏蔽',
                        onPressed: () => remove(user),
                      ),
                    ),
                  );
                },
              ),
            ),
      primaryAction: AppPrimaryAction(
        tooltip: "添加屏蔽用户",
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
        title: "删除所有屏蔽用户",
        content: "将清空全部屏蔽用户并同步到账号，此操作不可恢复。",
        confirmText: "全部删除",
        destructive: true,
        onConfirm: () => _deleteAll(notifier),
      ),
    );
  }

  Future<void> _deleteAll(BlocklistSettingsNotifier notifier) async {
    try {
      AppToast.success(await notifier.deleteAllUsers());
    } catch (e) {
      AppToast.error(e);
    }
  }

  Future<void> _add(BlocklistSettingsNotifier notifier, String user) async {
    AppToast.success(await notifier.addUser(user));
  }

  void _showAddDialog(
    BuildContext context,
    BlocklistSettingsNotifier notifier,
  ) {
    showDialog(
      context: context,
      builder: (_) {
        return BlocklistEditDialog(
          title: "添加屏蔽用户",
          inputHint: "UID 或 用户名",
          callback: (user) => _add(notifier, user),
        );
      },
    );
  }
}
