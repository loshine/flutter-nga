import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:flutter_nga/data/entity/user.dart';
import 'package:flutter_nga/providers/user/account_list_provider.dart';
import 'package:flutter_nga/ui/page/account_management/account_management_page.dart';

class _FakeAccountNotifier extends AccountListNotifier {
  final deleted = <String>[];

  @override
  AccountListState build() => AccountListState(
    list: [
      CacheUser('1', 'c1', '账号A', true),
      CacheUser('2', 'c2', '账号B', false),
    ],
  );

  @override
  Future<void> refresh() async {}

  @override
  Future<bool> delete(CacheUser cacheUser) async {
    deleted.add(cacheUser.uid);
    state = state.copyWith(
      list: state.list.where((u) => u.uid != cacheUser.uid).toList(),
    );
    return true;
  }
}

Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  testWidgets('only the default account is marked and menus differ', (
    tester,
  ) async {
    final notifier = _FakeAccountNotifier();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [accountListProvider.overrideWith(() => notifier)],
        // 对话框按钮通过 go_router 的 context.pop() 关闭
        child: MaterialApp.router(
          routerConfig: GoRouter(
            routes: [
              GoRoute(
                path: '/',
                builder: (_, _) => const AccountManagementPage(),
              ),
            ],
          ),
        ),
      ),
    );
    await _settle(tester);

    expect(find.byIcon(Icons.check_circle), findsOneWidget);
    expect(find.byIcon(Icons.circle_outlined), findsOneWidget);

    await tester.tap(find.byTooltip('更多操作').first);
    await _settle(tester);
    expect(find.text('设为默认'), findsNothing);
    await tester.tap(find.text('删除'));
    await _settle(tester);
    expect(find.textContaining('自动切换到「账号B」'), findsOneWidget);

    await tester.tap(find.text('取消'));
    await _settle(tester);
    expect(notifier.deleted, isEmpty);

    // 长按弹出同一菜单，非默认账号可设为默认
    await tester.longPress(find.text('账号B'));
    await _settle(tester);
    expect(find.text('设为默认'), findsOneWidget);
    await tester.tap(find.text('删除'));
    await _settle(tester);
    await tester.tap(find.widgetWithText(FilledButton, '删除'));
    await _settle(tester);
    expect(notifier.deleted, ['2']);
    // 删除后触发的刷新留有 EasyRefresh 计时器
    await tester.pump(const Duration(seconds: 2));
  });
}
