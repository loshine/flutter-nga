import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_nga/providers/settings/interface_settings_provider.dart';
import 'package:flutter_nga/ui/widget/nga_html_extensions.dart';
import 'package:flutter_nga/utils/dimen.dart';
import 'package:flutter_nga/utils/parser/content_parser.dart';

class NgaHtmlContentWidget extends ConsumerWidget {
  final String content;
  final int? authorId;
  final int? tid;
  final int? pid;
  final int? postDateTimestamp;

  /// 同页楼层 pid → 正文片段，用于把 Reply to 补成带原文的引用（对齐官网）
  final Map<int, String>? quoteBodyByPid;

  /// 正文整体的文字装饰，用于屏蔽的删除线模式
  final TextDecoration? textDecoration;

  const NgaHtmlContentWidget({
    super.key,
    required this.content,
    this.authorId,
    this.tid,
    this.pid,
    this.postDateTimestamp,
    this.quoteBodyByPid,
    this.textDecoration,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final interfaceState = ref.watch(interfaceSettingsProvider);
    return NgaHtml(
      NgaContentParser.parse(
        content,
        authorId: authorId,
        tid: tid,
        pid: pid,
        postDateTimestamp: postDateTimestamp,
        quoteBodyByPid: quoteBodyByPid,
      ),
      textStyle: TextStyle(
        fontSize: Dimen.bodyMedium * interfaceState.contentSizeMultiple,
        height: interfaceState.lineHeight.size,
        color: Theme.of(context).textTheme.bodyLarge?.color,
        decoration: textDecoration,
      ),
    );
  }
}
