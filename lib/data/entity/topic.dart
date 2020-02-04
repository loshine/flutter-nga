import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_nga/data/entity/topic_history.dart';
import 'package:flutter_nga/utils/constant.dart';
import 'package:flutter_nga/utils/palette.dart';

class TopicListData {
  const TopicListData({
    this.global,
    this.forum,
    this.rows,
    this.topicList,
    this.currentRows,
    this.topicRows,
    this.rRows,
  });

  final dynamic global;
  final dynamic forum;
  final int rows;
  final Map<String, Topic> topicList;
  final int currentRows;
  final int topicRows;
  final int rRows;

  factory TopicListData.fromJson(Map<String, dynamic> map) {
    Map<String, dynamic> topicMap = map["__T"];
    Map<String, Topic> tempMap = {};
    for (MapEntry<String, dynamic> entry in topicMap.entries) {
      tempMap[entry.key] = Topic.fromJson(entry.value);
    }
    return TopicListData(
      global: map["__GLOBAL"],
      forum: map["__F"],
      rows: map["__ROWS"],
      topicList: tempMap,
      currentRows: map["__T__ROWS"],
      topicRows: map["__T__ROWS__PAGE"],
      rRows: map["__R__ROWS_PAGE"],
    );
  }

  int get maxPage => rows ~/ rRows + (rows % rRows != 0 ? 1 : 0);
}

class Topic {
  const Topic({
    this.tid,
    this.fid,
    this.tpcurl,
    this.quoteFrom,
    this.quoteTo,
    this.author,
    this.subject,
    this.icon,
    this.postDate,
    this.lastPoster,
    this.lastPost,
    this.lastModify,
    this.recommend,
    this.authorId,
    this.type,
    this.replies,
    this.topicMisc,
    this.parent,
  });

  final int tid;
  final int fid;
  final String tpcurl;
  final dynamic quoteFrom;
  final String quoteTo;
  final String author;
  final dynamic authorId; // 匿名时为 String，非匿名时为 Int
  final String subject;
  final int icon;
  final int postDate;
  final dynamic lastPoster; // 也可能匿名
  final int lastPost;
  final int lastModify;
  final int recommend;
  final int type;
  final int replies;
  final String topicMisc;

  final TopicParent parent;

  factory Topic.fromJson(Map<String, dynamic> map) {
    return Topic(
      tid: map["tid"],
      fid: map["fid"],
      tpcurl: map["tpcurl"],
      quoteFrom: map["quote_from"],
      quoteTo: map["quote_to"].toString(),
      // 有一些不正常数据是 int 类型
      author: map["author"].toString(),
      // 写 PHP 的都没有一点数据类型的意识么？
      authorId: map["authorid"],
      subject: map["subject"].toString(),
      icon: map["icon"],
      postDate: map["postdate"],
      lastPoster: map["lastposter"],
      lastPost: map["lastpost"],
      lastModify: map["lastmodify"],
      recommend: map["recommend"],
      type: map["type"],
      replies: map["replies"],
      topicMisc: map["topic_misc"],
      parent: TopicParent.fromJson(map["parent"] == null ? {} : map["parent"]),
    );
  }

  bool hasAttachment() {
    return type & TOPIC_MASK_TYPE_ATTACHMENT == TOPIC_MASK_TYPE_ATTACHMENT;
  }

  bool isAssemble() {
    return type & TOPIC_MASK_TYPE_ASSEMBLE == TOPIC_MASK_TYPE_ASSEMBLE;
  }

  bool locked() {
    return type & TOPIC_MASK_TYPE_LOCK == TOPIC_MASK_TYPE_LOCK;
  }

  bool isBold() {
    return _getLastMiscByte() & TOPIC_MASK_FONT_STYLE_BOLD ==
        TOPIC_MASK_FONT_STYLE_BOLD;
  }

  bool isItalic() {
    return _getLastMiscByte() & TOPIC_MASK_FONT_STYLE_ITALIC ==
        TOPIC_MASK_FONT_STYLE_ITALIC;
  }

  bool isUnderline() {
    return _getLastMiscByte() & TOPIC_MASK_FONT_STYLE_UNDERLINE ==
        TOPIC_MASK_FONT_STYLE_UNDERLINE;
  }

  Color getSubjectColor() {
    var byte = _getLastMiscByte();
    if (byte & TOPIC_MASK_FONT_COLOR_RED == TOPIC_MASK_FONT_COLOR_RED) {
      return Colors.red;
    } else if (byte & TOPIC_MASK_FONT_COLOR_BLUE ==
        TOPIC_MASK_FONT_COLOR_BLUE) {
      return Colors.blue;
    } else if (byte & TOPIC_MASK_FONT_COLOR_GREEN ==
        TOPIC_MASK_FONT_COLOR_GREEN) {
      return Colors.green;
    } else if (byte & TOPIC_MASK_FONT_COLOR_ORANGE ==
        TOPIC_MASK_FONT_COLOR_ORANGE) {
      return Colors.orange;
    } else if (byte & TOPIC_MASK_FONT_COLOR_SILVER ==
        TOPIC_MASK_FONT_COLOR_SILVER) {
      return Color(0xFFC0C0C0);
    } else {
      return Palette.colorTextPrimary;
    }
  }

  int _getLastMiscByte() {
    if (topicMisc != null && topicMisc.isNotEmpty) {
      var misc = topicMisc;
      while (misc.length * 6 % 8 != 0) {
        misc += "A";
      }
      var bytes = base64.decode(misc);
      if (bytes != null && bytes.isNotEmpty && bytes[0].toInt() == 1) {
        return bytes[4].toInt();
      }
    }
    return 0;
  }

  /// 点击时生成浏览历史
  TopicHistory createHistory() {
    return TopicHistory(
      tid: tid,
      fid: fid,
      subject: subject,
      author: author,
      type: type,
      topicMisc: topicMisc,
      topicParentName: parent == null ? null : parent.name,
      time: DateTime.now().millisecondsSinceEpoch,
    );
  }
}

class TopicParent {
  const TopicParent(this.name);

  final String name;

  factory TopicParent.fromJson(Map<String, dynamic> map) {
    return TopicParent(map["2"]);
  }
}
