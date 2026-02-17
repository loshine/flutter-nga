import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_nga/ui/widget/collapse_widget.dart';

List<HtmlExtension> buildNgaHtmlExtensions(BuildContext context) {
  return [
    TagExtension(
      tagsToExtend: {'collapse'},
      builder: (extensionContext) {
        final title = extensionContext.attributes['title'];
        final children =
            extensionContext.inlineSpanChildren ?? const <InlineSpan>[];
        final style =
            (extensionContext.styledElement?.style ?? Style()).copyWith(
          display: Display.block,
          margin: Margins.zero,
          padding: HtmlPaddings.zero,
        );
        final body = CssBoxWidget.withInlineSpanChildren(
          style: style,
          children: children,
        );
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: CollapseWidget.fromNodes(
            title: title,
            child: body,
          ),
        );
      },
    ),
    TagExtension.inline(
      tagsToExtend: {'nga_emoticon'},
      builder: (extensionContext) {
        final src = extensionContext.attributes['src'];
        if (src == null || src.isEmpty) {
          return const TextSpan(text: '[表情]');
        }
        return WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Image.network(
              src,
              width: 22,
              height: 22,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Text('[表情]'),
            ),
          ),
        );
      },
    ),
    TagExtension(
      tagsToExtend: {'nga_hr'},
      builder: (_) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Divider(
          height: 1,
          color: Theme.of(context).dividerColor,
        ),
      ),
    ),
  ];
}
