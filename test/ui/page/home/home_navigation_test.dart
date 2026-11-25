import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:flutter_nga/data/entity/forum.dart';
import 'package:flutter_nga/data/entity/notification.dart';
import 'package:flutter_nga/data/entity/topic.dart';
import 'package:flutter_nga/data/entity/user.dart';
import 'package:flutter_nga/data/repository/message_repository.dart';
import 'package:flutter_nga/providers/core/repository_providers.dart';
import 'package:flutter_nga/providers/forum/favourite_forum_list_provider.dart';
import 'package:flutter_nga/providers/forum/forum_category_list_provider.dart';
import 'package:flutter_nga/providers/forum/forum_detail_provider.dart';
import 'package:flutter_nga/providers/home/home_drawer_header_provider.dart';
import 'package:flutter_nga/providers/settings/blocklist_settings_provider.dart';
import 'package:flutter_nga/providers/settings/design_style_provider.dart';
import 'package:flutter_nga/providers/settings/interface_settings_provider.dart';
import 'package:flutter_nga/providers/topic/topic_history_provider.dart';
import 'package:flutter_nga/ui/page/forum_detail/forum_detail_page.dart';
import 'package:flutter_nga/ui/page/home/home_page.dart';
import 'package:flutter_nga/ui/widget/adaptive/liquid_glass_surface.dart';
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
  _FakeFavouriteForumListNotifier([this._forums = const []]);

  final List<Forum> _forums;

  @override
  FavouriteForumListState build() =>
      FavouriteForumListState(forums: _forums, isInitialized: true);

  @override
  Future<void> refresh() async {}
}

class _RecordingForumDetailNotifier extends ForumDetailNotifier {
  _RecordingForumDetailNotifier(super.fid, this.refreshedFids);

  final List<int> refreshedFids;

  @override
  Future<ForumDetailState> refresh(bool recommend, int? type) async {
    refreshedFids.add(fid);
    state = ForumDetailState(
      page: 1,
      maxPage: 1,
      list: [Topic(tid: fid.abs() + 100, fid: fid, subject: '版块 $fid 主题')],
    );
    return state;
  }
}

class _FakeReadTopicIdsNotifier extends ReadTopicIdsNotifier {
  @override
  Set<int> build() => const {};
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
  AppDesignStyle style = AppDesignStyle.material,
  double macTitlebarInset = 0,
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
      child: AppDesignStyleScope(
        style: style,
        nativeLiquidGlassSupported: false,
        macTitlebarInset: macTitlebarInset,
        child: MaterialApp(
          theme: ThemeBuilder.applyDesignStyle(
            ThemeBuilder.buildLightTheme(Colors.brown),
            isAppleStyle: style == AppDesignStyle.apple,
          ),
          home: const HomePage(),
        ),
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

  testWidgets(
    'medium screen uses collapsed NavigationRail with bottom-right FAB',
    (tester) async {
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
        findsNothing,
      );
      expect(
        find.descendant(
          of: find.byType(Scaffold),
          matching: find.byTooltip('添加自定义版面'),
        ),
        findsOneWidget,
      );
      final fabRect = tester.getRect(find.byTooltip('添加自定义版面'));
      expect(fabRect.right, greaterThan(500));
      expect(fabRect.bottom, greaterThan(600));
    },
  );

