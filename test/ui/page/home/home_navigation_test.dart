import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:flutter_nga/data/entity/forum.dart';
import 'package:flutter_nga/data/entity/notification.dart';
import 'package:flutter_nga/data/entity/user.dart';
import 'package:flutter_nga/data/repository/message_repository.dart';
import 'package:flutter_nga/providers/core/repository_providers.dart';
import 'package:flutter_nga/providers/forum/favourite_forum_list_provider.dart';
import 'package:flutter_nga/providers/forum/forum_category_list_provider.dart';
import 'package:flutter_nga/providers/home/home_drawer_header_provider.dart';
import 'package:flutter_nga/providers/settings/blocklist_settings_provider.dart';
import 'package:flutter_nga/providers/settings/interface_settings_provider.dart';
import 'package:flutter_nga/ui/page/home/home_page.dart';
import 'package:flutter_nga/utils/theme_builder.dart';

class _FakeHeaderNotifier extends HomeDrawerHeaderNotifier {
  _FakeHeaderNotifier(this._user);
  final UserInfo? _user;

  @override
  UserInfo? build() => _user;

  @override
  Future<void> refresh() async => state = _user;
}

class _FakeMessageRepository implements MessageRepository {
  @override
  Future<NotificationInfo> getNotificationInfo() async => NotificationInfo(
    unreadReplyCount: 2,
    unreadSystemNotificationCount: 1,
    unreadMessageCount: 4,
  );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeBlocklistNotifier extends BlocklistSettingsNotifier {
  @override
  Future<void> init() async {}

  @override
  void loopSyncBlockList() {}
}

class _FakeInterfaceSettingsNotifier extends InterfaceSettingsNotifier {
  @override
  Future<void> init() async {}
}

class _FakeFavouriteForumListNotifier extends FavouriteForumListNotifier {
  @override
  FavouriteForumListState build() => const FavouriteForumListState();

  @override
  Future<void> refresh() async {}
}

class _FakeForumCategoryListNotifier extends ForumCategoryListNotifier {
  @override
  ForumCategoryListState build() => const ForumCategoryListState(
    categories: [
      ForumCategory('other', '网事杂谈', [
        ForumGroup('网事杂谈', [Forum(-7, '大漩涡')]),
      ]),
    ],
  );

  @override
  Future<void> ensureLoaded() async {}
}

Future<void> _pumpHome(
  WidgetTester tester, {
  required Size size,
  UserInfo? user,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        homeDrawerHeaderProvider.overrideWith(() => _FakeHeaderNotifier(user)),
        messageRepositoryProvider.overrideWithValue(_FakeMessageRepository()),
        blocklistSettingsProvider.overrideWith(_FakeBlocklistNotifier.new),
        interfaceSettingsProvider.overrideWith(
          _FakeInterfaceSettingsNotifier.new,
        ),
        favouriteForumListProvider.overrideWith(
          _FakeFavouriteForumListNotifier.new,
        ),
        forumCategoryListProvider.overrideWith(
          _FakeForumCategoryListNotifier.new,
        ),
      ],
      child: MaterialApp(
        theme: ThemeBuilder.buildLightTheme(Colors.brown),
        home: const HomePage(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'compact layout uses NavigationBar with aggregated unread badge',
    (tester) async {
      await _pumpHome(
        tester,
        size: const Size(400, 800),
        user: const UserInfo(uid: 1, username: '测试用户'),
      );

      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byType(NavigationRail), findsNothing);
      expect(find.byTooltip('搜索'), findsOneWidget);

      final badge = tester.widget<Badge>(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.byType(Badge),
        ),
      );
      expect(badge.isLabelVisible, isTrue);
      expect((badge.label as Text?)?.data, '7');
    },
  );

  testWidgets('medium screen uses collapsed NavigationRail with leading FAB', (
    tester,
  ) async {
    await _pumpHome(
      tester,
      size: const Size(700, 800),
      user: const UserInfo(uid: 1, username: '测试用户'),
    );

    final rail = tester.widget<NavigationRail>(find.byType(NavigationRail));
    expect(rail.extended, isFalse);
    expect(rail.labelType, NavigationRailLabelType.all);
    expect(
      find.descendant(
        of: find.byType(NavigationRail),
        matching: find.byTooltip('添加自定义版面'),
      ),
      findsOneWidget,
    );
  });

  testWidgets(
    'expanded screen uses extended NavigationRail with extended FAB',
    (tester) async {
      await _pumpHome(
        tester,
        size: const Size(1000, 800),
        user: const UserInfo(uid: 1, username: '测试用户'),
      );

      final rail = tester.widget<NavigationRail>(find.byType(NavigationRail));
      expect(rail.extended, isTrue);
      expect(rail.labelType, NavigationRailLabelType.none);
      expect(find.text('添加版面'), findsOneWidget);
    },
  );

  test('NavigationBar theme uses surfaceContainer for tonal separation', () {
    final theme = ThemeBuilder.buildLightTheme(Colors.brown);
    expect(
      theme.navigationBarTheme.backgroundColor,
      theme.colorScheme.surfaceContainer,
    );
  });
}
