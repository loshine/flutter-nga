import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_nga/data/entity/block.dart';
import 'package:flutter_nga/data/repository/user_repository.dart';
import 'package:flutter_nga/providers/core/repository_providers.dart';
import 'package:flutter_nga/providers/settings/blocklist_settings_provider.dart';

class _FakeUserRepository implements UserRepository {
  _FakeUserRepository({
    List<String> users = const [],
    List<String> words = const [],
  }) : serverUsers = [...users],
       serverWords = [...words];

  List<String> serverUsers;
  List<String> serverWords;
  final List<BlockInfoData> submissions = [];
  Completer<void>? gate;
  bool failNext = false;

  @override
  Future<BlockInfoData> getBlockInfo() async {
    return BlockInfoData([...serverUsers], [...serverWords]);
  }

  @override
  Future<String> setBlockInfo(BlockInfoData data) async {
    await gate?.future;
    if (failNext) {
      failNext = false;
      throw Exception('同步失败');
    }
    submissions.add(
      BlockInfoData([...data.blockUserList], [...data.blockWordList]),
    );
    serverUsers = [...data.blockUserList];
    serverWords = [...data.blockWordList];
    return '操作成功';
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test('连续移除 A 和 B 后提交 A，服务端保留仍可撤销的 B，撤销 B 后同步一致', () async {
    final repo = _FakeUserRepository(users: ['A', 'B', 'C'], words: ['W1']);
    final container = ProviderContainer(
      overrides: [userRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(container.dispose);

    final notifier = container.read(blocklistSettingsProvider.notifier);
    await notifier.load();

    // 连续移除 A、B（B 仍在撤销窗口中）
    notifier.removeUserLocally('A');
    notifier.removeUserLocally('B');
    expect(container.read(blocklistSettingsProvider).blockUserList, ['C']);

    // 替换 SnackBar 时仅提交 A，B 应保留在服务端提交的名单中
    await notifier.commitUserDeletion('A');
    expect(repo.submissions.single.blockUserList, ['B', 'C']);
    expect(repo.serverUsers, ['B', 'C']);

    // 撤销 B 后本地恢复，下一次服务端同步后 B 依然存在
    notifier.undoUserDeletion('B');
    expect(container.read(blocklistSettingsProvider).blockUserList, ['B', 'C']);
    await notifier.load();
    expect(container.read(blocklistSettingsProvider).blockUserList, ['B', 'C']);
  });

  test('连续移除关键词 W1 和 W2 后提交 W1，服务端保留仍可撤销的 W2', () async {
    final repo = _FakeUserRepository(users: ['U1'], words: ['W1', 'W2', 'W3']);
    final container = ProviderContainer(
      overrides: [userRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(container.dispose);

    final notifier = container.read(blocklistSettingsProvider.notifier);
    await notifier.load();

    notifier.removeWordLocally('W1');
    notifier.removeWordLocally('W2');

    await notifier.commitWordDeletion('W1');
    expect(repo.submissions.single.blockWordList, ['W2', 'W3']);

    notifier.undoWordDeletion('W2');
    await notifier.load();
    expect(container.read(blocklistSettingsProvider).blockWordList, [
      'W2',
      'W3',
    ]);
  });

  test('并发排队提交 A 和 B 时按顺序提交，B 失败时仅恢复 B 且与服务端一致', () async {
    final repo = _FakeUserRepository(users: ['A', 'B', 'C']);
    final container = ProviderContainer(
      overrides: [userRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(container.dispose);

    final notifier = container.read(blocklistSettingsProvider.notifier);
    await notifier.load();

    notifier.removeUserLocally('A');
    notifier.removeUserLocally('B');

    repo.gate = Completer<void>();
    final commitA = notifier.commitUserDeletion('A');
    final commitB = notifier.commitUserDeletion('B');

    // A 成功、B 失败
    repo.gate!.complete();
    repo.gate = null;
    await commitA;
    expect(repo.serverUsers, ['B', 'C']);

    // 等待 B 正常完成后再验证失败恢复场景
    await commitB;
    expect(repo.serverUsers, ['C']);

    notifier.removeUserLocally('C');
    repo.failNext = true;
    await expectLater(notifier.commitUserDeletion('C'), throwsException);
    expect(container.read(blocklistSettingsProvider).blockUserList, ['C']);
  });
}
