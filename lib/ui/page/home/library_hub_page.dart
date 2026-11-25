import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:flutter_nga/providers/home/home_drawer_header_provider.dart';
import 'package:flutter_nga/providers/home/home_provider.dart';
import 'package:flutter_nga/ui/page/favourite_topic_list/favourite_topic_list_page.dart';
import 'package:flutter_nga/ui/page/history/topic_history_list_page.dart';
import 'package:flutter_nga/ui/widget/adaptive/adaptive_controls.dart';

/// 顶级「收藏」Tab 聚合页：分段切换「贴子收藏」与「浏览历史」。
class LibraryHubPage extends ConsumerWidget {
  const LibraryHubPage({super.key});

  static const _segments = [
    AppSegment(value: 0, label: '贴子收藏'),
    AppSegment(value: 1, label: '浏览历史'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tab = ref.watch(libraryHubTabProvider);
    final accountSession = ref.watch(accountSessionVersionProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Container(
          color: colorScheme.surface,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: AppSegmentedControl<int>(
                segments: _segments,
                selected: tab,
                onChanged: (next) =>
                    ref.read(libraryHubTabProvider.notifier).setTab(next),
              ),
            ),
          ),
        ),
        Expanded(
          child: IndexedStack(
            index: tab,
            children: [
              FavouriteTopicListPage(
                key: ValueKey('library-fav-topics-$accountSession'),
                embedded: true,
                showAppBar: false,
              ),
              const TopicHistoryListPage(embedded: true, showAppBar: false),
            ],
          ),
        ),
      ],
    );
  }
}
