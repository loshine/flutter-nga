import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_nga/data/entity/notification.dart';
import 'package:flutter_nga/providers/notification/notification_list_provider.dart';

NgaNotification _n(int type, {int id = 100, int id2 = 0, int id3 = 0}) =>
    NgaNotification(
      type: type,
      fromUid: 1,
      fromUsername: 'alice',
      text: '测试主题',
      aboutId: id,
      aboutId2: id2,
      aboutId3: id3,
    );

void main() {
  group('NgaNotification.fromJson', () {
    test('兼容字符串数字并解析举报理由与分类', () {
      final n = NgaNotification.fromJson({
        '0': '14',
        '1': '12',
        '2': 'bob',
        '5': '某主题',
        '6': '300',
        '7': 400,
        '9': '1700000000',
        '10': 2,
        '11': '人身攻击',
        '13': '违规',
      });

      expect(n.type, NgaNotification.TYPE_REPORT_REPLY);
      expect(n.fromUid, 12);
      expect(n.aboutId, 300);
      expect(n.aboutId2, 400);
      expect(n.time, 1700000000);
      expect(n.aboutId4, 2);
      expect(n.category, NotificationCategory.moderation);
      expect(n.describe().detail, '[违规] 某主题\n理由：人身攻击');
      expect(n.target, const ReplyTarget(300, 400));
    });

    test('缺失字段时不抛异常', () {
      final n = NgaNotification.fromJson({'0': 9});
      expect(n.type, NgaNotification.TYPE_IP_CHANGE);
      expect(n.hasActor, isFalse);
      expect(n.target, isNull);
      expect(n.describe().actor, isNull);
    });
  });

  group('NotificationInfoListData.fromJson', () {
    test('合并三个分桶并按时间倒序', () {
      final data = NotificationInfoListData.fromJson({
        '0': [
          {'0': 1, '9': 10},
          {'0': 2, '9': 30},
        ],
        '1': [
          {'0': 13, '9': 20},
        ],
        '2': [
          {'0': 9, '9': 5},
        ],
        'unread': 3,
      });

      expect(data.notifications.map((e) => e.time), [30, 20, 10, 5]);
      expect(data.unread, 3);
    });

    test('分组按类型而不是服务端分桶', () {
      final data = NotificationInfoListData.fromJson({
        '1': [
          {'0': 10, '9': 3},
          {'0': 13, '9': 2},
        ],
        '0': [
          {'0': 17, '9': 1},
        ],
      });
      final state = NotificationListState(notifications: data.notifications);

      expect(state.sections.map((e) => e.key), [
        NotificationCategory.reply,
        NotificationCategory.message,
        NotificationCategory.moderation,
      ]);
    });
  });

  group('describe', () {
    test('类型 15 按 aboutId2 区分回复与主题发言', () {
      expect(_n(15, id2: 5).describe().action, '评价了你在主题中的回复并使用了道具');
      expect(_n(15).describe().action, '评价了你在主题中的发言并使用了道具');
    });

    test('类型 17 支持/反对没有来源用户', () {
      final reply = _n(17, id2: 5).describe();
      expect(reply.actor, isNull);
      expect(reply.action, '你在主题中的回复获得了支持或反对');
      expect(_n(17).describe().action, '你的主题获得了支持或反对');
    });

    test('未知类型给出兜底文案', () {
      expect(_n(99).describe().action, '未知提醒（类型 99）');
      expect(_n(99).category, NotificationCategory.system);
    });

    test('1~17 都有对应文案', () {
      for (var type = 1; type <= 17; type++) {
        expect(
          _n(type).describe().action,
          isNot(startsWith('未知提醒')),
          reason: 'type $type',
        );
      }
    });
  });

  group('target', () {
    test('回复类跳到触发提醒的回复，没有 pid 时回到主题', () {
      expect(_n(1, id2: 7).target, const ReplyTarget(100, 7));
      expect(_n(8, id2: 7).target, const ReplyTarget(100, 7));
      expect(_n(1).target, const TopicTarget(100));
    });

    test('评论回复跳到被评论的回复', () {
      expect(_n(4, id2: 7, id3: 8).target, const ReplyTarget(100, 8));
    });

    test('主题类、短消息与版面关键词', () {
      expect(_n(3).target, const TopicTarget(100));
      expect(_n(7).target, const TopicTarget(100));
      expect(_n(11, id: 55).target, const ConversationTarget(55));
      expect(_n(16, id: -7).target, const ForumTarget(-7));
      expect(_n(9).target, isNull);
    });

    test('短消息与版面关键词不提供进入主题', () {
      expect(_n(10).topicId, isNull);
      expect(_n(16).topicId, isNull);
      expect(_n(2, id2: 7).topicId, 100);
    });
  });

  group('noHintTarget', () {
    test('与网页版 _TNO / _RNO 对应', () {
      expect(_n(1).noHintTarget, const NoHintTarget(100, 0));
      expect(_n(3).noHintTarget, const NoHintTarget(100, 0));
      expect(_n(2, id3: 8).noHintTarget, const NoHintTarget(100, 8));
      expect(_n(4, id3: 8).noHintTarget, const NoHintTarget(100, 8));
      expect(_n(15, id3: 8).noHintTarget, const NoHintTarget(100, 8));
      expect(_n(17, id2: 7).noHintTarget, const NoHintTarget(100, 7));
      expect(_n(17).noHintTarget, const NoHintTarget(100, 0));
    });

    test('提及、短消息、系统提醒不支持', () {
      expect(_n(7).noHintTarget, isNull);
      expect(_n(8, id2: 7).noHintTarget, isNull);
      expect(_n(10).noHintTarget, isNull);
      expect(_n(9).noHintTarget, isNull);
    });
  });
}
