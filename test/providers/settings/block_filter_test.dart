import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_nga/data/entity/topic.dart';
import 'package:flutter_nga/data/entity/topic_detail.dart';
import 'package:flutter_nga/providers/settings/blocklist_settings_provider.dart';

const _blocked = Topic(
  tid: 1,
  fid: 10,
  author: '坏人',
  subject: '标题',
  lastPost: 0,
  replies: 0,
  type: 0,
);
const _normal = Topic(
  tid: 2,
  fid: 10,
  author: '好人',
  subject: '标题',
  lastPost: 0,
  replies: 0,
  type: 0,
);

BlockFilter _filter({
  bool client = true,
  bool list = true,
  bool details = true,
  BlockMode mode = BlockMode.COLLAPSE,
}) {
  return BlockFilter.fromSettings(BlocklistSettingsState(
    clientBlockEnabled: client,
    listBlockEnabled: list,
    detailsBlockEnabled: details,
    blockMode: mode,
    blockUserList: const ['坏人'],
  ));
}

void main() {
  test('client switch disables both list and detail blocking', () {
    final filter = _filter(client: false);
    expect(filter.topicMode(_blocked), isNull);
    expect(
      filter.replyMode(
        Reply(content: '', commentList: [], attachmentList: []),
        username: '坏人',
      ),
      isNull,
    );
  });

  test('list and detail switches are independent', () {
    final listOnly = _filter(details: false);
    final reply = Reply(content: '', commentList: [], attachmentList: []);
    expect(listOnly.topicMode(_blocked), BlockMode.COLLAPSE);
    expect(listOnly.replyMode(reply, username: '坏人'), isNull);

    final detailsOnly = _filter(list: false);
    expect(detailsOnly.topicMode(_blocked), isNull);
    expect(detailsOnly.replyMode(reply, username: '坏人'), BlockMode.COLLAPSE);
  });

  test('gone mode removes blocked topics, other modes keep them', () {
    expect(_filter(mode: BlockMode.GONE).visibleTopics([_blocked, _normal]),
        [_normal]);
    expect(_filter(mode: BlockMode.ALPHA).visibleTopics([_blocked, _normal]),
        [_blocked, _normal]);
    expect(
      _filter(mode: BlockMode.GONE, list: false)
          .visibleTopics([_blocked, _normal]),
      [_blocked, _normal],
    );
  });
}
