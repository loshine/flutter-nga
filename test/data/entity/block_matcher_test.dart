import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_nga/data/entity/block.dart';
import 'package:flutter_nga/data/entity/topic.dart';
import 'package:flutter_nga/data/entity/topic_detail.dart';

Topic _topic({Object? authorId, String? author, String subject = '普通标题'}) {
  return Topic(
    tid: 1,
    fid: 10,
    author: author,
    authorId: authorId,
    subject: subject,
    lastPost: 0,
    replies: 0,
    type: 0,
  );
}

Reply _reply({int? authorId, String subject = '', String content = ''}) {
  return Reply(
    content: content,
    subject: subject,
    authorId: authorId,
    commentList: [],
    attachmentList: [],
  );
}

void main() {
  final matcher = BlockMatcher(
    users: ['', '42', '坏人', ' '],
    words: ['剧透', ''],
  );

  test('matches numeric uid against string entries', () {
    expect(matcher.matchesTopic(_topic(authorId: 42)), isTrue);
    expect(matcher.matchesTopic(_topic(authorId: 43)), isFalse);
  });

  test('matches usernames and anonymous string ids', () {
    expect(matcher.matchesTopic(_topic(author: '坏人')), isTrue);
    expect(
      BlockMatcher(users: ['#anony_1'], words: [])
          .matchesTopic(_topic(authorId: '#anony_1')),
      isTrue,
    );
  });

  test('blank entries never match everything', () {
    expect(matcher.matchesTopic(_topic(author: '')), isFalse);
    expect(matcher.matchesText('任意内容'), isFalse);
    expect(BlockMatcher(users: [' '], words: ['']).isEmpty, isTrue);
  });

  test('keywords match unescaped topic subjects', () {
    expect(matcher.matchesTopic(_topic(subject: '最新&quot;剧透&quot;')), isTrue);
  });

  test('replies match author, subject or content', () {
    expect(matcher.matchesReply(_reply(authorId: 42)), isTrue);
    expect(matcher.matchesReply(_reply(), username: '坏人'), isTrue);
    expect(matcher.matchesReply(_reply(subject: '剧透警告')), isTrue);
    expect(matcher.matchesReply(_reply(content: '[b]剧透[/b]')), isTrue);
    expect(matcher.matchesReply(_reply(content: '正常回复')), isFalse);
  });
}
