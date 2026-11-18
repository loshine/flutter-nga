import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:toastification/toastification.dart';

import 'package:flutter_nga/data/entity/topic.dart';
import 'package:flutter_nga/data/repository/topic_repository.dart';
import 'package:flutter_nga/providers/core/repository_providers.dart';
import 'package:flutter_nga/providers/topic/favourite_topic_list_provider.dart';
import 'package:flutter_nga/ui/page/favourite_topic_list/favourite_topic_list_page.dart';

Topic _topic(int tid, {int page = 1}) => Topic(
  tid: tid,
  fid: 10,
  author: '作者',
  subject: '收藏$tid',
  lastPost: 0,
  replies: 0,
  type: 0,
  page: page,
);

TopicListData _data(List<Topic> topics, {int rows = 3}) => TopicListData(
  forum: const ForumInfo(),
  rows: rows,
  topicList: {for (final t in topics) '${t.tid}': t},
  currentRows: topics.length,
  topicRows: 35,
  rRows: 35,
);

class _FakeRepository implements TopicRepository {
  final deletes = <String>[];
  final pages = <int, List<Topic>>{
    1: [_topic(1), _topic(2), _topic(3)],
  };
  bool failDelete = false;
  Completer<void>? deleteGate;
  final events = <String>[];

  @override
  Future<TopicListData> getFavouriteTopicList(int page) async {
    events.add('list $page');
    return _data(pages[page] ?? const []);
  }

  @override
  Future<String?> deleteFavouriteTopic(int? tid, int? page) async {
    events.add('delete start $tid');
    await deleteGate?.future;
    if (failDelete) throw Exception('删除失败');
    deletes.add('$tid@$page');
    events.add('delete done $tid');
    return '操作成功';
  }

  @override
  Future<Set<int>> getHistoryTopicIds() async => {};

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

List<int?> _tids(ProviderContainer c) =>
    c.read(favouriteTopicListProvider).list.map((t) => t.tid).toList();

Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 15; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  group('FavouriteTopicListNotifier', () {
    late _FakeRepository repository;
    late ProviderContainer container;
    late FavouriteTopicListNotifier notifier;

    setUp(() async {
      repository = _FakeRepository();
      container = ProviderContainer(
        overrides: [topicRepositoryProvider.overrideWithValue(repository)],
      );
      notifier = container.read(favouriteTopicListProvider.notifier);
      await notifier.refresh();
    });
    tearDown(() => container.dispose());

    test('undo puts the topic back at its position without a request', () {
      notifier.removeLocally(_topic(2));
      expect(_tids(container), [1, 3]);
      notifier.undoDeletion(2);
      expect(_tids(container), [1, 2, 3]);
      expect(repository.deletes, isEmpty);
    });

    test('commit sends the delete with the topic page once', () async {
      notifier.removeLocally(_topic(2, page: 1));
      await notifier.commitDeletion(2);
      await notifier.commitDeletion(2);
      expect(repository.deletes, ['2@1']);
      expect(_tids(container), [1, 3]);
    });

    test('failed commit restores the topic and rethrows', () async {
      repository.failDelete = true;
      notifier.removeLocally(_topic(1));
      await expectLater(notifier.commitDeletion(1), throwsException);
      expect(_tids(container), [1, 2, 3]);
    });

    test('refresh flushes pending deletions first', () async {
      notifier.removeLocally(_topic(3));
      repository.pages[1] = [_topic(1), _topic(2)];
      await notifier.refresh();
      expect(repository.deletes, ['3@1']);
      expect(_tids(container), [1, 2]);
    });

    test('refresh waits for a deletion already in flight', () async {
      repository.deleteGate = Completer<void>();
      notifier.removeLocally(_topic(2));
      final commit = notifier.commitDeletion(2);
      repository.pages[1] = [_topic(1), _topic(3)];
      repository.events.clear();

      final refresh = notifier.refresh();
      await Future<void>.delayed(Duration.zero);
      expect(repository.events, isNot(contains('list 1')));

      repository.deleteGate!.complete();
      await commit;
      await refresh;
      expect(repository.events, ['delete done 2', 'list 1']);
      expect(_tids(container), [1, 3]);
    });

    test('load more skips topics already in the list', () async {
      repository.pages[2] = [_topic(3), _topic(4)];
      await notifier.loadMore();
      expect(_tids(container), [1, 2, 3, 4]);
    });
  });

  group('FavouriteTopicListPage', () {
    Future<_FakeRepository> pump(WidgetTester tester) async {
      final repository = _FakeRepository();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [topicRepositoryProvider.overrideWithValue(repository)],
          child: const ToastificationWrapper(
            child: MaterialApp(home: FavouriteTopicListPage()),
          ),
        ),
      );
      await _settle(tester);
      expect(find.text('收藏2'), findsOneWidget);
      return repository;
    }

    testWidgets('menu removal can be undone', (tester) async {
      final repository = await pump(tester);

      await tester.tap(find.byTooltip('更多操作').at(1));
      await _settle(tester);
      await tester.tap(find.text('取消收藏'));
      await _settle(tester);
      expect(find.text('收藏2'), findsNothing);
      expect(find.text('已取消收藏'), findsOneWidget);

      await tester.tap(find.text('撤销'));
      await _settle(tester);
      expect(find.text('收藏2'), findsOneWidget);
      expect(repository.deletes, isEmpty);
    });

    testWidgets('swipe removal commits after the snack bar times out', (
      tester,
    ) async {
      final repository = await pump(tester);

      await tester.drag(find.text('收藏1'), const Offset(-600, 0));
      await _settle(tester);
      expect(find.text('收藏1'), findsNothing);
      expect(repository.deletes, isEmpty);

      await tester.pump(const Duration(seconds: 5));
      await _settle(tester);
      expect(repository.deletes, ['1@1']);
    });

    testWidgets('leaving the page commits pending deletions', (tester) async {
      final repository = await pump(tester);

      await tester.tap(find.byTooltip('更多操作').first);
      await _settle(tester);
      await tester.tap(find.text('取消收藏'));
      await _settle(tester);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      expect(repository.deletes, ['1@1']);
    });
  });
}
