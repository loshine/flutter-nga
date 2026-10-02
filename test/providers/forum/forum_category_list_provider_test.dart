import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_nga/data/entity/forum.dart';
import 'package:flutter_nga/data/repository/forum_repository.dart';
import 'package:flutter_nga/providers/core/repository_providers.dart';
import 'package:flutter_nga/providers/forum/forum_category_list_provider.dart';

void main() {
  const cached = ForumCategory('cached', '缓存分类', [
    ForumGroup('缓存组', [Forum(1, '缓存版块')]),
  ]);
  const remote = ForumCategory('remote', '远程分类', [
    ForumGroup('远程组', [Forum(2, '远程版块')]),
  ]);

  test('ensureLoaded publishes cache before remote fetch completes', () async {
    final fetchCompleter = Completer<List<ForumCategory>>();
    final repository = _FakeForumRepository(
      cached: [cached],
      fetch: () => fetchCompleter.future,
    );
    final container = _container(repository);

    final loading =
        container.read(forumCategoryListProvider.notifier).ensureLoaded();
    await Future<void>.delayed(Duration.zero);

    final cachedState = container.read(forumCategoryListProvider);
    expect(cachedState.categories, [cached]);
    expect(cachedState.isLoading, isTrue);

    fetchCompleter.complete([remote]);
    await loading;
    final remoteState = container.read(forumCategoryListProvider);
    expect(remoteState.categories, [remote]);
    expect(remoteState.isLoading, isFalse);
    expect(remoteState.error, isNull);
  });

  test('remote failure keeps cached categories and records the error',
      () async {
    final repository = _FakeForumRepository(
      cached: [cached],
      fetch: () async => throw StateError('offline'),
    );
    final container = _container(repository);

    await container.read(forumCategoryListProvider.notifier).ensureLoaded();

    final state = container.read(forumCategoryListProvider);
    expect(state.categories, [cached]);
    expect(state.isLoading, isFalse);
    expect(state.error, isNotNull);
  });

  test('without cache a failed load can be retried by refresh', () async {
    var fail = true;
    final repository = _FakeForumRepository(
      cached: null,
      fetch: () async {
        if (fail) throw StateError('offline');
        return [remote];
      },
    );
    final container = _container(repository);
    final notifier = container.read(forumCategoryListProvider.notifier);

    await notifier.ensureLoaded();
    expect(container.read(forumCategoryListProvider).categories, isEmpty);
    expect(container.read(forumCategoryListProvider).error, isNotNull);

    // 已初始化后不再重复加载，重试走 refresh
    await notifier.ensureLoaded();
    expect(repository.fetchCalls, 1);

    fail = false;
    await notifier.refresh();
    final state = container.read(forumCategoryListProvider);
    expect(state.categories, [remote]);
    expect(state.error, isNull);
  });
}

ProviderContainer _container(ForumRepository repository) {
  final container = ProviderContainer(
    overrides: [
      forumRepositoryProvider.overrideWithValue(repository),
    ],
  );
  final subscription = container.listen(forumCategoryListProvider, (_, _) {});
  addTearDown(() {
    subscription.close();
    container.dispose();
  });
  return container;
}

class _FakeForumRepository implements ForumRepository {
  _FakeForumRepository({required this.cached, required this.fetch});

  final List<ForumCategory>? cached;
  final Future<List<ForumCategory>> Function() fetch;
  int fetchCalls = 0;

  @override
  Future<List<ForumCategory>?> getCachedForumCategories() async => cached;

  @override
  Future<List<ForumCategory>> fetchForumCategories() {
    fetchCalls++;
    return fetch();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}
