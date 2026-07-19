import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_nga/ui/widget/collapse_widget.dart';
import 'package:flutter_nga/utils/route.dart';

List<HtmlExtension> buildNgaHtmlExtensions(BuildContext context) {
  return [
    TagExtension(
      tagsToExtend: {'nga_quote'},
      builder: (extensionContext) {
        final children =
            extensionContext.inlineSpanChildren ?? const <InlineSpan>[];
        final style =
            (extensionContext.styledElement?.style ?? Style()).copyWith(
          display: Display.block,
          margin: Margins.zero,
          padding: HtmlPaddings.zero,
        );
        final body = children.isEmpty
            ? null
            : CssBoxWidget.withInlineSpanChildren(
                style: style,
                children: children,
              );
        return _NgaQuoteBar(
          attributes: extensionContext.attributes,
          body: body,
        );
      },
    ),
    TagExtension(
      tagsToExtend: {'album'},
      builder: (extensionContext) {
        final title = (extensionContext.attributes['title'] ?? '相册').trim();
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
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.8),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title.isEmpty ? '相册' : title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              body,
            ],
          ),
        );
      },
    ),
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

/// 回复引用卡：`<nga_quote pid tid uid author floor date>原文</nga_quote>`
/// - 标题条：作者 / 时间，整条可点进原帖
/// - 子节点：被引用原文（与网页端 quote 块一致）
class _NgaQuoteBar extends StatelessWidget {
  final Map<String, String> attributes;
  final Widget? body;

  const _NgaQuoteBar({required this.attributes, this.body});

  @override
  Widget build(BuildContext context) {
    final pid = attributes['pid'];
    final tid = attributes['tid'];
    final uid = attributes['uid'];
    final author = (attributes['author'] ?? '').trim();
    final floor = attributes['floor'];
    final date = (attributes['date'] ?? '').trim();
    final hasBody = body != null;

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final baseStyle =
        textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant);

    final header = Row(
      children: [
        Icon(
          Icons.format_quote,
          size: 16,
          color: colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Row(
            children: [
              Text('回复', style: baseStyle),
              if (author.isNotEmpty)
                Flexible(
                  child: GestureDetector(
                    // 匿名无 uid，不可点击，手势透传给整条引用条
                    onTap: uid == null || uid.isEmpty
                        ? null
                        : () => Routes.onLinkTap(
                            context, 'nuke.php?func=ucp&uid=$uid'),
                    child: Text(
                      floor != null ? '$author($floor)' : author,
                      style: baseStyle?.copyWith(color: colorScheme.primary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              if (date.isNotEmpty)
                Text(' · $date', style: baseStyle, maxLines: 1),
            ],
          ),
        ),
        Icon(
          Icons.chevron_right,
          size: 16,
          color: colorScheme.onSurfaceVariant,
        ),
      ],
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(8),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InkWell(
              onTap: () => _openQuote(context, pid: pid, tid: tid),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: header,
              ),
            ),
            if (hasBody) ...[
              Divider(
                height: 1,
                thickness: 1,
                color: colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
                child: body,
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 复用站内链接路由：pid 弹楼层详情，tid 跳话题详情
  void _openQuote(BuildContext context, {String? pid, String? tid}) {
    if (pid != null && pid.isNotEmpty) {
      Routes.onLinkTap(context, 'read.php?searchpost=1&pid=$pid');
    } else if (tid != null && tid.isNotEmpty) {
      Routes.onLinkTap(context, 'read.php?tid=$tid');
    }
  }
}
