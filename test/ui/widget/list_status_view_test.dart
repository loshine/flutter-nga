import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:toastification/toastification.dart';

import 'package:flutter_nga/providers/topic/favourite_topic_list_provider.dart';
import 'package:flutter_nga/ui/page/favourite_topic_list/favourite_topic_list_page.dart';
import 'package:flutter_nga/ui/widget/list_status_view.dart';
import 'package:flutter_nga/utils/hooks/list_load_status.dart';

class _FlakyFavouriteNotifier extends FavouriteTopicListNotifier {
  int refreshCalls = 0;

  @override
  Future<FavouriteTopicListState> refresh() async {
    refreshCalls++;
    if (refreshCalls == 1) throw Exception('网络错误');
    state = const FavouriteTopicListState();
    return state;
  }
}

Widget _switcher(ListLoadStatus status, {bool isEmpty = true}) {
  return MaterialApp(
    home: Scaffold(
      body: ListStatusSwitcher(
        status: status,
        isEmpty: isEmpty,
        emptyMessage: '暂无数据',
        onRetry: () {},
        child: const Text('列表'),
      ),
    ),
  );
}

Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 20; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  group('ListLoadStatus', () {
    test('failure with existing data is left to the caller', () {
      final status = ListLoadStatus();
      expect(status.fail(Exception('x'), hasData: true), isFalse);
      expect(status.error, isNull);
      expect(status.fail(Exception('x'), hasData: false), isTrue);
      expect(status.error, isNotNull);
      status.succeed();
      expect(status.error, isNull);
      expect(status.loaded, isTrue);
    });
  });

  group('ListStatusSwitcher', () {
    testWidgets('shows the list while the first load is pending', (
      tester,
    ) async {
      await tester.pumpWidget(_switcher(ListLoadStatus()));
      expect(find.text('列表'), findsOneWidget);
      expect(find.text('重试'), findsNothing);
    });

    testWidgets('shows the empty state after loading', (tester) async {
      await tester.pumpWidget(_switcher(ListLoadStatus()..succeed()));
      expect(find.text('暂无数据'), findsOneWidget);
      expect(find.text('重试'), findsOneWidget);
    });

    testWidgets('shows the error with retry', (tester) async {
      final status = ListLoadStatus()..fail(Exception('连接超时'), hasData: false);
      await tester.pumpWidget(_switcher(status));
      expect(find.textContaining('连接超时'), findsOneWidget);
      expect(find.text('重试'), findsOneWidget);
    });

    testWidgets('keeps the list when it has data', (tester) async {
      final status = ListLoadStatus()..fail(Exception('连接超时'), hasData: false);
      await tester.pumpWidget(_switcher(status, isEmpty: false));
      expect(find.text('列表'), findsOneWidget);
    });
  });

  testWidgets('favourite page: first load failure shows retry, then empty', (
    tester,
  ) async {
    final notifier = _FlakyFavouriteNotifier();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [favouriteTopicListProvider.overrideWith(() => notifier)],
        child: const ToastificationWrapper(
          child: MaterialApp(home: FavouriteTopicListPage()),
        ),
      ),
    );
    await _settle(tester);

    expect(notifier.refreshCalls, 1);
    expect(find.textContaining('网络错误'), findsOneWidget);

    await tester.tap(find.text('重试'));
    await _settle(tester);

    expect(notifier.refreshCalls, 2);
    expect(find.text('暂无收藏'), findsOneWidget);
  });
}
