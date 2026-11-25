import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:flutter_nga/data/entity/forum.dart';
import 'package:flutter_nga/data/entity/notification.dart';
import 'package:flutter_nga/data/entity/topic.dart';
import 'package:flutter_nga/data/entity/user.dart';
import 'package:flutter_nga/data/repository/message_repository.dart';
import 'package:flutter_nga/my_app.dart';
import 'package:flutter_nga/providers/core/repository_providers.dart';
import 'package:flutter_nga/providers/forum/favourite_forum_list_provider.dart';
import 'package:flutter_nga/providers/forum/forum_category_list_provider.dart';
import 'package:flutter_nga/providers/forum/forum_detail_provider.dart';
import 'package:flutter_nga/providers/home/home_drawer_header_provider.dart';
import 'package:flutter_nga/providers/home/home_provider.dart';
import 'package:flutter_nga/providers/settings/blocklist_settings_provider.dart';
import 'package:flutter_nga/providers/settings/design_style_provider.dart';
import 'package:flutter_nga/providers/settings/interface_settings_provider.dart';
import 'package:flutter_nga/providers/topic/topic_history_provider.dart';
import 'package:flutter_nga/ui/page/forum_detail/forum_detail_page.dart';
import 'package:flutter_nga/ui/page/home/apple_workspace_shell.dart';
import 'package:flutter_nga/ui/page/home/home_page.dart';
import 'package:flutter_nga/ui/widget/adaptive/liquid_glass_surface.dart';
import 'package:flutter_nga/utils/route.dart';
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
          matching: find.byTooltip('添加自定义版块'),
        ),
        findsNothing,
      );
      expect(
        find.descendant(
          of: find.byType(Scaffold),
          matching: find.byTooltip('添加自定义版块'),
        ),
        findsOneWidget,
      );
      final fabRect = tester.getRect(find.byTooltip('添加自定义版块'));
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
          matching: find.byTooltip('添加自定义版块'),
        ),
        findsNothing,
      );
      final fabFinder = find.descendant(
        of: find.byType(Scaffold),
        matching: find.byTooltip('添加自定义版块'),
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
      expect(find.byTooltip('添加自定义版块'), findsOneWidget);
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
      expect(find.text('搜索…'), findsOneWidget);
      expect(find.byTooltip('添加自定义版块'), findsOneWidget);
      expect(find.byTooltip('收起侧边栏'), findsOneWidget);

      // 点击添加自定义版块按钮可打开新版弹窗
      await tester.tap(find.byTooltip('添加自定义版块'));
      await tester.pumpAndSettle();
      expect(find.text('添加自定义版块'), findsOneWidget);
      expect(find.text('版块 ID (fid)'), findsOneWidget);
      expect(find.text('版块名称'), findsOneWidget);
      await tester.tap(find.text('取消'));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('收起侧边栏'));
      await tester.pumpAndSettle();
      expect(find.byTooltip('展开侧边栏'), findsOneWidget);

      await tester.tap(find.byTooltip('展开侧边栏'));
      await tester.pumpAndSettle();
      expect(find.byTooltip('收起侧边栏'), findsOneWidget);

      // ⌃⌘S 快捷键切换侧边栏收起与展开
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.metaLeft);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.keyS);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.keyS);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.metaLeft);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pumpAndSettle();
      expect(find.byTooltip('展开侧边栏'), findsOneWidget);
    },
  );

  testWidgets(
    'switching favourite forums in AppleWorkspaceShell creates distinct ForumDetailPage keys and auto-refreshes each forum',
    (tester) async {
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

  testWidgets(
    'iPhone landscape keeps Apple 4-tab layout instead of switching to AppleWorkspaceShell',
    (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);

      await _pumpHome(
        tester,
        size: const Size(932, 430),
        user: const UserInfo(uid: 1, username: '测试用户'),
        style: AppDesignStyle.apple,
      );

      expect(find.byType(AppleWorkspaceShell), findsNothing);
      expect(find.byType(NavigationDrawer), findsNothing);
      expect(find.byType(LiquidGlassSurface), findsWidgets);
      expect(find.text('版块'), findsOneWidget);
      expect(find.text('收藏'), findsOneWidget);
      expect(find.text('消息'), findsOneWidget);
      expect(find.text('我的'), findsOneWidget);
    },
  );

  testWidgets(
    'AppleWorkspaceShell respects left safe area padding in sidebar',
    (tester) async {
      tester.view.padding = const FakeViewPadding(left: 44);
      await _pumpHome(
        tester,
        size: const Size(1100, 800),
        user: const UserInfo(uid: 1, username: '测试用户'),
        style: AppDesignStyle.apple,
      );

      expect(find.byType(AppleWorkspaceShell), findsOneWidget);
      final favTopicsRect = tester.getRect(find.text('贴子收藏'));
      expect(favTopicsRect.left, greaterThanOrEqualTo(44));
    },
  );

  testWidgets(
    'dispatchNativeMenuNavigate deduplicates imperative pushes, delegates workspace items, and ignores while modal is open',
    (tester) async {
      final observer = TopRouteObserver();
      final workspaceMenu = WorkspaceMenuController();
      late BuildContext homeContext;

      final router = GoRouter(
        initialLocation: Routes.HOME,
        observers: [observer],
        routes: [
          GoRoute(
            path: Routes.HOME,
            builder: (context, _) {
              homeContext = context;
              return const Scaffold(body: Text('HOME_PAGE'));
            },
          ),
          GoRoute(
            path: Routes.SEARCH,
            builder: (_, _) => const Scaffold(body: Text('SEARCH_PAGE')),
          ),
          GoRoute(
            path: Routes.SETTINGS,
            builder: (_, _) => const Scaffold(body: Text('SETTINGS_PAGE')),
          ),
          GoRoute(
            path: Routes.TOPIC_PUBLISH,
            builder: (_, _) => const Scaffold(body: Text('PUBLISH_PAGE')),
          ),
        ],
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      // 1. 连续触发两次 /search 不会重复压栈，pop 一次即回到首页
      dispatchNativeMenuNavigate(
        router: router,
        routeObserver: observer,
        workspaceMenu: workspaceMenu,
        path: Routes.SEARCH,
      );
      await tester.pumpAndSettle();
      expect(find.text('SEARCH_PAGE'), findsOneWidget);

      dispatchNativeMenuNavigate(
        router: router,
        routeObserver: observer,
        workspaceMenu: workspaceMenu,
        path: Routes.SEARCH,
      );
      await tester.pumpAndSettle();

      router.pop();
      await tester.pumpAndSettle();
      expect(find.text('HOME_PAGE'), findsOneWidget);
      expect(router.canPop(), isFalse);

      // 2. 工作区活跃时，⌘1~⌘4 与 ⌘, 交由工作区处理而不压栈；在二级页触发时先回首页
      final handledPaths = <String>[];
      bool handler(String path) {
        handledPaths.add(path);
        return true;
      }

      workspaceMenu.register(handler);
      dispatchNativeMenuNavigate(
        router: router,
        routeObserver: observer,
        workspaceMenu: workspaceMenu,
        path: Routes.FAVOURITE_TOPICS,
      );
      dispatchNativeMenuNavigate(
        router: router,
        routeObserver: observer,
        workspaceMenu: workspaceMenu,
        path: Routes.TOPIC_HISTORY,
      );
      await tester.pumpAndSettle();
      expect(handledPaths, [Routes.FAVOURITE_TOPICS, Routes.TOPIC_HISTORY]);
      expect(router.canPop(), isFalse);

      // 从 /search 触发工作区目标会先 pop 回 /home
      dispatchNativeMenuNavigate(
        router: router,
        routeObserver: observer,
        workspaceMenu: workspaceMenu,
        path: Routes.SEARCH,
      );
      await tester.pumpAndSettle();
      expect(find.text('SEARCH_PAGE'), findsOneWidget);

      dispatchNativeMenuNavigate(
        router: router,
        routeObserver: observer,
        workspaceMenu: workspaceMenu,
        path: Routes.SETTINGS,
      );
      await tester.pumpAndSettle();
      expect(find.text('HOME_PAGE'), findsOneWidget);
      expect(handledPaths.last, Routes.SETTINGS);

      // 3. 模态弹窗打开时忽略菜单快捷键
      showDialog<void>(
        context: homeContext,
        builder: (_) => const AlertDialog(content: Text('MODAL_OPEN')),
      );
      await tester.pumpAndSettle();
      expect(find.text('MODAL_OPEN'), findsOneWidget);

      dispatchNativeMenuNavigate(
        router: router,
        routeObserver: observer,
        workspaceMenu: workspaceMenu,
        path: Routes.SEARCH,
      );
      dispatchNativeMenuNavigate(
        router: router,
        routeObserver: observer,
        workspaceMenu: workspaceMenu,
        path: Routes.SETTINGS,
      );
      await tester.pumpAndSettle();
      expect(find.text('SEARCH_PAGE'), findsNothing);
      expect(handledPaths.length, 3);

      // 4. 在设置 Sheet 上再压入子路由后触发 ⌘1/⌘,，退回露出设置 Sheet 后停止分发
      router.push(Routes.SEARCH);
      await tester.pumpAndSettle();
      expect(find.text('SEARCH_PAGE'), findsOneWidget);

      dispatchNativeMenuNavigate(
        router: router,
        routeObserver: observer,
        workspaceMenu: workspaceMenu,
        path: Routes.FAVOURITE_TOPICS,
      );
      await tester.pumpAndSettle();
      expect(find.text('SEARCH_PAGE'), findsNothing);
      expect(find.text('MODAL_OPEN'), findsOneWidget);
      expect(handledPaths.length, 3);

      Navigator.of(homeContext).pop();
      await tester.pumpAndSettle();
    },
  );
}
