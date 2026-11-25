import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_nga/providers/message/message_block_list_provider.dart';
import 'package:flutter_nga/providers/message/send_message_provider.dart';
import 'package:flutter_nga/providers/settings/design_style_provider.dart';
import 'package:flutter_nga/ui/page/send_message/contact_edit_dialog.dart';
import 'package:flutter_nga/ui/widget/adaptive/app_icons.dart';
import 'package:flutter_nga/ui/widget/adaptive/app_scaffold.dart';
import 'package:flutter_nga/ui/widget/list_status_view.dart';
import 'package:flutter_nga/ui/widget/readable_width.dart';
import 'package:flutter_nga/utils/app_toast.dart';
import 'package:flutter_nga/utils/hooks/easy_refresh_hooks.dart';
import 'package:flutter_nga/utils/route.dart';

/// 短消息屏蔽列表：被屏蔽的用户无法与你对话。
class MessageBlockListPage extends HookConsumerWidget {
  const MessageBlockListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final refreshController = useEasyRefreshController();
    final loaded = useState(false);
    final users = ref.watch(messageBlockListProvider);
    final notifier = ref.read(messageBlockListProvider.notifier);
    final colorScheme = Theme.of(context).colorScheme;
    final isApple = context.isAppleStyle;

    Future<void> onRefresh() async {
      try {
        await notifier.refresh();
        if (!context.mounted) return;
        loaded.value = true;
        refreshController.finishRefresh();
      } catch (err) {
        if (!context.mounted) return;
        refreshController.finishRefresh(IndicatorResult.fail);
        AppToast.error(err);
      }
    }

    void add() {
      showDialog<void>(
        context: context,
        builder: (_) => ContactEditDialog(
          title: '屏蔽用户',
          callback: (text) async {
            final input = splitMessageUsers(text);
            if (input.isEmpty) {
              throw '请输入有效的 UID 或用户名';
            }
            final message = await notifier.add(input);
            AppToast.success(message ?? '已屏蔽');
          },
        ),
      );
    }

    useInitialRefresh(refreshController);

    return AppScaffold(
      title: const Text('屏蔽用户'),
      body: EasyRefresh(
        controller: refreshController,
        onRefresh: onRefresh,
        child: users.isEmpty
            ? CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  if (loaded.value)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: ListStatusView(
                        icon: Icons.person_off_outlined,
                        message: '未屏蔽任何用户\n被屏蔽的用户无法与你发起或回复对话',
                      ),
                    ),
                ],
              )
            : ReadableListPadding(
                builder: (context, padding) => ListView.separated(
                  padding: padding,
                  itemCount: users.length,
                  separatorBuilder: (_, _) => Divider(
                    height: isApple ? 0.5 : 1,
                    thickness: isApple ? 0.5 : 1,
                    indent: 16,
                    color: isApple
                        ? colorScheme.outlineVariant
                        : colorScheme.surfaceContainerHighest,
                  ),
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return ListTile(
                      title: Text(user.username),
                      subtitle: Text('UID: ${user.uid}'),
                      onTap: () => Routes.navigateTo(
                        context,
                        "${Routes.USER}?uid=${user.uid}",
                      ),
                      trailing: TextButton(
                        onPressed: () async {
                          try {
                            final message = await notifier.remove(user);
                            AppToast.success(message ?? '已解除屏蔽');
                          } catch (err) {
                            AppToast.error(err);
                          }
                        },
                        child: const Text('解除屏蔽'),
                      ),
                    );
                  },
                ),
              ),
      ),
      primaryAction: AppPrimaryAction(
        tooltip: '屏蔽用户',
        onPressed: add,
        icon: const Icon(Icons.person_off_outlined),
        appleIcon: Icon(AppIcons.add(context)),
      ),
    );
  }
}
