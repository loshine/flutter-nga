import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:material_ui/material_ui.dart';

import 'package:flutter_nga/ui/widget/collapse_widget.dart';
import 'package:flutter_nga/ui/widget/nga_html_extensions.dart';
import 'package:flutter_nga/ui/widget/username_text.dart';
import 'package:flutter_nga/utils/parser/content_parser.dart';
import 'package:flutter_nga/utils/theme_builder.dart';

final _theme = ThemeBuilder.buildLightTheme(Colors.brown);

Future<void> _pumpHtml(WidgetTester tester, String html) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: _theme,
      home: Scaffold(body: SingleChildScrollView(child: NgaHtml(html))),
    ),
  );
  await tester.pump();
}

/// 找到包含 [text] 的 TextSpan，并返回沿 span 树继承后的最终样式。
TextStyle? _styleOf(WidgetTester tester, String text) {
  TextStyle? found;
  void visit(InlineSpan span, TextStyle? inherited) {
    final style = inherited?.merge(span.style) ?? span.style;
    if (span is TextSpan) {
      if (found == null && (span.text ?? '').contains(text)) found = style;
      for (final child in span.children ?? const <InlineSpan>[]) {
        visit(child, style);
      }
    }
  }

  for (final richText in tester.widgetList<RichText>(find.byType(RichText))) {
    visit(richText.text, null);
  }
  return found;
}

Finder _richText(String text) => find.textContaining(text, findRichText: true);

final _dictButton = find.byWidgetPredicate(
  (w) => w is Semantics && w.properties.hint == '查看词条注释',
);

