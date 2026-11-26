import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_nga/data/entity/message.dart';
import 'package:flutter_nga/data/repository/message_repository.dart';
import 'package:flutter_nga/providers/core/repository_providers.dart';
import 'package:flutter_nga/providers/message/message_block_list_provider.dart';

class _FakeMessageRepository extends Fake implements MessageRepository {
  List<MessageParticipant> blockList = const [];

  @override
  Future<List<MessageParticipant>> getMessageBlockList() async => blockList;
}

void main() {
  test('离开页面后释放屏蔽列表，再次进入不会看到上一个账号的缓存', () async {
    final repository = _FakeMessageRepository()
      ..blockList = const [(uid: 7, username: 'bob')];
    final container = ProviderContainer(
      overrides: [messageRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    final subscription = container.listen(messageBlockListProvider, (_, _) {});
    await container.read(messageBlockListProvider.notifier).refresh();
    expect(subscription.read(), const [(uid: 7, username: 'bob')]);

    // 模拟离开页面（例如去切换账号），provider 无人监听后被释放
    subscription.close();
    await container.pump();

    final reopened = container.listen(messageBlockListProvider, (_, _) {});
    addTearDown(reopened.close);
    expect(reopened.read(), isEmpty);
  });

  test('请求返回前页面已关闭时不抛异常', () async {
    final repository = _FakeMessageRepository();
    final container = ProviderContainer(
      overrides: [messageRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    final subscription = container.listen(messageBlockListProvider, (_, _) {});
    final pending = container.read(messageBlockListProvider.notifier).refresh();
    subscription.close();
    await container.pump();

    await expectLater(pending, completion(isEmpty));
  });
}
