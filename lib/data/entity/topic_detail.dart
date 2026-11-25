import 'dart:core';

import 'package:flutter_nga/data/core/nga_domains.dart';
import 'package:flutter_nga/data/entity/topic.dart';
import 'package:flutter_nga/data/entity/user.dart';
import 'package:flutter_nga/utils/json_cast.dart';

class TopicDetailData {
  final Map<String, Reply> replyList;
  final Map<String, User> userList;

  final Map<String, Group> groupList;
  final Map<String, Medal> medalList;
  final Map<String, Reputation> reputationList;

  final dynamic global;
  final int rows;
  final int currentRows;
  final int replyPageRows;

  final Topic topic;
  final List<int> hotReplies;

  const TopicDetailData({
    this.global,
    required this.userList,
    required this.replyList,
    required this.groupList,
    required this.medalList,
    required this.reputationList,
    required this.rows,
    required this.currentRows,
    required this.replyPageRows,
    required this.topic,
    required this.hotReplies,
  });

  factory TopicDetailData.fromJson(Map<String, dynamic> map) {
    final userMap = asJsonMap(map["__U"], 'TopicDetailData.__U');
    final replyMap = asJsonMap(map["__R"], 'TopicDetailData.__R');
    final topicInfoMap = asJsonMap(map["__T"], 'TopicDetailData.__T');
    Map<String, User> tempUserMap = {};
    Map<String, Group> tempGroupMap = {};
    Map<String, Medal> tempMedalMap = {};
    Map<String, Reputation> tempReputationMap = {};
    for (MapEntry<String, dynamic> entry in userMap.entries) {
      int? key = int.tryParse(entry.key);
      if (key == null) {
        // __GROUPS 用户等级
        if ("__GROUPS" == entry.key) {
          final groups = asJsonMap(entry.value, 'TopicDetailData.__U.__GROUPS');
          for (final m in groups.entries) {
            tempGroupMap[m.key] = Group.fromJson(
              asJsonMap(m.value, 'TopicDetailData.__U.__GROUPS.${m.key}'),
            );
          }
        } else if ("__MEDALS" == entry.key) {
          // __MEDALS 奖牌
          final medals = asJsonMap(entry.value, 'TopicDetailData.__U.__MEDALS');
          for (final m in medals.entries) {
            tempMedalMap[m.key] = Medal.fromJson(
              asJsonMap(m.value, 'TopicDetailData.__U.__MEDALS.${m.key}'),
            );
          }
        } else if ("__REPUTATIONS" == entry.key) {
          // __REPUTATIONS 威望
          final reputations = asJsonMap(
            entry.value,
            'TopicDetailData.__U.__REPUTATIONS',
          );
          for (final m in reputations.entries) {
            tempReputationMap[m.key] = Reputation.fromJson(
              asJsonMap(m.value, 'TopicDetailData.__U.__REPUTATIONS.${m.key}'),
            );
          }
        }
      } else {
        tempUserMap[entry.key] = User.fromJson(
          asJsonMap(entry.value, 'TopicDetailData.__U.${entry.key}'),
        );
        if (key != tempUserMap[entry.key]!.uid) {
          tempUserMap[entry.key]!.uid = key;
        }
      }
    }
    Map<String, Reply> tempReplyMap = {};
    for (MapEntry<String, dynamic> entry in replyMap.entries) {
      tempReplyMap[entry.key] = Reply.fromJson(
        asJsonMap(entry.value, 'TopicDetailData.__R.${entry.key}'),
      );
    }
    final topicMisc =
        asJsonMapOrNull(
          topicInfoMap["post_misc_var"],
          'TopicDetailData.__T.post_misc_var',
        ) ??
        {};
    List<int> hotReplies = [];
    if (topicMisc.containsKey("17")) {
      final hots = topicMisc["17"]?.toString() ?? "";
      hotReplies.addAll(
        hots
            .split(",")
            .where((e) => e.isNotEmpty)
            .map((e) => int.tryParse(e))
            .where((e) => e != null)
            .cast(),
      );
    }
    return TopicDetailData(
      global: map["__GLOBAL"],
      userList: tempUserMap,
      replyList: tempReplyMap,
      groupList: tempGroupMap,
      medalList: tempMedalMap,
      reputationList: tempReputationMap,
      currentRows: _asInt(map["__R__ROWS"]) ?? tempReplyMap.length,
      replyPageRows: _asInt(map["__R__ROWS_PAGE"]) ?? 20,
      rows: _asInt(map["__ROWS"]) ?? tempReplyMap.length,
      topic: Topic.fromJson(asJsonMap(map["__T"], 'TopicDetailData.__T')),
      hotReplies: hotReplies,
    );
  }

  int get maxPage => (rows / replyPageRows.toDouble()).ceil();
}

