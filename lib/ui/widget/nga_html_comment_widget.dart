import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_nga/providers/settings/interface_settings_provider.dart';
import 'package:flutter_nga/utils/dimen.dart';
import 'package:flutter_nga/utils/parser/content_parser.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NgaHtmlCommentWidget extends ConsumerWidget {
  final String content;

  const NgaHtmlCommentWidget({Key? key, required this.content})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final interfaceState = ref.watch(interfaceSettingsProvider);
    return Html(
      data: NgaContentParser.parseComment(content),
      style: {
        'body': Style(
          fontSize: FontSize(Dimen.body * interfaceState.contentSizeMultiple),
          lineHeight: LineHeight(interfaceState.lineHeight.size),
          padding: HtmlPaddings.zero,
          margin: Margins.zero,
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
      },
    );
  }
}
