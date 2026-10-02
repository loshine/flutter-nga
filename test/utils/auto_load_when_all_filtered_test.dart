import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:flutter_nga/utils/hooks/easy_refresh_hooks.dart';

class _Harness extends HookWidget {
  const _Harness({
    required this.rawItems,
    required this.visibleCount,
    required this.canLoadMore,
    required this.onLoad,
  });

  final List<Object?> rawItems;
  final int visibleCount;
  final bool canLoadMore;
  final Future<void> Function(EasyRefreshController) onLoad;

  @override
  Widget build(BuildContext context) {
    final controller = useEasyRefreshController(controlFinishLoad: true);
    useAutoLoadWhenAllFiltered(
      controller,
      rawItems: rawItems,
      visibleCount: visibleCount,
      canLoadMore: canLoadMore,
      maxAttempts: 2,
    );
    return EasyRefresh(
      controller: controller,
      footer: const ClassicFooter(),
      onLoad: canLoadMore ? () => onLoad(controller) : null,
      child: ListView.builder(
        itemCount: visibleCount,
        itemBuilder: (_, index) => Text('item $index'),
      ),
    );
  }
}

void main() {
  late int loads;

  Future<void> onLoad(EasyRefreshController controller) async {
    loads++;
    controller.finishLoad();
  }

  Future<void> pump(
    WidgetTester tester, {
    required List<Object?> rawItems,
    int visibleCount = 0,
    bool canLoadMore = true,
  }) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: _Harness(
          rawItems: rawItems,
          visibleCount: visibleCount,
          canLoadMore: canLoadMore,
          onLoad: onLoad,
        ),
      ),
    ));
    await tester.pumpAndSettle();
  }

  setUp(() => loads = 0);

  testWidgets('loads the next page when every item is filtered',
      (tester) async {
    await pump(tester, rawItems: [1, 2]);
    expect(loads, 1);
  });

  testWidgets('does not load when something is visible or no more pages',
      (tester) async {
    await pump(tester, rawItems: [1, 2], visibleCount: 1);
    await pump(tester, rawItems: [3, 4], canLoadMore: false);
    await pump(tester, rawItems: const []);
    expect(loads, 0);
  });

  testWidgets('stops after max consecutive attempts and resets on content',
      (tester) async {
    await pump(tester, rawItems: [1]);
    await pump(tester, rawItems: [1, 2]);
    await pump(tester, rawItems: [1, 2, 3]);
    expect(loads, 2);

    await pump(tester, rawItems: [1, 2, 3, 4], visibleCount: 1);
    await pump(tester, rawItems: [5]);
    expect(loads, 3);
  });
}
