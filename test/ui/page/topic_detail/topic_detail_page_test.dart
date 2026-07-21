import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_nga/data/entity/topic.dart';
import 'package:flutter_nga/providers/topic/topic_detail_provider.dart';
import 'package:flutter_nga/providers/topic/topic_single_page_provider.dart';
import 'package:flutter_nga/ui/page/topic_detail/topic_detail_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _PendingTopicSinglePageNotifier extends TopicSinglePageNotifier {
  _PendingTopicSinglePageNotifier(
    super.key,
    this.completer,
  );

  final Completer<TopicSinglePageState> completer;

  @override
  Future<TopicSinglePageState> refresh() => completer.future;
}

class _TopicRequestHarness {
  final requests = <TopicSinglePageKey, Completer<TopicSinglePageState>>{};

  TopicSinglePageNotifier createNotifier(TopicSinglePageKey key) {
    final completer = requests.putIfAbsent(
      key,
      () => Completer<TopicSinglePageState>(),
    );
    return _PendingTopicSinglePageNotifier(key, completer);
  }
}

void main() {
  testWidgets('new topic starts with its route title and first page',
      (tester) async {
    final harness = _TopicRequestHarness();
    final container = ProviderContainer(
      overrides: [
        topicSinglePageProvider.overrideWith2(harness.createNotifier),
      ],
    );
    const oldKey = TopicDetailKey(tid: 1);
    final oldProvider = topicDetailProvider(oldKey);
    final oldSubscription = container.listen(oldProvider, (_, __) {});
    addTearDown(() {
      oldSubscription.close();
      container.dispose();
    });
    container.read(oldProvider.notifier).updateMetadata(
          maxPage: 5,
          maxFloor: 100,
          topic: const Topic(tid: 1, subject: '旧标题'),
        );
    container.read(oldProvider.notifier).setCurrentPage(3);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: TopicDetailPage(2, 10, subject: '新标题'),
        ),
      ),
    );

    expect(find.text('新标题'), findsOneWidget);
    expect(find.text('旧标题'), findsNothing);
    expect(find.text('1/1'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 50));
  });

  testWidgets('network title replaces an empty route title', (tester) async {
    final harness = _TopicRequestHarness();
    final container = ProviderContainer(
      overrides: [
        topicSinglePageProvider.overrideWith2(harness.createNotifier),
      ],
    );
    addTearDown(container.dispose);
    const requestKey = TopicSinglePageKey(tid: 2, page: 1);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: TopicDetailPage(2, 10),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 50));

    harness.requests[requestKey]!.complete(
      const TopicSinglePageState(
        maxPage: 4,
        maxFloor: 80,
        topic: Topic(tid: 2, subject: '接口标题'),
      ),
    );
    // Flush refresh Future, then AppBar rebuild from updateMetadata.
    await tester.pump();
    await tester.pump();

    expect(find.text('接口标题'), findsOneWidget);
    expect(find.text('1/4'), findsOneWidget);
  });

  testWidgets('a completed request does not update a disposed detail page',
      (tester) async {
    final harness = _TopicRequestHarness();
    final container = ProviderContainer(
      overrides: [
        topicSinglePageProvider.overrideWith2(harness.createNotifier),
      ],
    );
    addTearDown(container.dispose);
    const requestKey = TopicSinglePageKey(tid: 2, page: 1);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: TopicDetailPage(2, 10),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pumpWidget(const SizedBox.shrink());

    harness.requests[requestKey]!.complete(
      const TopicSinglePageState(
        maxPage: 4,
        maxFloor: 80,
        topic: Topic(tid: 2, subject: '迟到的标题'),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
  });
}
