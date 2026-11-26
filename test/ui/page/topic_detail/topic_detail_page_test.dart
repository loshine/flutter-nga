import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_nga/data/entity/topic.dart';
import 'package:flutter_nga/providers/topic/topic_detail_provider.dart';
import 'package:flutter_nga/providers/topic/topic_single_page_provider.dart';
import 'package:flutter_nga/ui/page/topic_detail/topic_detail_page.dart';

class _PendingTopicSinglePageNotifier extends TopicSinglePageNotifier {
  _PendingTopicSinglePageNotifier(super.key, this.completer, this.started);

  final Completer<TopicSinglePageState> completer;
  final Completer<void> started;

  @override
  Future<TopicSinglePageState> refresh() {
    if (!started.isCompleted) started.complete();
    return completer.future;
  }
}

class _TopicRequestHarness {
  final requests = <TopicSinglePageKey, Completer<TopicSinglePageState>>{};
  final refreshStarts = <TopicSinglePageKey, Completer<void>>{};

  TopicSinglePageNotifier createNotifier(TopicSinglePageKey key) {
    final completer = requests.putIfAbsent(
      key,
      () => Completer<TopicSinglePageState>(),
    );
    final started = refreshStarts.putIfAbsent(key, Completer<void>.new);
    return _PendingTopicSinglePageNotifier(key, completer, started);
  }

  Future<void> waitForRefreshStart(
    WidgetTester tester,
    TopicSinglePageKey key,
  ) async {
    final started = refreshStarts[key]!;
    for (var i = 0; i < 50 && !started.isCompleted; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(
      started.isCompleted,
      isTrue,
      reason: 'Initial refresh did not start.',
    );
  }
}

void main() {
  testWidgets('new topic starts with its route title and first page', (
    tester,
  ) async {
    final harness = _TopicRequestHarness();
    final container = ProviderContainer(
      overrides: [
        topicSinglePageProvider.overrideWith2(harness.createNotifier),
      ],
    );
    const oldKey = (tid: 1);
    final oldProvider = topicDetailProvider(oldKey);
    final oldSubscription = container.listen(oldProvider, (_, _) {});
    addTearDown(() {
      oldSubscription.close();
      container.dispose();
    });
    container
        .read(oldProvider.notifier)
        .updateMetadata(
          maxPage: 5,
          maxFloor: 100,
          topic: const Topic(tid: 1, subject: '旧标题'),
        );
    container.read(oldProvider.notifier).setCurrentPage(3);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: TopicDetailPage(2, 10, subject: '新标题')),
      ),
    );

    expect(find.text('新标题'), findsOneWidget);
    expect(find.text('旧标题'), findsNothing);
    expect(find.text('1/1'), findsOneWidget);
    await harness.waitForRefreshStart(tester, (
      tid: 2,
      page: 1,
      authorid: null,
    ));
  });

  testWidgets('network title replaces an empty route title', (tester) async {
    final harness = _TopicRequestHarness();
    final container = ProviderContainer(
      overrides: [
        topicSinglePageProvider.overrideWith2(harness.createNotifier),
      ],
    );
    addTearDown(container.dispose);
    const requestKey = (tid: 2, page: 1, authorid: null);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: TopicDetailPage(2, 10)),
      ),
    );
    await harness.waitForRefreshStart(tester, requestKey);

    harness.requests[requestKey]!.complete(
      const TopicSinglePageState(
        maxPage: 4,
        maxFloor: 80,
        topic: Topic(tid: 2, subject: '接口标题'),
      ),
    );
    await tester.pump();
    await tester.pump();
    // Advance EasyRefresh's processed-state timer before test teardown.
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    expect(find.text('接口标题'), findsOneWidget);
    expect(find.text('1/4'), findsOneWidget);
  });

  testWidgets('a completed request does not update a disposed detail page', (
    tester,
  ) async {
    final harness = _TopicRequestHarness();
    final container = ProviderContainer(
      overrides: [
        topicSinglePageProvider.overrideWith2(harness.createNotifier),
      ],
    );
    addTearDown(container.dispose);
    const requestKey = (tid: 2, page: 1, authorid: null);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: TopicDetailPage(2, 10)),
      ),
    );
    await harness.waitForRefreshStart(tester, requestKey);
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

  testWidgets('bottom bar has tooltips and really disables page buttons', (
    tester,
  ) async {
    final harness = _TopicRequestHarness();
    final container = ProviderContainer(
      overrides: [
        topicSinglePageProvider.overrideWith2(harness.createNotifier),
      ],
    );
    addTearDown(container.dispose);
    const detailKey = (tid: 2);
    final detail = container.listen(topicDetailProvider(detailKey), (_, _) {});
    addTearDown(detail.close);
    container
        .read(topicDetailProvider(detailKey).notifier)
        .updateMetadata(maxPage: 3, maxFloor: 60, topic: null);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: TopicDetailPage(2, 10)),
      ),
    );
    await harness.waitForRefreshStart(tester, (
      tid: 2,
      page: 1,
      authorid: null,
    ));

    IconButton button(String tooltip) => tester.widget<IconButton>(
      find.ancestor(
        of: find.byTooltip(tooltip),
        matching: find.byType(IconButton),
      ),
    );
    expect(button('上一页').onPressed, isNull);
    expect(button('下一页').onPressed, isNotNull);
    expect(find.byTooltip('收藏'), findsOneWidget);
    expect(find.byTooltip('回复'), findsOneWidget);

    await tester.tap(find.byTooltip('更多'));
    // 首次刷新挂起时 EasyRefresh 指示器一直在动，不能 pumpAndSettle。
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('切换到夜间模式'), findsOneWidget);
    expect(find.text('复制帖子链接'), findsOneWidget);
    expect(find.text('在浏览器中打开'), findsOneWidget);
  });

  testWidgets('dark theme offers switching to light', (tester) async {
    final harness = _TopicRequestHarness();
    final container = ProviderContainer(
      overrides: [
        topicSinglePageProvider.overrideWith2(harness.createNotifier),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: ThemeData(brightness: Brightness.dark),
          home: const TopicDetailPage(2, 10),
        ),
      ),
    );
    await harness.waitForRefreshStart(tester, (
      tid: 2,
      page: 1,
      authorid: null,
    ));
    await tester.tap(find.byTooltip('更多'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('切换到日间模式'), findsOneWidget);
  });
}