class Reply {
  String content;
  String? alterInfo;
  int? tid;
  int score;
  int? score2;
  String? postDate;
  int? authorId;
  String? subject;
  int? type;
  int? fid;
  int? pid;
  int? recommend;
  int? lou;
  int? contentLength;
  int? postDateTimestamp;
  List<Reply> commentList;
  List<Attachment> attachmentList;

  Reply({
    required this.content,
    this.alterInfo,
    this.tid,
    this.score = 0,
    this.score2,
    this.postDate,
    this.authorId,
    this.subject,
    this.type,
    this.fid,
    this.pid,
    this.recommend,
    this.lou,
    this.contentLength,
    this.postDateTimestamp,
    required this.commentList,
    required this.attachmentList,
  });

  factory Reply.fromJson(Map<String, dynamic> map) {
    dynamic commentData = map["comment"];
    List<Reply> commentList = [];
    if (commentData is Map) {
      final comments = asJsonMap(commentData, 'Reply.comment');
      comments.forEach(
        (k, v) =>
            commentList.add(Reply.fromJson(asJsonMap(v, 'Reply.comment.$k'))),
      );
    }
    dynamic attachmentData = map["attachs"];
    List<Attachment> attachmentList = [];
    if (attachmentData is Map) {
      final attachments = asJsonMap(attachmentData, 'Reply.attachs');
      attachments.forEach(
        (k, v) => attachmentList.add(
          Attachment.fromJson(asJsonMap(v, 'Reply.attachs.$k')),
        ),
      );
    }
    return Reply(
      content: map["content"] == null ? "" : map["content"].toString(),
      // 服务端弱类型兼容：可能返回 int / String / null
      alterInfo: map["alterinfo"]?.toString(),
      tid: _asInt(map["tid"]),
      score: _asInt(map["score"]) ?? 0,
      score2: _asInt(map["score_2"]),
      postDate: map["postdate"]?.toString(),
      authorId: _asInt(map["authorid"]),
      subject: map["subject"] == null ? "" : map["subject"].toString(),
      type: _asInt(map["type"]),
      fid: _asInt(map["fid"]),
      pid: _asInt(map["pid"]),
      recommend: _asInt(map["recommend"]),
      lou: _asInt(map["lou"]),
      // 实际上无用属性，还可能是字符串，干脆不要了
      //      contentLength: int.tryParse(map["content_length"]) ?? 0,
      postDateTimestamp: _asInt(map["postdatetimestamp"]),
      commentList: commentList,
      attachmentList: attachmentList,
    );
  }

  String get quoteContent {
    var c = content;
    if (c.length > 250) {
      c = c.substring(0, 250);
    }
    return c;
  }

  void merge(Reply comment) {
    content = comment.content;
    alterInfo = comment.alterInfo;
    tid = comment.tid;
    score = comment.score;
    score2 = comment.score2;
    type = comment.type;
    fid = comment.fid;
    recommend = comment.recommend;
    contentLength = comment.contentLength;
    postDateTimestamp = comment.postDateTimestamp;
    commentList = comment.commentList;
  }
}

class Group {
  final int? id;
  final String? name;

  const Group(this.id, this.name);

  factory Group.fromJson(Map<String, dynamic> map) {
    return Group(_asInt(map["2"]), map["0"]?.toString());
  }
}

class Medal {
  final int? id;
  final String? name;
  final String? description;
  final String? image;

  const Medal(this.id, this.name, this.description, this.image);

  factory Medal.fromJson(Map<String, dynamic> map) {
    return Medal(
      _asInt(map["3"]),
      map["1"]?.toString(),
      map["2"]?.toString(),
      map["0"]?.toString(),
    );
  }
}

class Reputation {
  const Reputation();

  factory Reputation.fromJson(Map<String, dynamic> map) {
    return Reputation();
  }
}

class Attachment {
  const Attachment({
    this.attachUrl,
    this.size,
    this.type,
    this.urlUtf8OrgName,
    this.dscp,
    this.path,
    this.name,
    this.ext,
    this.thumb,
  });

  factory Attachment.fromJson(Map<String, dynamic> map) {
    return Attachment(
      attachUrl: map['attachurl']?.toString(),
      size: _asInt(map['size']),
      type: map['type']?.toString(),
      urlUtf8OrgName: map['url_utf8_org_name']?.toString(),
      dscp: map['dscp']?.toString(),
      path: map['path']?.toString(),
      name: map['name']?.toString(),
      ext: map['ext']?.toString(),
      thumb: map['thumb'],
    );
  }

  final String? attachUrl;
  final int? size;
  final String? type;
  final String? urlUtf8OrgName;
  final String? dscp;
  final String? path;
  final String? name;
  final String? ext;
  final dynamic thumb;

  String get realUrl => "$ngaAttachmentBase/$attachUrl";
}

int? _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}
