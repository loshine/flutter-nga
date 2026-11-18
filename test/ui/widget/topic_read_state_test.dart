import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:flutter_nga/data/entity/topic.dart';
import 'package:flutter_nga/data/repository/topic_repository.dart';
import 'package:flutter_nga/providers/core/repository_providers.dart';
import 'package:flutter_nga/providers/topic/topic_history_provider.dart';
import 'package:flutter_nga/ui/widget/topic_list_item_widget.dart';

class _FakeHistoryRepository implements TopicRepository {
  _FakeHistoryRepository(this.ids);

  Set<int> ids;
  int loads = 0;

  @override
  Future<Set<int>> getHistoryTopicIds() async {
    loads++;
    return ids;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// topic_misc 首字节为 1 时第 5 字节是样式位，1 = 红色标题
const _redMisc = 'AQAAAAEA';

Future<Color?> _titleColor(
  WidgetTester tester, {
  required Set<int> readIds,
  String? topicMisc,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        topicRepositoryProvider.overrideWithValue(
          _FakeHistoryRepository(readIds),
        ),
      ],
      child: MaterialApp(
        theme: ThemeData(colorSchemeSeed: Colors.indigo),
        home: Scaffold(
          body: TopicListItemWidget(
            topic: Topic(
              tid: 1,
              fid: 10,
              author: '作者',
              subject: '帖子标题',
              topicMisc: topicMisc,
              lastPost: 0,
              replies: 0,
              type: 0,
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  final rich = tester.widget<RichText>(
    find.textContaining('帖子标题', findRichText: true).first,
  );
  // Text.rich 外层是 DefaultTextStyle 的根 span，标题 span 在 children 里
  final root = rich.text as TextSpan;
  return root.children?.first.style?.color ?? root.style?.color;
}

void main() {
  group('ReadTopicIdsNotifier', () {
    test('loads history tids once and marks new reads', () async {
      final repository = _FakeHistoryRepository({1, 2});
      final container = ProviderContainer(
        overrides: [topicRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);

      expect(container.read(readTopicIdsProvider), isEmpty);
      await Future<void>.delayed(Duration.zero);
      expect(container.read(readTopicIdsProvider), {1, 2});

      container.read(readTopicIdsProvider.notifier).markRead(3);
      expect(container.read(readTopicIdsProvider), {1, 2, 3});

      repository.ids = {3};
      await container.read(readTopicIdsProvider.notifier).reload();
      expect(container.read(readTopicIdsProvider), {3});
      expect(repository.loads, 2);
    });
  });

  testWidgets('unread titles keep the normal color', (tester) async {
    final color = await _titleColor(tester, readIds: {});
    final theme = Theme.of(tester.element(find.byType(TopicListItemWidget)));
    expect(color, theme.textTheme.bodyLarge?.color);
  });

  testWidgets('read titles use onSurfaceVariant', (tester) async {
    final color = await _titleColor(tester, readIds: {1});
    final theme = Theme.of(tester.element(find.byType(TopicListItemWidget)));
    expect(color, theme.colorScheme.onSurfaceVariant);
  });

  testWidgets('unread colored titles keep their color', (tester) async {
    final color = await _titleColor(tester, readIds: {}, topicMisc: _redMisc);
    expect(color, Colors.red);
  });

  testWidgets('read colored titles keep their hue with lower opacity', (
    tester,
  ) async {
    final color = await _titleColor(tester, readIds: {1}, topicMisc: _redMisc);
    expect(color, Colors.red.withValues(alpha: 0.6));
  });
}
