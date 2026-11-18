import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:flutter_nga/data/entity/topic.dart';
import 'package:flutter_nga/data/entity/topic_history.dart';
import 'package:flutter_nga/ui/widget/topic_history_list_item_widget.dart';
import 'package:flutter_nga/ui/widget/topic_list_item_widget.dart';

const _scale = 2.0;

/// 测试字体中每个字形宽高都等于字号，便于按尺寸判断实际缩放倍数。
Future<void> _pumpScaled(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(_scale)),
          child: Scaffold(body: SingleChildScrollView(child: child)),
        ),
      ),
    ),
  );
  await tester.pump();
}

RichText _richTextOf(WidgetTester tester, String text) =>
    tester.widget(find.textContaining(text, findRichText: true).first);

/// [text] 所在 RichText 在屏幕上的实际区域（包含 WidgetSpan 的缩放变换）。
Rect _paintedRect(WidgetTester tester, String text) =>
    tester.getRect(find.text(text, findRichText: true).first);

void main() {
  group('标题跟随系统文字缩放', () {
    testWidgets('帖子列表', (tester) async {
      await _pumpScaled(
        tester,
        const TopicListItemWidget(
          topic: Topic(
            tid: 1,
            fid: 10,
            author: '作者',
            subject: '帖子标题',
            lastPost: 0,
            replies: 0,
            type: 0,
            parent: TopicParent('版块'),
          ),
        ),
      );

      expect(
        _richTextOf(tester, '帖子标题').textScaler,
        const TextScaler.linear(_scale),
      );
      // 版块标签：字号 10，随标题整体缩放一次，不能再叠加自身的缩放。
      expect(_paintedRect(tester, '版块').width, closeTo(2 * 10 * _scale, 4));
    });

    testWidgets('浏览历史', (tester) async {
      await _pumpScaled(
        tester,
        TopicHistoryListItemWidget(
          topicHistory: TopicHistory(
            tid: 1,
            fid: 10,
            author: '作者',
            subject: '历史标题',
            type: 0,
            topicParentName: '版块',
          ),
        ),
      );

      expect(
        _richTextOf(tester, '历史标题').textScaler,
        const TextScaler.linear(_scale),
      );
      expect(_paintedRect(tester, '版块').width, closeTo(2 * 10 * _scale, 4));
    });
  });
}