void main() {
  group('nga_quote', () {
    testWidgets('renders header and quoted body', (tester) async {
      await _pumpHtml(
        tester,
        "<nga_quote pid='875718629' tid='47217372' uid='66738726' "
        "author='golcore' floor='3' date='2026-07-20 00:43'>"
        '被引用的<b>原文</b></nga_quote>正文',
      );

      expect(find.byIcon(Icons.format_quote), findsOneWidget);
      expect(find.byType(UsernameText), findsOneWidget);
      expect(_richText('2026-07-20 00:43'), findsOneWidget);
      expect(_richText('被引用的'), findsOneWidget);
      expect(_styleOf(tester, '原文')?.fontWeight, FontWeight.bold);
      expect(find.byType(Divider), findsOneWidget);
      expect(_richText('正文'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('omits body section when quote is empty', (tester) async {
      await _pumpHtml(
        tester,
        "<nga_quote pid='1' author='golcore'></nga_quote>",
      );

      expect(find.byIcon(Icons.format_quote), findsOneWidget);
      expect(find.byType(Divider), findsNothing);
    });

    testWidgets('parser output keeps quote card for Reply to', (tester) async {
      await _pumpHtml(
        tester,
        NgaContentParser.parse(
          '[quote][pid=875718629,47217372,1]Reply[/pid] [b]Post by '
          '[uid=66738726]golcore[/uid] (2026-07-20 00:43):[/b]<br/><br/>'
          '原文内容[/quote]回复',
        ),
      );

      expect(find.byIcon(Icons.format_quote), findsOneWidget);
      expect(_richText('原文内容'), findsOneWidget);
    });
  });

  group('album', () {
    testWidgets('wraps images in a titled card', (tester) async {
      await _pumpHtml(
        tester,
        NgaContentParser.parse(
          '[album=旅行相册][url]https://img.nga.178.com/attachments/a.jpg[/url]'
          '[url]https://img.nga.178.com/attachments/b.jpg[/url][/album]',
        ),
      );

      expect(find.text('旅行相册'), findsOneWidget);
      expect(find.byType(Image), findsNWidgets(2));
      expect(tester.takeException(), isNull);
    });

    testWidgets('falls back to default title', (tester) async {
      await _pumpHtml(tester, "<album title=' '>内容</album>");

      expect(find.text('相册'), findsOneWidget);
      expect(_richText('内容'), findsOneWidget);
    });
  });

  group('collapse', () {
    testWidgets('is collapsed by default and expands on tap', (tester) async {
      await _pumpHtml(tester, "<collapse title='剧透'>隐藏内容</collapse>");

      expect(find.byType(CollapseWidget), findsOneWidget);
      expect(find.text('点击展开:剧透'), findsOneWidget);
      final collapsedBox = find.ancestor(
        of: _richText('隐藏内容'),
        matching: find.byType(SizedBox),
      );
      expect(tester.getSize(collapsedBox.first).height, 0);

      await tester.tap(find.text('点击展开:剧透'));
      await tester.pumpAndSettle();

      expect(find.text('点击收起:剧透'), findsOneWidget);
      expect(tester.getSize(_richText('隐藏内容')).height, greaterThan(0));
    });

    testWidgets('untitled collapse keeps empty title', (tester) async {
      await _pumpHtml(tester, '<collapse>内容</collapse>');

      expect(find.text('点击展开:'), findsOneWidget);
    });
  });

  group('nga_dict', () {
    testWidgets('term is styled as primary dotted underline', (tester) async {
      await _pumpHtml(
        tester,
        NgaContentParser.parse('前[size=150%][dict][SCP-087]楼梯[/dict][/size]后'),
      );

      final style = _styleOf(tester, 'SCP-087');
      final primary = _theme.colorScheme.primary;
      expect(style?.color, primary);
      expect(style?.decoration, TextDecoration.underline);
      expect(style?.decorationStyle, TextDecorationStyle.dotted);
      expect(style?.decorationColor, primary);
      // 继承外层 [size] 的字号
      final outer = _styleOf(tester, '前')!.fontSize!;
      expect(style!.fontSize, closeTo(outer * 1.5, 0.01));
      expect(_dictButton, findsOneWidget);
      expect(tester.widget<Semantics>(_dictButton).properties.label, 'SCP-087');
    });

    testWidgets('tapping term shows definition dialog', (tester) async {
      await _pumpHtml(
        tester,
        NgaContentParser.parse('[dict][SCP-087]一座[b]向下[/b]延伸的楼梯[/dict]'),
      );

      await tester.tap(_richText('SCP-087'));
      await tester.pumpAndSettle();

      expect(find.byType(Dialog), findsOneWidget);
      expect(_richText('延伸的楼梯'), findsOneWidget);
      expect(_styleOf(tester, '向下')?.fontWeight, FontWeight.bold);

      await tester.tap(find.text('关闭'));
      await tester.pumpAndSettle();
      expect(find.byType(Dialog), findsNothing);
    });

    testWidgets('missing definition renders plain term', (tester) async {
      await _pumpHtml(tester, "<nga_dict term='词' definition=''>词</nga_dict>");

      expect(_richText('词'), findsOneWidget);
      expect(_dictButton, findsNothing);
    });
  });

  group('nga_emoticon', () {
    testWidgets('renders inline image at its original height', (tester) async {
      await _pumpHtml(
        tester,
        "前<nga_emoticon src='https://img4.nga.cn/ngabbs/post/smile/ac0.png'"
        " height='60' descent='12'></nga_emoticon>后",
      );

      final inline = tester.widget<InlineCustomWidget>(
        find.byType(InlineCustomWidget),
      );
      expect(inline.alignment, PlaceholderAlignment.baseline);
      expect(
        tester.widget<EmoticonBaseline>(find.byType(EmoticonBaseline)).descent,
        12,
      );
      final image = tester.widget<CachedNetworkImage>(
        find.byType(CachedNetworkImage),
      );
      expect(image.width, isNull);
      expect(image.height, 60);
      expect(image.imageUrl, endsWith('ac0.png'));
      expect(_richText('前'), findsOneWidget);
    });

    testWidgets('loading placeholder keeps final height and baseline', (
      tester,
    ) async {
      await _pumpHtml(
        tester,
        "前<nga_emoticon src='https://img4.nga.cn/ngabbs/post/smile/ac0.png'"
        " height='60' descent='12'></nga_emoticon>后",
      );

      // 图片尚未加载：占位是高 60 的正方形（另加左右各 2 的间距），
      // 没有文字基线，按「高度 - descent」对齐，与加载完成后一致。
      final baseline = find.byType(EmoticonBaseline);
      expect(tester.getSize(baseline), const Size(64, 60));
      final box = tester.renderObject<RenderBox>(baseline);
      expect(box.getDryBaseline(box.constraints, TextBaseline.alphabetic), 48);
      expect(find.text('[表情]'), findsNothing);
    });

    testWidgets('missing src falls back to placeholder text', (tester) async {
      await _pumpHtml(tester, '<nga_emoticon></nga_emoticon>');

      expect(find.byType(Image), findsNothing);
      expect(find.text('[表情]'), findsOneWidget);
    });

    Future<void> pumpBaselineRow(WidgetTester tester, List<Widget> children) {
      return tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: children,
            ),
          ),
        ),
      );
    }

    testWidgets('image bottom sinks descent below the baseline', (
      tester,
    ) async {
      await pumpBaselineRow(tester, const [
        EmoticonBaseline(
          descent: 0,
          child: SizedBox(key: Key('flush'), width: 10, height: 60),
        ),
        EmoticonBaseline(
          descent: 12,
          child: SizedBox(key: Key('sunk'), width: 10, height: 60),
        ),
      ]);

      final flush = tester.getBottomLeft(find.byKey(const Key('flush')));
      final sunk = tester.getBottomLeft(find.byKey(const Key('sunk')));
      expect(sunk.dy - flush.dy, 12);
    });

    testWidgets('child with its own baseline keeps it', (tester) async {
      await pumpBaselineRow(tester, const [
        Text('字', key: Key('plain')),
        EmoticonBaseline(descent: 12, child: Text('字', key: Key('wrapped'))),
      ]);

      expect(
        tester.getTopLeft(find.byKey(const Key('wrapped'))).dy,
        tester.getTopLeft(find.byKey(const Key('plain'))).dy,
      );
    });
  });

  testWidgets('====== renders a 1px divider line', (tester) async {
    await _pumpHtml(tester, NgaContentParser.parse('上======下'));

    final borders = tester
        .widgetList<Container>(find.byType(Container))
        .map((c) => c.decoration)
        .whereType<BoxDecoration>()
        .map((d) => d.border)
        .whereType<Border>()
        .where((b) => b.top.width == 1);
    expect(borders, hasLength(1));
    expect(borders.single.top.color, _theme.dividerColor);
  });

  testWidgets('table renders cells with borders', (tester) async {
    await _pumpHtml(
      tester,
      NgaContentParser.parse(
        '[table][tr][td]A[/td][td]B[/td][/tr]'
        '[tr][td colspan=2]合并[/td][/tr][/table]',
      ),
    );

    expect(find.byType(HtmlTable), findsOneWidget);
    for (final text in ['A', 'B', '合并']) {
      expect(_richText(text), findsOneWidget);
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('td width hint does not squeeze cell text', (tester) async {
    await _pumpHtml(
      tester,
      NgaContentParser.parse(
        '[table][tr][td20]二十宽度[/td][td]x[/td][/tr][/table]',
      ),
    );

    expect(
      tester.getSize(_richText('二十宽度')).height,
      tester.getSize(_richText('x')).height,
    );
  });

  testWidgets('link uses primary color and unknown tag stays visible', (
    tester,
  ) async {
    await _pumpHtml(
      tester,
      NgaContentParser.parse(
        '[url=https://bbs.nga.cn/read.php?tid=1]站内帖子[/url] '
        '[futuretag]原样[/futuretag]',
      ),
    );

    expect(_styleOf(tester, '站内帖子')?.color, _theme.colorScheme.primary);
    expect(_styleOf(tester, '站内帖子')?.decoration, TextDecoration.underline);
    final unknown = _styleOf(tester, '[futuretag]');
    expect(unknown, isNotNull);
    expect(unknown!.fontFamily, 'monospace');
    expect(_richText('原样'), findsOneWidget);
  });

  test('cssColor emits rgba with alpha', () {
    expect(cssColor(const Color(0x80FF0000)), 'rgba(255, 0, 0, 0.502)');
  });

  group('line break after block', () {
    Future<double> heightOf(WidgetTester tester, String ubb) async {
      final key = GlobalKey();
      await tester.pumpWidget(
        MaterialApp(
          theme: _theme,
          home: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                key: key,
                children: [NgaHtml(NgaContentParser.parse(ubb))],
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      return tester.getSize(find.byKey(key)).height;
    }

    for (final block in [
      '[quote]q[/quote]',
      '======',
      '[collapse=t]q[/collapse]',
      '[album=t]q[/album]',
      '[align=center]q[/align]',
      '[table][tr][td]q[/td][/tr][/table]',
    ]) {
      testWidgets('first <br> after $block is swallowed', (tester) async {
        final plain = await heightOf(tester, 'a${block}b');
        expect(await heightOf(tester, 'a$block<br/>b'), plain);
        expect(await heightOf(tester, 'a$block [b]<br/>b[/b]'), plain);
        // 第二个换行仍然生效
        expect(
          await heightOf(tester, 'a$block<br/><br/>b'),
          greaterThan(plain),
        );
      });
    }

    testWidgets('line breaks between inline text are kept', (tester) async {
      expect(
        await heightOf(tester, 'a<br/><br/>b'),
        greaterThan(await heightOf(tester, 'a<br/>b')),
      );
    });
  });
}
