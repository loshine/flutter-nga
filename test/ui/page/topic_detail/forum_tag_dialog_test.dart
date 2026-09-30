import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_nga/data/entity/topic_tag.dart';
import 'package:flutter_nga/ui/page/topic_detail/forum_tag_dialog.dart';

void main() {
  testWidgets('preset tags remain selectable in a height-limited dialog', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(400, 400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    String? selected;
    final tags = List.generate(
      20,
      (index) => TopicTag(id: index, content: '分类 $index'),
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return TextButton(
                  onPressed: () => showDialog<void>(
                    context: context,
                    builder: (_) => ForumTagDialog(
                      fid: 1,
                      tagList: tags,
                      onSelected: (tag) => selected = tag,
                    ),
                  ),
                  child: const Text('打开分类'),
                );
              },
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('打开分类'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('分类 0'));
    expect(selected, '分类 0');
    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -1500),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('分类 19'));
    expect(selected, '分类 19');
    expect(tester.takeException(), isNull);
  });
}
