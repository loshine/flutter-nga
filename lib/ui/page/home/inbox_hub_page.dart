import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:flutter_nga/providers/home/home_drawer_header_provider.dart';
import 'package:flutter_nga/providers/home/home_provider.dart';
import 'package:flutter_nga/providers/notification/unread_count_provider.dart';
import 'package:flutter_nga/ui/page/conversation/conversation_list_page.dart';
import 'package:flutter_nga/ui/page/notification/notification_list_page.dart';
import 'package:flutter_nga/ui/widget/adaptive/adaptive_controls.dart';

/// 顶级「消息」Tab 聚合页：分段切换「短消息」与「提醒信息」，各自展示未读计数。
class InboxHubPage extends ConsumerWidget {
  const InboxHubPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tab = ref.watch(inboxHubTabProvider);
    final accountSession = ref.watch(accountSessionVersionProvider);
    final userInfo = ref.watch(homeDrawerHeaderProvider);
    ref.watch(unreadCountProvider);
    final unread = ref
        .read(unreadCountProvider.notifier)
        .countsFor(userInfo?.uid);
    final colorScheme = Theme.of(context).colorScheme;

    final segments = [
      AppSegment(
        value: 0,
        label: unread.messages > 0 ? '短消息 (${unread.messages})' : '短消息',
      ),
      AppSegment(
        value: 1,
        label: unread.notifications > 0 ? '提醒 (${unread.notifications})' : '提醒',
      ),
    ];

    return Column(
      children: [
        Container(
          color: colorScheme.surface,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: AppSegmentedControl<int>(
                segments: segments,
                selected: tab,
                onChanged: (next) =>
                    ref.read(inboxHubTabProvider.notifier).setTab(next),
              ),
            ),
          ),
        ),
        Expanded(
          child: IndexedStack(
            index: tab,
            children: [
              ConversationListPage(
                key: ValueKey('inbox-conversations-$accountSession'),
                embedded: true,
                showAppBar: false,
              ),
              NotificationListPage(
                key: ValueKey('inbox-notifications-$accountSession'),
                embedded: true,
                showAppBar: false,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
