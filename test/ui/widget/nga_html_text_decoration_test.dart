import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:flutter_nga/ui/widget/nga_html_content_widget.dart';

/// 收集所有带文字的 TextSpan 及其最终生效的 decoration（沿 span 树继承）
List<(String, TextDecoration?)> _textDecorations(WidgetTester tester) {
  final result = <(String, TextDecoration?)>[];
  void visit(InlineSpan span, TextDecoration? inherited) {
    final decoration = span.style?.decoration ?? inherited;
    if (span is TextSpan) {
      final text = span.text?.trim() ?? '';
      if (text.isNotEmpty) result.add((text, decoration));
      for (final child in span.children ?? const <InlineSpan>[]) {
        visit(child, decoration);
      }
    }
  }

  for (final richText in tester.widgetList<RichText>(find.byType(RichText))) {
    visit(richText.text, null);
  }
  return result;
}

void main() {
  testWidgets('content decoration reaches nested inline and block text',
      (tester) async {
    await tester.pumpWidget(ProviderScope(
      child: MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: NgaHtmlContentWidget(
              content: '普通正文 [b]加粗文字[/b]<br/>[quote]引用内容[/quote]',
              textDecoration: TextDecoration.lineThrough,
            ),
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    final spans = _textDecorations(tester);
    for (final text in ['普通正文', '加粗文字', '引用内容']) {
      final matched = spans.where((span) => span.$1.contains(text));
      expect(matched, isNotEmpty, reason: '$text not rendered: $spans');
      expect(matched.every((span) => span.$2 == TextDecoration.lineThrough),
          isTrue,
          reason: '$text missing line-through: $spans');
    }
  });

  testWidgets('content has no decoration by default', (tester) async {
    await tester.pumpWidget(ProviderScope(
      child: MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: NgaHtmlContentWidget(content: '普通正文 [b]加粗文字[/b]'),
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    final spans = _textDecorations(tester);
    expect(spans, isNotEmpty);
    expect(
      spans.any((span) => span.$2 == TextDecoration.lineThrough),
      isFalse,
    );
  });
}
