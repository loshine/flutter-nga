import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_nga/store/settings/interface_settings_store.dart';
import 'package:flutter_nga/utils/dimen.dart';
import 'package:flutter_nga/utils/parser/content_parser.dart';
import 'package:flutter_nga/utils/route.dart';
import 'package:html/dom.dart' as dom;
import 'package:provider/provider.dart';

class NgaHtmlContentWidget extends StatelessWidget {
  final String content;

  const NgaHtmlContentWidget({Key? key, required this.content})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Html(
      data: NgaContentParser.parse(content),
      style: {
        'body': Style(
          lineHeight: LineHeight(
              Provider.of<InterfaceSettingsStore>(context).lineHeight.size),
          padding: HtmlPaddings.zero,
          margin: Margins.zero,
          color: Theme.of(context).textTheme.bodyLarge?.color,
          fontSize: FontSize(Dimen.body *
              Provider.of<InterfaceSettingsStore>(context).contentSizeMultiple),
        ),
        'blockquote': Style(
          padding: HtmlPaddings.zero,
          margin: Margins.zero,
        ),
        'table': Style(
          margin: Margins.all(8),
          border: Border(
            left: BorderSide(color: Colors.grey.shade300),
            right: BorderSide(color: Colors.grey.shade300),
            top: BorderSide(color: Colors.grey.shade300),
          ),
        ),
        'tr': Style(
          backgroundColor: Colors.white.withValues(alpha: 0.6),
          border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
        ),
        'td': Style(padding: HtmlPaddings.all(8)),
      },
      onLinkTap: (String? url, Map<String, String> attributes, dom.Element? element) {
        Routes.onLinkTap(context, url);
      },
    );
  }
}
