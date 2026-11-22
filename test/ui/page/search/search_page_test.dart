import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:flutter_nga/ui/page/search/search_page.dart';
import 'package:flutter_nga/utils/dimen.dart';
import 'package:flutter_nga/utils/theme_builder.dart';

void main() {
  testWidgets('搜索页使用 M3 SearchBar（自动聚焦、无双搜索图标、留足左右边距）与 SegmentedButton', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: ThemeBuilder.buildLightTheme(Colors.brown),
          home: const SearchPage(fid: -7),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final searchBar = find.byType(SearchBar);
    expect(searchBar, findsOneWidget);
    // 独立展示时左右边距均与下方卡片对齐（16dp）
    final rect = tester.getRect(searchBar);
    expect(rect.left, greaterThanOrEqualTo(Dimen.spacingL));
    expect(
      tester.getSize(find.byType(Scaffold)).width - rect.right,
      greaterThanOrEqualTo(Dimen.spacingL),
    );

    // 只有一个搜索图标按钮，无冗余重复图标
    expect(find.byIcon(Icons.search), findsOneWidget);
    expect(find.byType(SegmentedButton<int>), findsNWidgets(2));
    expect(find.byType(FilterChip), findsOneWidget);

    // 切换到「用户」显示用户名/用户ID 分段按钮
    await tester.tap(find.text('用户'));
    await tester.pumpAndSettle();
    expect(find.text('用户名'), findsOneWidget);
    expect(find.text('用户ID'), findsOneWidget);
  });

  testWidgets('带返回按钮进入搜索页时，搜索框与返回按钮之间有间隔', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: ThemeBuilder.buildLightTheme(Colors.brown),
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const SearchPage(fid: -7),
                  ),
                ),
                child: const Text('打开搜索'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('打开搜索'));
    await tester.pumpAndSettle();

    final backRect = tester.getRect(find.byType(BackButton));
    final barRect = tester.getRect(find.byType(SearchBar));
    expect(
      barRect.left - backRect.right,
      greaterThanOrEqualTo(Dimen.spacingXS),
    );
  });
}
