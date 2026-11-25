import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:flutter_nga/data/entity/conversation.dart';
import 'package:flutter_nga/data/entity/topic.dart';
import 'package:flutter_nga/providers/forum/favourite_forum_list_provider.dart';
import 'package:flutter_nga/providers/forum/forum_detail_provider.dart';
import 'package:flutter_nga/providers/message/conversation_detail_provider.dart';
import 'package:flutter_nga/providers/message/conversation_list_provider.dart';
import 'package:flutter_nga/providers/settings/base_url_settings_provider.dart';
import 'package:flutter_nga/providers/settings/blocklist_settings_provider.dart';
import 'package:flutter_nga/providers/settings/interface_settings_provider.dart';
import 'package:flutter_nga/providers/settings/theme_provider.dart';
import 'package:flutter_nga/providers/settings/user_agent_settings_provider.dart';
import 'package:flutter_nga/providers/topic/topic_history_provider.dart';
import 'package:flutter_nga/providers/topic/topic_single_page_provider.dart';
import 'package:flutter_nga/ui/page/conversation/conversation_detail_page.dart';
import 'package:flutter_nga/ui/page/conversation/conversation_list_page.dart';
import 'package:flutter_nga/ui/page/forum_detail/forum_detail_page.dart';
import 'package:flutter_nga/ui/page/settings/blocklist_settings_page.dart';
import 'package:flutter_nga/ui/page/settings/interface_settings_page.dart';
import 'package:flutter_nga/ui/page/settings/settings_page.dart';
import 'package:flutter_nga/ui/page/topic_detail/topic_detail_page.dart';
import 'package:flutter_nga/ui/widget/adaptive_layout.dart';
import 'package:flutter_nga/utils/theme_builder.dart';

class _FakeForumDetailNotifier extends ForumDetailNotifier {
  _FakeForumDetailNotifier(super.arg, this._topics);

  final List<Topic> _topics;

  @override
  ForumDetailState build() =>
      ForumDetailState(page: 1, maxPage: 1, enablePullUp: false, list: _topics);

  @override
  Future<ForumDetailState> refresh(bool isRecommend, int? type) async {
    return state;
  }
}

class _FakeForumRecommendNotifier extends ForumDetailNotifier {
  _FakeForumRecommendNotifier(super.arg);

  @override
  ForumDetailState build() => const ForumDetailState(enablePullUp: false);

  @override
  Future<ForumDetailState> refresh(bool isRecommend, int? type) async => state;
}

class _FakeTopicSinglePageNotifier extends TopicSinglePageNotifier {
  _FakeTopicSinglePageNotifier(super.arg);

  @override
  Future<TopicSinglePageState> refresh() {
    // 保持未完成避免网络调用，仅验证详情页挂载与标题展示
    return Completer<TopicSinglePageState>().future;
  }
}

class _FakeTopicHistoryNotifier extends TopicHistoryNotifier {
  @override
  void build() {}

  @override
  Future<int> insertHistory(history) async => 1;
}

class _FakeReadTopicIdsNotifier extends ReadTopicIdsNotifier {
  @override
  Set<int> build() => const {};
}

class _FakeFavouriteForumListNotifier extends FavouriteForumListNotifier {
  @override
  FavouriteForumListState build() => const FavouriteForumListState();

  @override
  Future<void> ensureLoaded() async {}
}

class _FakeConversationListNotifier extends ConversationListNotifier {
  _FakeConversationListNotifier(this._list);

  final List<Conversation> _list;

  @override
  ConversationListState build() =>
      ConversationListState(page: 1, enablePullUp: false, list: _list);

  @override
  Future<ConversationListState> refresh() async => state;
}

class _FakeConversationDetailNotifier extends ConversationDetailNotifier {
  _FakeConversationDetailNotifier(super.arg);

  @override
  ConversationDetailState build() =>
      const ConversationDetailState(page: 1, enablePullUp: false);

