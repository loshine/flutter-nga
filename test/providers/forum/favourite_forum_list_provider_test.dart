import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_nga/data/entity/forum.dart';
import 'package:flutter_nga/data/repository/forum_repository.dart';
import 'package:flutter_nga/providers/core/repository_providers.dart';
import 'package:flutter_nga/providers/forum/favourite_forum_list_provider.dart';
import 'package:flutter_nga/ui/page/forum_detail/forum_favourite_button_widet.dart';

void main() {
  test('refresh publishes cache before remote sync completes', () async {
    const cached = Forum(1, '本地缓存');
    const remote = Forum(2, '远程数据');
    final syncCompleter = Completer<List<Forum>>();
    final repository = _FakeForumRepository(
      cached: [cached],
      syncFuture: syncCompleter.future,
    );
    final container = _container(repository);
    final subscription = container.listen(
      favouriteForumListProvider,
      (_, __) {},
    );
    addTearDown(() {
      subscription.close();
      container.dispose();
    });

    final refresh =
        container.read(favouriteForumListProvider.notifier).refresh();
    await Future<void>.delayed(Duration.zero);

    final cachedState = container.read(favouriteForumListProvider);
    expect(cachedState.forums, [cached]);
    expect(cachedState.isSyncing, isTrue);

    syncCompleter.complete([remote]);
    await refresh;
    final syncedState = container.read(favouriteForumListProvider);
    expect(syncedState.forums, [remote]);
    expect(syncedState.isSyncing, isFalse);
  });

  test('failed delete keeps the confirmed local favourite', () async {
    const forum = Forum(7, '议事厅');
    final repository = _FakeForumRepository(
      cached: [forum],
      synced: [forum],
      failDelete: true,
    );
    final container = _container(repository);
    final subscription = container.listen(
      favouriteForumListProvider,
      (_, __) {},
    );
    addTearDown(() {
      subscription.close();
      container.dispose();
    });
    final notifier = container.read(favouriteForumListProvider.notifier);
    await notifier.refresh();

    await expectLater(notifier.delete(forum), throwsStateError);

    final state = container.read(favouriteForumListProvider);
    expect(state.isFavourite(forum.identity), isTrue);
    expect(state.isBusy(forum.identity), isFalse);
  });

  test('a busy favourite ignores duplicate delete requests', () async {
    const forum = Forum(7, '议事厅');
    final deleteGate = Completer<void>();
    final repository = _FakeForumRepository(
      cached: [forum],
      synced: [forum],
      deleteGate: deleteGate,
    );
    final container = _container(repository);
    final subscription = container.listen(
      favouriteForumListProvider,
      (_, __) {},
    );
    addTearDown(() {
      subscription.close();
      container.dispose();
    });
    final notifier = container.read(favouriteForumListProvider.notifier);
    await notifier.refresh();

    final firstDelete = notifier.delete(forum);
    await Future<void>.delayed(Duration.zero);
    expect(container.read(favouriteForumListProvider).isBusy(forum.identity),
        isTrue);

    await notifier.delete(forum);
    expect(repository.deleteCalls, 1);

    deleteGate.complete();
    await firstDelete;
    expect(container.read(favouriteForumListProvider).isBusy(forum.identity),
        isFalse);
  });

  test('account change clears stale state and reloads the current cache',
      () async {
    const first = Forum(1, '账号一');
    const second = Forum(2, '账号二');
    final repository = _FakeForumRepository(
      cached: [first],
      synced: [first],
    );
    final container = _container(repository);
    final subscription = container.listen(
      favouriteForumListProvider,
      (_, __) {},
    );
    addTearDown(() {
      subscription.close();
      container.dispose();
    });
    final notifier = container.read(favouriteForumListProvider.notifier);
    await notifier.refresh();

    repository
      ..cached = [second]
      ..synced = [second];
    notifier.onAccountChanged();
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);

    expect(container.read(favouriteForumListProvider).forums, [second]);
  });

  testWidgets('forum buttons derive fid and stid stars from the shared list',
      (tester) async {
    const special = Forum(7, '特殊版块', type: 1);
    final repository = _FakeForumRepository(
      cached: [special],
      synced: [special],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          forumRepositoryProvider.overrideWithValue(repository),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: Row(
              children: [
                ForumFavouriteButtonWidget(fid: 7, name: '普通版块'),
                ForumFavouriteButtonWidget(
                  fid: 7,
                  name: '特殊版块',
                  type: 1,
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.star_border), findsOneWidget);
    expect(find.byIcon(Icons.star), findsOneWidget);
  });
}

ProviderContainer _container(ForumRepository repository) {
  return ProviderContainer(
    overrides: [
      forumRepositoryProvider.overrideWithValue(repository),
    ],
  );
}

class _FakeForumRepository implements ForumRepository {
  _FakeForumRepository({
    required this.cached,
    this.synced = const [],
    this.syncFuture,
    this.failDelete = false,
    this.deleteGate,
  });

  List<Forum> cached;
  List<Forum> synced;
  Future<List<Forum>>? syncFuture;
  bool failDelete;
  Completer<void>? deleteGate;
  int deleteCalls = 0;

  @override
  Future<List<Forum>> getFavouriteList() async => [...cached];

  @override
  Future<List<Forum>> syncFavouriteList() async {
    final result = syncFuture == null ? synced : await syncFuture!;
    cached = [...result];
    return [...result];
  }

  @override
  Future<bool> isFavourite(Forum forum) async {
    return cached.any((item) => item.identity == forum.identity);
  }

  @override
  Future<void> saveFavourite(Forum forum) async {
    cached = [
      ...cached.where((item) => item.identity != forum.identity),
      forum,
    ];
  }

  @override
  Future<void> deleteFavourite(Forum forum) async {
    deleteCalls++;
    await deleteGate?.future;
    if (failDelete) throw StateError('delete failed');
    cached = cached.where((item) => item.identity != forum.identity).toList();
  }

  @override
  List<ForumGroup> getForumGroups() => const [];

  @override
  Future<List<Forum>> getForumByName(String keyword) =>
      throw UnimplementedError();

  @override
  Future<String?> addChildForumSubscription(int fid, int? parentId) =>
      throw UnimplementedError();

  @override
  Future<String?> deleteChildForumSubscription(int fid, int? parentId) =>
      throw UnimplementedError();
}
