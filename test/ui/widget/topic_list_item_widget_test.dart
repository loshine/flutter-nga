import 'package:flutter/material.dart';
import 'package:flutter_nga/data/entity/topic.dart';
import 'package:flutter_nga/data/entity/topic_history.dart';
import 'package:flutter_nga/ui/widget/topic_history_list_item_widget.dart';
import 'package:flutter_nga/ui/widget/topic_list_item_widget.dart';
import 'package:flutter_nga/utils/name_utils.dart' as name_utils;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const _anonymousAuthor = '#anony_6b0df884c0e44bf854e195a52cbc3a0e';

void main() {
  testWidgets('topic list displays the generated anonymous name',
      (tester) async {
    final displayName = name_utils.getShowName(_anonymousAuthor);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: TopicListItemWidget(
              topic: const Topic(
                tid: 1,
                fid: 10,
                author: _anonymousAuthor,
                subject: '匿名帖子',
                lastPost: 0,
                replies: 0,
                type: 0,
              ),
            ),
          ),
        ),
      ),
    );

    expect(displayName, isNot(_anonymousAuthor));
    expect(find.text(displayName), findsOneWidget);
    expect(find.text(_anonymousAuthor), findsNothing);
  });

  testWidgets('topic history displays the generated anonymous name',
      (tester) async {
    final displayName = name_utils.getShowName(_anonymousAuthor);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: TopicHistoryListItemWidget(
              topicHistory: TopicHistory(
                tid: 1,
                fid: 10,
                author: _anonymousAuthor,
                subject: '匿名帖子',
                type: 0,
              ),
            ),
          ),
        ),
      ),
    );

    expect(displayName, isNot(_anonymousAuthor));
    expect(find.text(displayName), findsOneWidget);
    expect(find.text(_anonymousAuthor), findsNothing);
  });
}