  @override
  Future<ConversationDetailState> refresh() async => state;
}

class _FakeThemeNotifier extends ThemeNotifier {
  @override
  Future<void> refresh() async {}
}

class _FakeBaseUrlNotifier extends BaseUrlSettingsNotifier {
  @override
  Future<void> init() async {}
}

class _FakeUserAgentNotifier extends UserAgentSettingsNotifier {
  @override
  Future<void> init() async {}
}

class _FakeBlocklistNotifier extends BlocklistSettingsNotifier {
  @override
  Future<void> load() async {}
}

class _FakeInterfaceSettingsNotifier extends InterfaceSettingsNotifier {
  @override
  Future<void> init() async {}
}

Future<void> _setSurface(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

void main() {
  group('WindowSizeClass', () {
    test('classifies widths according to M3 breakpoints', () {
      expect(WindowSizeClass.fromWidth(390), WindowSizeClass.compact);
      expect(WindowSizeClass.fromWidth(599), WindowSizeClass.compact);
      expect(WindowSizeClass.fromWidth(600), WindowSizeClass.medium);
      expect(WindowSizeClass.fromWidth(839), WindowSizeClass.medium);
      expect(WindowSizeClass.fromWidth(840), WindowSizeClass.expanded);
      expect(WindowSizeClass.fromWidth(1199), WindowSizeClass.expanded);
      expect(WindowSizeClass.fromWidth(1200), WindowSizeClass.large);
    });
  });

  group('MasterDetailLayout', () {
    testWidgets('shows only master pane below breakpoint', (tester) async {
      await _setSurface(tester, const Size(700, 800));
      var observedTwoPane = true;
      await tester.pumpWidget(
        MaterialApp(
          home: MasterDetailLayout(
            masterBuilder: (_, isTwoPane) {
              observedTwoPane = isTwoPane;
              return const Scaffold(body: Text('Master'));
            },
            detailBuilder: (_) => const Scaffold(body: Text('Detail')),
          ),
        ),
      );

      expect(observedTwoPane, isFalse);
      expect(find.text('Master'), findsOneWidget);
      expect(find.text('Detail'), findsNothing);
    });

    testWidgets('shows master and detail side by side at or above breakpoint', (
      tester,
    ) async {
      await _setSurface(tester, const Size(1000, 800));
      var observedTwoPane = false;
      await tester.pumpWidget(
        MaterialApp(
          home: MasterDetailLayout(
            masterBuilder: (_, isTwoPane) {
              observedTwoPane = isTwoPane;
              return const Scaffold(body: Text('Master'));
            },
            detailBuilder: (_) => const Scaffold(body: Text('Detail')),
          ),
        ),
      );

      expect(observedTwoPane, isTrue);
      expect(find.text('Master'), findsOneWidget);
      expect(find.text('Detail'), findsOneWidget);
      expect(
        tester.getRect(find.text('Master')).right,
        lessThan(tester.getRect(find.text('Detail')).left),
      );
    });
  });

  testWidgets(
    'ForumDetailPage opens selected topic in right pane on large screen',
    (tester) async {
      await _setSurface(tester, const Size(1200, 800));
      const sampleTopic = Topic(
        tid: 1001,
        fid: -7,
        type: 0,
        subject: '大屏分栏测试主题',
        author: '测试作者',
        replies: 12,
        lastPost: 1700000000,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            forumDetailProvider.overrideWith2(
              (fid) => _FakeForumDetailNotifier(fid, const [sampleTopic]),
            ),
            forumRecommendProvider.overrideWith2(
              _FakeForumRecommendNotifier.new,
            ),
            favouriteForumListProvider.overrideWith(
              _FakeFavouriteForumListNotifier.new,
            ),
            topicSinglePageProvider.overrideWith2(
              _FakeTopicSinglePageNotifier.new,
            ),
            topicHistoryProvider.overrideWith(_FakeTopicHistoryNotifier.new),
            readTopicIdsProvider.overrideWith(_FakeReadTopicIdsNotifier.new),
            blocklistSettingsProvider.overrideWith(_FakeBlocklistNotifier.new),
            interfaceSettingsProvider.overrideWith(
              _FakeInterfaceSettingsNotifier.new,
            ),
          ],
          child: MaterialApp(
            theme: ThemeBuilder.buildLightTheme(Colors.brown),
            home: const ForumDetailPage(fid: -7, name: '大漩涡', type: 0),
          ),
        ),
      );
      await tester.pump();
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      expect(find.text('选择一篇帖子开始阅读'), findsOneWidget);
      expect(find.byType(TopicDetailPage), findsNothing);

      await tester.tap(find.text('大屏分栏测试主题'));
      await tester.pump();
      await tester.pump();

      expect(find.byType(TopicDetailPage), findsOneWidget);
      final detailWidget = tester.widget<TopicDetailPage>(
        find.byType(TopicDetailPage),
      );
      expect(detailWidget.embedded, isTrue);
      expect(detailWidget.tid, 1001);

      // 点击关闭按钮恢复空态占位
      await tester.tap(find.byTooltip('关闭'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));
      expect(find.byType(TopicDetailPage), findsNothing);
      expect(find.text('选择一篇帖子开始阅读'), findsOneWidget);
    },
  );

  testWidgets('SettingsPage shows two panes and switches right detail pane', (
    tester,
  ) async {
    await _setSurface(tester, const Size(1100, 800));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          themeProvider.overrideWith(_FakeThemeNotifier.new),
          baseUrlSettingsProvider.overrideWith(_FakeBaseUrlNotifier.new),
          userAgentSettingsProvider.overrideWith(_FakeUserAgentNotifier.new),
          blocklistSettingsProvider.overrideWith(_FakeBlocklistNotifier.new),
          interfaceSettingsProvider.overrideWith(
            _FakeInterfaceSettingsNotifier.new,
          ),
        ],
        child: MaterialApp(
          theme: ThemeBuilder.buildLightTheme(Colors.brown),
          home: const SettingsPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 默认在右侧显示界面设置
    expect(find.byType(InterfaceSettingsPage), findsOneWidget);
    expect(find.byType(BlocklistSettingsPage), findsNothing);

    await tester.tap(find.text('屏蔽设置'));
    await tester.pumpAndSettle();

    expect(find.byType(BlocklistSettingsPage), findsOneWidget);
    expect(
      tester
          .widget<BlocklistSettingsPage>(find.byType(BlocklistSettingsPage))
          .embedded,
      isTrue,
    );
  });

  testWidgets(
    'ConversationListPage opens selected conversation in right pane on large screen',
    (tester) async {
      await _setSurface(tester, const Size(1100, 800));
      final sampleConversation = Conversation(
        42,
        1700000000,
        0,
        '大屏私信测试',
        1,
        1700000000,
        2,
        3,
        0,
        '用户A',
        '用户B',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            conversationListProvider.overrideWith(
              () => _FakeConversationListNotifier([sampleConversation]),
            ),
            conversationDetailProvider.overrideWith2(
              _FakeConversationDetailNotifier.new,
            ),
          ],
          child: MaterialApp(
            theme: ThemeBuilder.buildLightTheme(Colors.brown),
            home: const ConversationListPage(),
          ),
        ),
      );
      await tester.pump();
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      expect(find.text('选择一段对话查看消息'), findsOneWidget);
      expect(find.byType(ConversationDetailPage), findsNothing);

      await tester.tap(find.textContaining('大屏私信测试'));
      await tester.pump();
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      expect(find.byType(ConversationDetailPage), findsOneWidget);
      expect(
        tester
            .widget<ConversationDetailPage>(find.byType(ConversationDetailPage))
            .embedded,
        isTrue,
      );
    },
  );
}
