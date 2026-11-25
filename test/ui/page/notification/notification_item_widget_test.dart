import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:flutter_nga/data/entity/notification.dart';
import 'package:flutter_nga/ui/page/notification/notification_item_widget.dart';

void main() {
  Future<void> pump(
    WidgetTester tester,
    NgaNotification notification, {
    ValueChanged<NoHintTarget>? onNoHint,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NotificationItemWidget(
            notification: notification,
            onNoHint: onNoHint,
          ),
        ),
      ),
    );
  }

  testWidgets('显示来源用户、动作与主题标题', (tester) async {
    await pump(
      tester,
      const NgaNotification(
        type: NgaNotification.TYPE_REPLY_TOPIC,
        fromUid: 1,
        fromUsername: 'alice',
        text: '测试主题',
        aboutId: 100,
        aboutId2: 7,
      ),
    );

    expect(find.textContaining('alice'), findsOneWidget);
    expect(find.textContaining('回复了你的主题'), findsOneWidget);
    expect(find.text('测试主题'), findsOneWidget);
  });

  testWidgets('长按可以不再提示此主题', (tester) async {
    NoHintTarget? received;
    await pump(
      tester,
      const NgaNotification(
        type: NgaNotification.TYPE_REPLY_TOPIC,
        fromUid: 1,
        fromUsername: 'alice',
        text: '测试主题',
        aboutId: 100,
      ),
      onNoHint: (target) => received = target,
    );

    await tester.longPress(find.byType(NotificationItemWidget));
    await tester.pumpAndSettle();
    expect(find.text('查看 alice 的主页'), findsOneWidget);

    await tester.tap(find.text('不再提示此主题的回复或评论'));
    await tester.pumpAndSettle();
    expect(received, (tid: 100, pid: 0));
  });
}
