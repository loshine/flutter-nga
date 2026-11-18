import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:toastification/toastification.dart';

import 'package:flutter_nga/providers/settings/blocklist_settings_provider.dart';
import 'package:flutter_nga/ui/page/settings/blocklist_keywords_page.dart';
import 'package:flutter_nga/ui/page/settings/blocklist_users_page.dart';

class _FakeBlocklistNotifier extends BlocklistSettingsNotifier {
  int deleteAllUsersCalls = 0;
  int deleteAllWordsCalls = 0;

  @override
  BlocklistSettingsState build() => const BlocklistSettingsState(
    blockUserList: ['用户A'],
    blockWordList: ['关键词A'],
  );

  @override
  Future<void> load() async {}

  @override
  Future<String> deleteAllUsers() async {
    deleteAllUsersCalls++;
    state = state.copyWith(blockUserList: []);
    return '操作成功';
  }

  @override
  Future<String> deleteAllWords() async {
    deleteAllWordsCalls++;
    state = state.copyWith(blockWordList: []);
    return '操作成功';
  }
}

Future<_FakeBlocklistNotifier> _pump(WidgetTester tester, Widget page) async {
  final notifier = _FakeBlocklistNotifier();
  final router = GoRouter(
    routes: [GoRoute(path: '/', builder: (context, state) => page)],
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [blocklistSettingsProvider.overrideWith(() => notifier)],
      child: ToastificationWrapper(
        child: MaterialApp.router(routerConfig: router),
      ),
    ),
  );
  await tester.pump();
  return notifier;
}

Future<void> _cleanUpToasts(WidgetTester tester) async {
  toastification.dismissAll(delayForAnimation: false);
  await tester.pump(const Duration(milliseconds: 700));
  toastification.managers.clear();
  await tester.pumpWidget(const SizedBox.shrink());
}

void main() {
  testWidgets('删除所有屏蔽用户需要确认，取消时不删除', (tester) async {
    final notifier = await _pump(tester, const BlocklistUsersPage());

    await tester.tap(find.byTooltip('删除所有屏蔽用户'));
    await tester.pumpAndSettle();
    expect(find.textContaining('不可恢复'), findsOneWidget);

    await tester.tap(find.text('取消'));
    await tester.pumpAndSettle();
    expect(notifier.deleteAllUsersCalls, 0);
    expect(find.text('用户A'), findsOneWidget);

    await tester.tap(find.byTooltip('删除所有屏蔽用户'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('全部删除'));
    await tester.pumpAndSettle();
    expect(notifier.deleteAllUsersCalls, 1);
    expect(find.text('用户A'), findsNothing);

    await _cleanUpToasts(tester);
  });

  testWidgets('删除所有屏蔽关键词需要确认', (tester) async {
    final notifier = await _pump(tester, const BlocklistKeywordsPage());

    await tester.tap(find.byTooltip('删除所有屏蔽关键词'));
    await tester.pumpAndSettle();
    expect(notifier.deleteAllWordsCalls, 0);
    expect(find.textContaining('不可恢复'), findsOneWidget);

    await tester.tap(find.text('全部删除'));
    await tester.pumpAndSettle();
    expect(notifier.deleteAllWordsCalls, 1);

    await _cleanUpToasts(tester);
  });
}
