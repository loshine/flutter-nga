import 'package:flutter_nga/data/entity/topic.dart';
import 'package:flutter_nga/providers/topic/topic_detail_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('different topics keep independent detail state', () {
    final container = ProviderContainer();
    const topicAKey = TopicDetailKey(tid: 1);
    const topicBKey = TopicDetailKey(tid: 2);
    final topicA = topicDetailProvider(topicAKey);
    final topicB = topicDetailProvider(topicBKey);
    final topicASubscription = container.listen(topicA, (_, __) {});
    final topicBSubscription = container.listen(topicB, (_, __) {});
    addTearDown(() {
      topicASubscription.close();
      topicBSubscription.close();
      container.dispose();
    });

    container.read(topicA.notifier).updateMetadata(
          maxPage: 5,
          maxFloor: 100,
          topic: const Topic(tid: 1, subject: '帖子 A'),
        );
    container.read(topicA.notifier).setCurrentPage(3);

    final topicBState = container.read(topicB);
    expect(topicBState.currentPage, 1);
    expect(topicBState.maxPage, 1);
    expect(topicBState.subject, isNull);
  });

  test('metadata update clamps the current page atomically', () {
    final container = ProviderContainer();
    const key = TopicDetailKey(tid: 1);
    final provider = topicDetailProvider(key);
    final subscription = container.listen(provider, (_, __) {});
    addTearDown(() {
      subscription.close();
      container.dispose();
    });

    final notifier = container.read(provider.notifier);
    notifier.updateMetadata(
      maxPage: 5,
      maxFloor: 100,
      topic: const Topic(tid: 1, subject: '帖子'),
    );
    notifier.setCurrentPage(5);
    notifier.updateMetadata(
      maxPage: 2,
      maxFloor: 30,
      topic: const Topic(tid: 1, subject: '帖子'),
    );

    final state = container.read(provider);
    expect(state.currentPage, 2);
    expect(state.maxPage, 2);
    expect(state.maxFloor, 30);
    expect(state.subject, '帖子');
  });

  test('detail state resets after its last listener is removed', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    const key = TopicDetailKey(tid: 1);
    final provider = topicDetailProvider(key);
    final subscription = container.listen(provider, (_, __) {});

    container.read(provider.notifier).updateMetadata(
          maxPage: 4,
          maxFloor: 80,
          topic: const Topic(tid: 1, subject: '帖子'),
        );
    subscription.close();
    await container.pump();

    final newSubscription = container.listen(provider, (_, __) {});
    addTearDown(newSubscription.close);
    final state = container.read(provider);
    expect(state.currentPage, 1);
    expect(state.maxPage, 1);
    expect(state.subject, isNull);
  });
}
