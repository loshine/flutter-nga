import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:flutter_nga/data/entity/forum.dart';
import 'package:flutter_nga/ui/page/forum_group/forum_category_page.dart';

void main() {
  Future<void> pumpPage(WidgetTester tester, ForumCategory category) {
    return tester.pumpWidget(ProviderScope(
      child: MaterialApp(
        home: Scaffold(body: ForumCategoryPage(category: category)),
      ),
    ));
  }

  testWidgets('tapping a group header collapses and expands its forums', (
    tester,
  ) async {
    await pumpPage(
      tester,
      const ForumCategory('other', '网事杂谈', [
        ForumGroup('网事杂谈', [Forum(-7, '大漩涡')]),
        ForumGroup('IT软硬件', [Forum(334, '硬件配置')]),
      ]),
    );

    expect(find.text('大漩涡'), findsOneWidget);
    expect(find.text('硬件配置'), findsOneWidget);

    await tester.tap(find.text('网事杂谈'));
    await tester.pumpAndSettle();
    expect(find.text('大漩涡'), findsNothing);
    expect(find.text('硬件配置'), findsOneWidget);

    await tester.tap(find.text('网事杂谈'));
    await tester.pumpAndSettle();
    expect(find.text('大漩涡'), findsOneWidget);
  });

  testWidgets('a single-group category has no collapsible header', (
    tester,
  ) async {
    await pumpPage(
      tester,
      const ForumCategory('trad', '传统游戏', [
        ForumGroup('传统游戏', [Forum(1, '炉石传说')]),
      ]),
    );

    expect(find.text('传统游戏'), findsNothing);
    expect(find.byType(ListTile), findsNothing);
    expect(find.text('炉石传说'), findsOneWidget);
  });
}
