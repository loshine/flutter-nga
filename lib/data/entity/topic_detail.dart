import 'dart:core';

import 'package:flutter_nga/data/entity/topic.dart';
import 'package:flutter_nga/data/entity/user.dart';

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
    this.userList,
    this.replyList,
    this.groupList,
    this.medalList,
    this.reputationList,
    this.rows,
    this.currentRows,
    this.replyPageRows,
    this.topic,
    this.hotReplies,
  });

  factory TopicDetailData.fromJson(Map<String, dynamic> map) {
    Map<String, dynamic> userMap = map["__U"];
    Map<String, dynamic> replyMap = map["__R"];
    Map<String, dynamic> topicInfoMap = map["__T"];
    Map<String, User> tempUserMap = {};
    Map<String, Group> tempGroupMap = {};
    Map<String, Medal> tempMedalMap = {};
    Map<String, Reputation> tempReputationMap = {};
    for (MapEntry<String, dynamic> entry in userMap.entries) {
      int key = int.tryParse(entry.key);
      if (key == null) {
        // __GROUPS 用户等级
        if ("__GROUPS" == entry.key) {
          for (MapEntry<String, dynamic> m in entry.value.entries) {
            tempGroupMap[m.key] = Group.fromJson(m.value);
          }
        } else if ("__MEDALS" == entry.key) {
          // __MEDALS 奖牌
          for (MapEntry<String, dynamic> m in entry.value.entries) {
            tempMedalMap[m.key] = Medal.fromJson(m.value);
          }
        } else if ("__REPUTATIONS" == entry.key) {
          // __REPUTATIONS 威望
          for (MapEntry<String, dynamic> m in entry.value.entries) {
            tempReputationMap[m.key] = Reputation.fromJson(m.value);
          }
        }
      } else {
        tempUserMap[entry.key] = User.fromJson(entry.value);
        if (key != tempUserMap[entry.key].uid) {
          tempUserMap[entry.key].uid = key;
        }
      }
    }
    Map<String, Reply> tempReplyMap = {};
    for (MapEntry<String, dynamic> entry in replyMap.entries) {
      tempReplyMap[entry.key] = Reply.fromJson(entry.value);
    }
    Map<String, dynamic> topicMisc = topicInfoMap["post_misc_var"];
    List<int> hotReplies = [];
    if (topicMisc.containsKey("17")) {
      String hots = topicMisc["17"];
      hotReplies.addAll(hots
          .split(",")
          .where((e) => e.isNotEmpty)
          .map((e) => int.tryParse(e))
          .where((e) => e != null));
    }
    return TopicDetailData(
      global: map["__GLOBAL"],
      userList: tempUserMap,
      replyList: tempReplyMap,
      groupList: tempGroupMap,
      medalList: tempMedalMap,
      reputationList: tempReputationMap,
      currentRows: map["__R__ROWS"],
      replyPageRows: map["__R__ROWS_PAGE"],
      rows: map["__ROWS"],
      topic: Topic.fromJson(map["__T"]),
      hotReplies: hotReplies,
    );
  }

  int get maxPage => (rows / replyPageRows.toDouble()).ceil();
}

class Reply {
  String content;
  String alterInfo;
  int tid;
  int score;
  int score2;
  String postDate;
  int authorId;
  String subject;
  int type;
  int fid;
  int pid;
  int recommend;
  int lou;
  int contentLength;
  int postDateTimestamp;
  List<Reply> commentList;
  List<Attachment> attachmentList;

  Reply({
    this.content,
    this.alterInfo,
    this.tid,
    this.score,
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
    this.commentList,
    this.attachmentList,
  });

  factory Reply.fromJson(Map<String, dynamic> map) {
    Map<String, dynamic> commentMap = map["comment"];
    List<Reply> commentList = [];
    if (commentMap != null) {
      commentMap.forEach((k, v) => commentList.add(Reply.fromJson(v)));
    }
    Map<String, dynamic> attachmentMap = map["attachs"];
    List<Attachment> attachmentList = [];
    if (attachmentMap != null) {
      attachmentMap
          .forEach((k, v) => attachmentList.add(Attachment.fromJson(v)));
    }
    return Reply(
      content: map["content"] == null ? "" : map["content"].toString(),
      // 这都可能会是 int 我也是服气
      alterInfo: map["alterinfo"],
      tid: map["tid"],
      score: map["score"],
      score2: map["score_2"],
      postDate: map["postdate"],
      authorId: map["authorid"],
      subject: map["subject"] == null ? "" : map["subject"].toString(),
      type: map["type"],
      fid: map["fid"],
      pid: map["pid"],
      recommend: map["recommend"],
      lou: map["lou"],
// 实际上无用属性，还可能是字符串，干脆不要了
//      contentLength: int.tryParse(map["content_length"]) ?? 0,
      postDateTimestamp: map["postdatetimestamp"],
      commentList: commentList,
      attachmentList: attachmentList,
    );
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
  final int id;
  final String name;

  const Group(this.id, this.name);

  factory Group.fromJson(Map<String, dynamic> map) {
    return Group(map["2"], map["0"]);
  }
}

class Medal {
  final int id;
  final String name;
  final String description;
  final String image;

  const Medal(this.id, this.name, this.description, this.image);

  factory Medal.fromJson(Map<String, dynamic> map) {
    return Medal(map["3"], map["1"], map["2"], map["0"]);
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
      attachUrl: map['attachurl'],
      size: map['size'],
      type: map['type'],
      urlUtf8OrgName: map['url_utf8_org_name'],
      dscp: map['dscp'],
      path: map['path'],
      name: map['name'],
      ext: map['ext'],
      thumb: map['thumb'],
    );
  }

  final String attachUrl;
  final int size;
  final String type;
  final String urlUtf8OrgName;
  final String dscp;
  final String path;
  final String name;
  final String ext;
  final dynamic thumb;

  String get realUrl => "https://img.nga.178.com/attachments/$attachUrl";
}
