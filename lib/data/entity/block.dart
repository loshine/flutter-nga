import 'package:flutter_nga/data/entity/topic.dart';
import 'package:flutter_nga/data/entity/topic_detail.dart';
import 'package:flutter_nga/utils/code_utils.dart' as code_utils;

class BlockInfoData {
  final List<String> blockUserList;
  final List<String> blockWordList;

  BlockInfoData(this.blockUserList, this.blockWordList);

  factory BlockInfoData.fromJson(Map map) {
    String data = map["0"];
    final userList = <String>[];
    final wordList = <String>[];
    // 1 代表有屏蔽信息
    if (data.startsWith("1\n")) {
      // 第一个 \n 后是屏蔽词
      final wordsAndUsers = data.substring("1\n".length);
      // 第二个 \n 后是屏蔽用户
      final secondGapIndex = wordsAndUsers.indexOf("\n");
      // 如果没有第二个 \n
      if (secondGapIndex < 0) {
        wordList.addAll(wordsAndUsers.split(" ").where((e) => e != ""));
      } else {
        final words = wordsAndUsers.substring(0, secondGapIndex);
        final users = wordsAndUsers.substring(secondGapIndex + 1);
        wordList.addAll(words.split(" ").where((e) => e != ""));
        userList.addAll(users.split(" "));
      }
    }
    return BlockInfoData(userList, wordList);
  }

  String toData() {
    final data = StringBuffer();
    if (blockWordList.isNotEmpty || blockUserList.isNotEmpty) {
      data.write("1\n");
      if (blockWordList.isNotEmpty) {
        data.write(blockWordList.reduce((value, e) => "$value $e"));
      }
      if (blockUserList.isNotEmpty) {
        data.write("\n");
        data.write(blockUserList.reduce((value, e) => "$value $e"));
      }
    }
    return data.toString();
  }
}

/// 屏蔽名单匹配规则，与展示无关，列表与详情共用
///
/// 服务端名单中的用户条目既可能是用户名也可能是 uid，
/// 因此同时用用户名和 uid 字符串比对；关键词对标题与正文做子串匹配。
class BlockMatcher {
  BlockMatcher({
    required Iterable<String> users,
    required Iterable<String> words,
  })  : _users = users.map((e) => e.trim()).where((e) => e.isNotEmpty).toSet(),
        _words =
            words.map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

  final Set<String> _users;
  final List<String> _words;

  bool get isEmpty => _users.isEmpty && _words.isEmpty;

  /// [uid] 可能是 int（普通用户）或 String（匿名用户），统一按字符串比对
  bool matchesUser({Object? uid, String? username}) {
    if (uid != null && _users.contains(uid.toString())) return true;
    return username != null && _users.contains(username);
  }

  bool matchesText(String? text) {
    if (text == null || text.isEmpty) return false;
    return _words.any(text.contains);
  }

  bool matchesTopic(Topic topic) {
    return matchesUser(uid: topic.authorId, username: topic.author) ||
        matchesText(code_utils.unescapeHtml(topic.subject));
  }

  /// [username] 来自楼层对应的 User，Reply 本身只有 authorId
  bool matchesReply(Reply reply, {String? username}) {
    return matchesUser(uid: reply.authorId, username: username) ||
        matchesText(code_utils.unescapeHtml(reply.subject)) ||
        matchesText(reply.content);
  }
}
