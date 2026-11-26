import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_nga/providers/message/conversation_list_provider.dart';
import 'package:flutter_nga/ui/page/conversation/conversation_detail_page.dart';
import 'package:flutter_nga/ui/widget/adaptive/app_icons.dart';
import 'package:flutter_nga/ui/widget/adaptive/app_scaffold.dart';
import 'package:flutter_nga/ui/widget/adaptive_layout.dart';
import 'package:flutter_nga/ui/widget/list_status_view.dart';
import 'package:flutter_nga/ui/widget/readable_width.dart';
import 'package:flutter_nga/utils/app_toast.dart';
import 'package:flutter_nga/utils/hooks/easy_refresh_hooks.dart';
import 'package:flutter_nga/utils/hooks/list_load_status.dart';
import 'package:flutter_nga/utils/route.dart';

import 'conversation_item_widget.dart';

class ConversationListPage extends HookConsumerWidget {
  const ConversationListPage({
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
    final loadStatus = useListLoadStatus();
    final selectedMid = useState<int?>(null);
    final state = ref.watch(conversationListProvider);
    final notifier = ref.read(conversationListProvider.notifier);

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
        final hasData = ref.read(conversationListProvider).list.isNotEmpty;
        if (!loadStatus.fail(err, hasData: hasData)) AppToast.error(err);
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
      } catch (_) {
        if (!context.mounted) return;
        refreshController.finishLoad(IndicatorResult.fail);
      }
    }

    useInitialRefresh(refreshController);

    return MasterDetailLayout(
      masterBuilder: (context, isTwoPane) => AppScaffold(
        embedded: embedded,
        showAppBar: showAppBar,
        leading: leading,
        title: const Text('短消息'),
        actions: [
          IconButton(
            tooltip: '屏蔽用户',
            icon: Icon(AppIcons.block(context)),
            onPressed: () =>
                Routes.navigateTo(context, Routes.MESSAGE_BLOCKLIST),
          ),
        ],
        body: EasyRefresh(
          controller: refreshController,
          onRefresh: onRefresh,
          onLoad: state.enablePullUp ? onLoading : null,
          child: ListStatusSwitcher(
            status: loadStatus,
            isEmpty: state.list.isEmpty,
            emptyMessage: '暂无短消息',
            emptyIcon: Icons.mail_outline,
            onRetry: refreshController.callRefresh,
            child: ReadableListPadding(
              builder: (context, padding) => ListView.builder(
                padding: padding,
                itemCount: state.list.length,
                itemBuilder: (context, index) {
                  final conversation = state.list[index];
                  return ConversationItemWidget(
                    conversation: conversation,
                    selected:
                        isTwoPane && selectedMid.value == conversation.mid,
                    onTap: isTwoPane && conversation.mid != null
                        ? () => selectedMid.value = conversation.mid
                        : null,
                    onLeft: refreshController.callRefresh,
                  );
                },
              ),
            ),
          ),
        ),
        primaryAction: AppPrimaryAction(
          tooltip: '新建短消息',
          onPressed: () async {
            final sent = await Routes.navigateTo(
              context,
              "${Routes.SEND_MESSAGE}?mid=0",
            );
            if (sent == true && context.mounted) {
              refreshController.callRefresh();
            }
          },
          icon: const Icon(Icons.edit_outlined),
          appleIcon: Icon(AppIcons.edit(context)),
        ),
      ),
      detailBuilder: (context) {
        final mid = selectedMid.value;
        if (mid == null) {
          return const MasterDetailEmptyPlaceholder(
            icon: Icons.mail_outline,
            title: '选择一段对话查看消息',
            subtitle: '点击新建按钮可发起短消息',
          );
        }
        return ConversationDetailPage(
          key: ValueKey('embedded-conversation-$mid'),
          mid: mid,
          embedded: true,
          onLeft: () {
            selectedMid.value = null;
            refreshController.callRefresh();
          },
          onClose: () => selectedMid.value = null,
        );
      },
    );
  }
}