  testWidgets(
    'expanded screen uses permanent NavigationDrawer wrapping icon and label with bottom-right FAB',
    (tester) async {
      await _pumpHome(
        tester,
        size: const Size(1000, 800),
        user: const UserInfo(uid: 1, username: '测试用户'),
      );

      expect(find.byType(NavigationRail), findsNothing);
      expect(find.byType(NavigationDrawer), findsOneWidget);
      final drawer = tester.widget<NavigationDrawer>(
        find.byType(NavigationDrawer),
      );
      expect(drawer.selectedIndex, 0);

      // 选中胶囊同时包裹图标和文字（4 个顶级导航项：版块、收藏、消息、我的）
      final indicatorFinder = find.descendant(
        of: find.byType(NavigationDrawer),
        matching: find.byType(NavigationIndicator),
      );
      expect(indicatorFinder, findsNWidgets(4));
      final indicatorRect = tester.getRect(indicatorFinder.first);
      final iconRect = tester.getRect(
        find.descendant(
          of: find.byType(NavigationDrawer),
          matching: find.byIcon(Icons.forum),
        ),
      );
      final labelRect = tester.getRect(
        find.descendant(
          of: find.byType(NavigationDrawer),
          matching: find.text('版块'),
        ),
      );
      expect(indicatorRect.left, lessThanOrEqualTo(iconRect.left));
      expect(indicatorRect.right, greaterThanOrEqualTo(labelRect.right));

      expect(
        find.descendant(
          of: find.byType(NavigationDrawer),
          matching: find.byTooltip('添加自定义版面'),
        ),
        findsNothing,
      );
      final fabFinder = find.descendant(
        of: find.byType(Scaffold),
        matching: find.byTooltip('添加自定义版面'),
      );
      expect(fabFinder, findsOneWidget);
      final fabRect = tester.getRect(fabFinder);
      expect(fabRect.right, greaterThan(800));
      expect(fabRect.bottom, greaterThan(600));

      // 点击「我的」切换到第四个目标，选中胶囊随之切换
      await tester.tap(
        find.descendant(
          of: find.byType(NavigationDrawer),
          matching: find.text('我的'),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<NavigationDrawer>(find.byType(NavigationDrawer))
            .selectedIndex,
        3,
      );
    },
  );

  test('NavigationBar and NavigationDrawer themes use expected M3 colors', () {
    final theme = ThemeBuilder.buildLightTheme(Colors.brown);
    expect(
      theme.navigationBarTheme.backgroundColor,
      theme.colorScheme.surfaceContainer,
    );
    expect(
      theme.navigationDrawerTheme.indicatorColor,
      theme.colorScheme.secondaryContainer,
    );
    expect(theme.navigationDrawerTheme.indicatorShape, const StadiumBorder());
  });

  testWidgets(
    'Apple compact layout uses floating LiquidGlass tab bar and no FAB',
    (tester) async {
      await _pumpHome(
        tester,
        size: const Size(400, 800),
        user: const UserInfo(uid: 1, username: '测试用户'),
        style: AppDesignStyle.apple,
      );

      expect(find.byType(NavigationBar), findsNothing);
      expect(find.byType(FloatingActionButton), findsNothing);
      expect(find.byType(LiquidGlassSurface), findsWidgets);
      expect(find.byTooltip('添加自定义版面'), findsOneWidget);
      expect(find.text('版块'), findsOneWidget);
      expect(find.text('收藏'), findsOneWidget);
      expect(find.text('消息'), findsOneWidget);
      expect(find.text('我的'), findsOneWidget);
    },
  );

  testWidgets(
    'Apple large layout uses AppleWorkspaceShell source list without FAB',
    (tester) async {
      await _pumpHome(
        tester,
        size: const Size(1100, 800),
        user: const UserInfo(uid: 1, username: '测试用户'),
        style: AppDesignStyle.apple,
        macTitlebarInset: 52,
      );

      expect(find.byType(NavigationDrawer), findsNothing);
      expect(find.byType(NavigationRail), findsNothing);
      expect(find.byType(FloatingActionButton), findsNothing);
      expect(find.text('贴子收藏'), findsOneWidget);
      expect(find.text('浏览历史'), findsOneWidget);
      expect(find.text('短消息'), findsOneWidget);
      expect(find.text('提醒信息'), findsOneWidget);
      expect(find.byTooltip('收起侧边栏'), findsOneWidget);

      await tester.tap(find.byTooltip('收起侧边栏'));
      await tester.pumpAndSettle();
      expect(find.byTooltip('展开侧边栏'), findsOneWidget);

      await tester.tap(find.byTooltip('展开侧边栏'));
      await tester.pumpAndSettle();
      expect(find.byTooltip('收起侧边栏'), findsOneWidget);
    },
  );

  testWidgets(
    'switching favourite forums in AppleWorkspaceShell creates distinct ForumDetailPage keys and auto-refreshes each forum',
    (tester) async {
      expect(
        (id: -7, type: 0).toString(),
        isNot(equals((id: 334, type: 0).toString())),
      );

      final refreshedFids = <int>[];
      const forumA = Forum(-7, '大漩涡');
      const forumB = Forum(334, '硬件区');

      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            homeDrawerHeaderProvider.overrideWith(
              () => _FakeHeaderNotifier(const UserInfo(uid: 1, username: '测试')),
            ),
            messageRepositoryProvider.overrideWithValue(
              _FakeMessageRepository(),
            ),
            blocklistSettingsProvider.overrideWith(_FakeBlocklistNotifier.new),
            interfaceSettingsProvider.overrideWith(
              _FakeInterfaceSettingsNotifier.new,
            ),
            favouriteForumListProvider.overrideWith(
              () => _FakeFavouriteForumListNotifier(const [forumA, forumB]),
            ),
            forumCategoryListProvider.overrideWith(
              _FakeForumCategoryListNotifier.new,
            ),
            forumDetailProvider(forumA.fid).overrideWith(
              () => _RecordingForumDetailNotifier(forumA.fid, refreshedFids),
            ),
            forumDetailProvider(forumB.fid).overrideWith(
              () => _RecordingForumDetailNotifier(forumB.fid, refreshedFids),
            ),
            readTopicIdsProvider.overrideWith(_FakeReadTopicIdsNotifier.new),
          ],
          child: AppDesignStyleScope(
            style: AppDesignStyle.apple,
            nativeLiquidGlassSupported: false,
            macTitlebarInset: 52,
            child: MaterialApp(
              theme: ThemeBuilder.applyDesignStyle(
                ThemeBuilder.buildLightTheme(Colors.brown),
                isAppleStyle: true,
                isMacDesktop: true,
              ),
              home: const HomePage(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(refreshedFids, contains(-7));
      expect(find.text('版块 -7 主题'), findsOneWidget);
      final firstKey = tester
          .widget<ForumDetailPage>(find.byType(ForumDetailPage))
          .key;

      await tester.tap(find.text('硬件区'));
      await tester.pumpAndSettle();

      final secondKey = tester
          .widget<ForumDetailPage>(find.byType(ForumDetailPage))
          .key;
      expect(secondKey, isNot(equals(firstKey)));
      expect(refreshedFids, contains(334));
      expect(find.text('版块 334 主题'), findsOneWidget);
      expect(find.text('暂无帖子'), findsNothing);

      // 让 EasyRefresh 完成态的默认 1s 计时器走完，避免 teardown 残留 pending timer
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
    },
  );
}
