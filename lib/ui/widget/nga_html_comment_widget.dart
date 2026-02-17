import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_nga/providers/settings/interface_settings_provider.dart';
import 'package:flutter_nga/utils/dimen.dart';
import 'package:flutter_nga/utils/parser/content_parser.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NgaHtmlCommentWidget extends ConsumerWidget {
  final String content;
  final int? authorId;
  final int? tid;
  final int? pid;

  const NgaHtmlCommentWidget({
    super.key,
    required this.content,
    this.authorId,
    this.tid,
    this.pid,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final interfaceState = ref.watch(interfaceSettingsProvider);
    return Html(
      data: NgaContentParser.parseComment(content, authorId: authorId, tid: tid, pid: pid),
      style: {
        'body': Style(
          fontSize: FontSize(Dimen.bodyMedium * interfaceState.contentSizeMultiple),
          lineHeight: LineHeight(interfaceState.lineHeight.size),
          padding: HtmlPaddings.zero,
          margin: Margins.zero,
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
      },
    );
  }
}
