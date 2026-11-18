import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:flutter_nga/data/entity/notification.dart';
import 'package:flutter_nga/data/entity/user.dart';
import 'package:flutter_nga/data/repository/message_repository.dart';
import 'package:flutter_nga/providers/core/repository_providers.dart';
import 'package:flutter_nga/providers/home/home_drawer_header_provider.dart';
import 'package:flutter_nga/providers/notification/unread_count_provider.dart';
import 'package:flutter_nga/ui/page/mine/mine_page.dart';

class _FakeHeaderNotifier extends HomeDrawerHeaderNotifier {
  _FakeHeaderNotifier(this.user);

  UserInfo? user;

  void switchTo(UserInfo? next) {
    user = next;
    state = next;
  }

  @override
  UserInfo? build() => null;

  @override
  Future<void> refresh() async => state = user;
}

class _FakeMessageRepository implements MessageRepository {
  int infoCalls = 0;
  Completer<void>? gate;

  @override
  Future<NotificationInfo> getNotificationInfo() async {
    infoCalls++;
    await gate?.future;
    return NotificationInfo(
      unreadReplyCount: 2,
      unreadSystemNotificationCount: 1,
      unreadMessageCount: 5,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

late _FakeHeaderNotifier _header;

Future<_FakeMessageRepository> _pump(
  WidgetTester tester,
  UserInfo? user,
) async {
  final repository = _FakeMessageRepository();
  _header = _FakeHeaderNotifier(user);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        homeDrawerHeaderProvider.overrideWith(() => _header),
        messageRepositoryProvider.overrideWithValue(repository),
      ],
      child: const MaterialApp(home: Scaffold(body: MinePage())),
    ),
  );
  await tester.pumpAndSettle();
  return repository;
}

String? _badgeLabel(WidgetTester tester, String title) {
  final tile = find.ancestor(of: find.text(title), matching: find.byType(Row));
  final badge = tester.widget<Badge>(
    find.descendant(of: tile.first, matching: find.byType(Badge)),
  );
  if (!badge.isLabelVisible) return null;
  return (badge.label as Text?)?.data;
}

void main() {
  testWidgets('logged in users see unread badges', (tester) async {
    final repository = await _pump(
      tester,
      const UserInfo(uid: 1, username: '测试用户'),
    );
    expect(repository.infoCalls, 1);
    expect(_badgeLabel(tester, '提醒信息'), '3');
    expect(_badgeLabel(tester, '短消息'), '5');
  });

  testWidgets('logged out users see no badge and send no request', (
    tester,
  ) async {
    final repository = await _pump(tester, null);
    expect(repository.infoCalls, 0);
    expect(_badgeLabel(tester, '提醒信息'), isNull);
    expect(_badgeLabel(tester, '短消息'), isNull);
  });

  testWidgets('logging in while on the page fetches the badges', (
    tester,
  ) async {
    final repository = await _pump(tester, null);
    expect(repository.infoCalls, 0);

    _header.switchTo(const UserInfo(uid: 1, username: '测试用户'));
    await tester.pumpAndSettle();
    expect(repository.infoCalls, 1);
    expect(_badgeLabel(tester, '提醒信息'), '3');
  });

  testWidgets('switching accounts refetches the badges', (tester) async {
    final repository = await _pump(
      tester,
      const UserInfo(uid: 1, username: '账号A'),
    );
    expect(repository.infoCalls, 1);

    _header.switchTo(const UserInfo(uid: 2, username: '账号B'));
    await tester.pumpAndSettle();
    expect(repository.infoCalls, 2);

    _header.switchTo(null);
    await tester.pumpAndSettle();
    expect(repository.infoCalls, 2);
    expect(_badgeLabel(tester, '短消息'), isNull);
  });

  test('counts fetched for a previous account are dropped', () async {
    final repository = _FakeMessageRepository()..gate = Completer<void>();
    final header = _FakeHeaderNotifier(null);
    final container = ProviderContainer(
      overrides: [
        homeDrawerHeaderProvider.overrideWith(() => header),
        messageRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);
    container.read(homeDrawerHeaderProvider);
    header.switchTo(const UserInfo(uid: 1));

    final notifier = container.read(unreadCountProvider.notifier);
    final pending = notifier.refresh();
    header.switchTo(const UserInfo(uid: 2));
    repository.gate!.complete();
    await pending;

    expect(notifier.countsFor(1).notifications, 0);
    expect(notifier.countsFor(2).notifications, 0);
  });
}
