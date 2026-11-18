import 'package:flutter_nga/data/entity/topic.dart';
import 'package:flutter_nga/data/repository/topic_repository.dart';
import 'package:flutter_nga/providers/core/repository_providers.dart';
import 'package:flutter_nga/providers/topic/topic_detail_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeFavouriteRepository implements TopicRepository {
  final calls = <String>[];

  @override
  Future<String?> addFavouriteTopic(int? tid) async {
    calls.add('add $tid');
    return '收藏成功';
  }

  @override
  Future<String?> deleteFavouriteTopic(int? tid, int? page) async {
    calls.add('del $tid $page');
    return '删除成功';
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test('favourite toggles between add and delete', () async {
    final repository = _FakeFavouriteRepository();
    final container = ProviderContainer(
      overrides: [topicRepositoryProvider.overrideWithValue(repository)],
    );
    const key = TopicDetailKey(tid: 9);
    final provider = topicDetailProvider(key);
    final subscription = container.listen(provider, (_, _) {});
    addTearDown(() {
      subscription.close();
      container.dispose();
    });

    expect(container.read(provider).favourite, FavouriteStatus.unknown);
    expect(await container.read(provider.notifier).toggleFavourite(), '收藏成功');
    expect(container.read(provider).favourite, FavouriteStatus.favourited);
    expect(container.read(provider).favouriteBusy, isFalse);

    expect(await container.read(provider.notifier).toggleFavourite(), '删除成功');
    expect(container.read(provider).favourite, FavouriteStatus.notFavourited);
    expect(repository.calls, ['add 9', 'del 9 1']);
  });

  test('favourite ignores taps while a request is in flight', () async {
    final repository = _FakeFavouriteRepository();
    final container = ProviderContainer(
      overrides: [topicRepositoryProvider.overrideWithValue(repository)],
    );
    const key = TopicDetailKey(tid: 9);
    final provider = topicDetailProvider(key);
    final subscription = container.listen(provider, (_, _) {});
    addTearDown(() {
      subscription.close();
      container.dispose();
    });

    final notifier = container.read(provider.notifier);
    final first = notifier.toggleFavourite();
    expect(await notifier.toggleFavourite(), isNull);
    await first;
    expect(repository.calls, ['add 9']);
  });

  test('different topics keep independent detail state', () {
    final container = ProviderContainer();
    const topicAKey = TopicDetailKey(tid: 1);
    const topicBKey = TopicDetailKey(tid: 2);
    final topicA = topicDetailProvider(topicAKey);
    final topicB = topicDetailProvider(topicBKey);
    final topicASubscription = container.listen(topicA, (_, _) {});
    final topicBSubscription = container.listen(topicB, (_, _) {});
    addTearDown(() {
      topicASubscription.close();
      topicBSubscription.close();
      container.dispose();
    });

    container
        .read(topicA.notifier)
        .updateMetadata(
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
    final subscription = container.listen(provider, (_, _) {});
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
    final subscription = container.listen(provider, (_, _) {});

    container
        .read(provider.notifier)
        .updateMetadata(
          maxPage: 4,
          maxFloor: 80,
          topic: const Topic(tid: 1, subject: '帖子'),
        );
    subscription.close();
    await container.pump();

    final newSubscription = container.listen(provider, (_, _) {});
    addTearDown(newSubscription.close);
    final state = container.read(provider);
    expect(state.currentPage, 1);
    expect(state.maxPage, 1);
    expect(state.subject, isNull);
  });
}
