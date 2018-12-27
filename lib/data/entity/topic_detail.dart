import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_nga/utils/constant.dart';
import 'package:flutter_nga/utils/palette.dart';

class TopicDetailData {
  final Map<String, Reply> replyList;
  final Map<String, User> userList;

  final dynamic global;
  final int rows;
  final int currentRows;
  final int rRows;

  const TopicDetailData({
    this.global,
    this.userList,
    this.replyList,
    this.rows,
    this.currentRows,
    this.rRows,
  });

  factory TopicDetailData.fromJson(Map<String, dynamic> map) {
    Map<String, dynamic> userMap = map["__U"];
    Map<String, dynamic> replyMap = map["__R"];
    Map<String, User> tempMap = {};
    for (MapEntry<String, dynamic> entry in userMap.entries) {
      if (entry.key.runtimeType == String)
        continue;
      tempMap[entry.key] = User.fromJson(entry.value);
    }
    Map<String, Reply> tempMap2 = {};
    for (MapEntry<String, dynamic> entry in replyMap.entries) {
      tempMap2[entry.key] = Reply.fromJson(entry.value);
    }
    return TopicDetailData(
      global: map["__GLOBAL"],
      userList: tempMap,
      replyList: tempMap2,
      currentRows: map["__R__ROWS"],
      rRows: map["__R__ROWS_PAGE"],
      rows: map["__ROWS"],
    );
  }
}

class User {
  final int uid;
  final String userName;
  final int credit;
  final String medal;
  final String reputation;
  final int groupId;
  final int memberId;
  final String avatar;
  final int yz;
  final String site;
  final String honor;
  final int regDate;
  final String muteTime;
  final int postNum;
  final int rvrc;
  final int money;
  final int thisVisit;
  final String signature;
  final String nickname;
  final int bitData;

  const User(
      {this.uid,
      this.userName,
      this.credit,
      this.medal,
      this.reputation,
      this.groupId,
      this.memberId,
      this.avatar,
      this.yz,
      this.site,
      this.honor,
      this.regDate,
      this.muteTime,
      this.postNum,
      this.rvrc,
      this.money,
      this.thisVisit,
      this.signature,
      this.nickname,
      this.bitData});

  factory User.fromJson(Map<String, dynamic> map) {
    return User(
      uid: map["uid"],
      userName: map["username"],
      credit: map["credit"],
      medal: map["medal"],
      reputation: map["reputation"],
      groupId: map["groupid"],
      memberId: map["memberid"],
      avatar: map["avatar"],
      yz: map["yz"],
      site: map["site"],
      honor: map["honor"],
      regDate: map["regdate"],
      muteTime: map["mute_time"],
      postNum: map["postnum"],
      rvrc: map["rvrc"],
      money: map["money"],
      thisVisit: map["thisvisit"],
      signature: map["signature"],
      nickname: map["nickname"],
      bitData: map["bit_data"],
    );
  }
}

class Reply {
  final String content;
  final String alterInfo;
  final int tid;
  final int score;
  final int score2;
  final String postDate;
  final int authorId;
  final String subject;
  final int type;
  final int fid;
  final int pid;
  final int recommend;
  final int lou;
  final int contentLength;
  final int postDateTimestamp;

  const Reply(
      {this.content,
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
      this.postDateTimestamp});

  factory Reply.fromJson(Map<String, dynamic> map) {
    return Reply(
      content: map["content"],
      alterInfo: map["alterinfo"],
      tid: map["tid"],
      score: map["score"],
      score2: map["score_2"],
      postDate: map["postdate"],
      authorId: map["authorid"],
      subject: map["subject"],
      type: map["type"],
      fid: map["fid"],
      pid: map["pid"],
      recommend: map["recommend"],
      lou: map["lou"],
      contentLength: map["content_length"],
      postDateTimestamp: map["postdatetimestamp"],
    );
  }
}
