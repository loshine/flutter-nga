import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_nga/utils/constant.dart';
import 'package:flutter_nga/utils/palette.dart';

class TopicHistory {
  TopicHistory({
    this.tid,
    this.fid,
    this.subject,
    this.author,
    this.type,
    this.topicMisc,
    this.topicParentName,
    this.time,
  })  : assert(tid != null),
        assert(fid != null),
        assert(subject != null);

  int id;
  final int tid;
  final int fid;
  final String subject;
  final String author;
  final int type;
  final String topicMisc;
  final String topicParentName;
  final int time;

  Map<String, dynamic> toJson() {
    return {
      'tid': tid,
      'fid': fid,
      'subject': subject,
      'author': author,
      'type': type,
      'topicMisc': topicMisc,
      'topicParentName': topicParentName,
      'time': time
    };
  }

  factory TopicHistory.fromJson(Map map) {
    return TopicHistory(
      tid: map['tid'],
      fid: map['fid'],
      subject: map['subject'],
      author: map['author'],
      type: map['type'],
      topicMisc: map['topicMisc'],
      topicParentName: map['topicParentName'],
      time: map['time'],
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
  TopicHistory createNewHistory() {
    return TopicHistory(
      tid: tid,
      fid: fid,
      subject: subject,
      author: author,
      type: type,
      topicMisc: topicMisc,
      topicParentName: topicParentName,
      time: DateTime.now().millisecondsSinceEpoch,
    );
  }
}
