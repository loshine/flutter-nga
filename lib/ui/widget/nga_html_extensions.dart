import 'package:flutter/rendering.dart' show RenderProxyBox;
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:html/dom.dart' as dom;
import 'package:material_ui/material_ui.dart';
import 'package:flutter_nga/ui/widget/collapse_widget.dart';
import 'package:flutter_nga/ui/widget/username_text.dart';
import 'package:flutter_nga/utils/route.dart';

/// NGA 帖子 / 评论通用的 HTML 渲染入口。
///
/// 负责把 `NgaContentParser` 的输出交给 flutter_widget_from_html_core：
/// - 自定义标签（`nga_quote` / `album` / `collapse` / `nga_dict` / `nga_emoticon`）
///   由 [NgaHtmlWidgetFactory] 与 [_buildCustomWidget] 处理；
/// - 样式统一走 `customStylesBuilder`，颜色取自 material_ui 主题；
/// - 链接点击交给 [Routes.onLinkTap]。
///
/// 未注册的标签沿用 fwfh 的默认行为：按行内元素渲染其子节点。
class NgaHtml extends StatelessWidget {
  const NgaHtml(
    this.html, {
    super.key,
    this.textStyle,
    this.decorateBlocks = true,
  });

  final String html;

  /// 根节点文字样式（字号、行高、颜色、整体装饰）。
  final TextStyle? textStyle;

  /// 是否给引用块 / 表格加背景与边框（帖子正文开启，评论沿用默认外观）。
  final bool decorateBlocks;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final primary = cssColor(colorScheme.primary);
    final unknownColor = theme.textTheme.bodySmall?.color?.withValues(
      alpha: 0.75,
    );

    return HtmlWidget(
      html,
      textStyle: textStyle,
      // 长楼层（>1 万字符）默认会异步构建，列表里会先占位再跳变高度；与旧版一致保持同步。
      buildAsync: false,
      factoryBuilder: NgaHtmlWidgetFactory.new,
      customWidgetBuilder: _buildCustomWidget,
      customStylesBuilder: (element) {
        switch (element.localName) {
          case 'a':
            return {'color': primary};
          case 'nga_dict':
            return {
              'color': primary,
              'text-decoration-line': 'underline',
              'text-decoration-style': 'dotted',
              'text-decoration-color': primary,
            };
          case 'hr':
            return {
              'margin': '8px 0',
              'border-top': '1px solid ${cssColor(theme.dividerColor)}',
            };
          case 'pre':
            return {
              'margin': '8px 0',
              'padding': '8px',
              'background-color': cssColor(
                theme.dividerColor.withValues(alpha: 0.15),
              ),
              'font-family': 'monospace',
              'white-space': 'pre',
            };
          case 'code':
            return {'font-family': 'monospace'};
        }
        if (element.classes.contains('ubb-unknown')) {
          return {
            'font-family': 'monospace',
            if (unknownColor != null) 'color': cssColor(unknownColor),
          };
        }
        if (!decorateBlocks) return null;
        final border = '1px solid ${cssColor(colorScheme.outlineVariant)}';
        switch (element.localName) {
          case 'blockquote':
            return {
              'margin': '4px 0',
              'padding': '8px 12px',
              'background-color': cssColor(colorScheme.surfaceContainerHigh),
            };
          case 'table':
            return {
              'margin': '8px',
              'border': border,
              'border-collapse': 'collapse',
            };
          case 'td':
            return {
              'padding': '8px',
              'border': border,
              'background-color': cssColor(
                colorScheme.surfaceContainerLowest.withValues(alpha: 0.6),
              ),
            };
        }
        return null;
      },
      onTapUrl: (url) {
        Routes.onLinkTap(context, url);
        return true;
      },
    );
  }
}

/// 把 [Color] 转成 csslib 能解析的 `rgba()`。
@visibleForTesting
String cssColor(Color color) {
  int channel(double value) => (value * 255).round().clamp(0, 255);
  final alpha = color.a.toStringAsFixed(3);
  return 'rgba(${channel(color.r)}, ${channel(color.g)}, ${channel(color.b)}, $alpha)';
}

/// 行内表情：`<nga_emoticon src height descent>`，加载失败或缺 src 时回退为
/// `[表情]`。
///
/// 与网页版一致按原图尺寸显示：高度取 `height`（图片原始高度），宽度随图片比例；
/// 预先占住高度，避免图片加载后行高跳动。缺 `height` 时按图片自身尺寸。
/// 垂直方向对齐文字基线，底边再下沉 `descent`（网页的 `vertical-align` 负值）。
Widget? _buildCustomWidget(dom.Element element) {
  if (element.localName != 'nga_emoticon') return null;
  final src = element.attributes['src'];
  if (src == null || src.isEmpty) {
    return const InlineCustomWidget(child: Text('[表情]'));
  }
  return InlineCustomWidget(
    child: EmoticonBaseline(
      descent: double.tryParse(element.attributes['descent'] ?? '') ?? 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Image.network(
          src,
          height: double.tryParse(element.attributes['height'] ?? ''),
          errorBuilder: (_, _, _) => const Text('[表情]'),
        ),
      ),
    ),
  );
}

/// 让没有文字基线的子组件（图片）以「距底部 [descent]」处作为基线，
/// 等价于 CSS 的 `vertical-align: -descent`。子组件自带基线（如加载失败时的
/// 占位文字）时沿用其基线。
@visibleForTesting
class EmoticonBaseline extends SingleChildRenderObjectWidget {
  const EmoticonBaseline({
    super.key,
    required this.descent,
    required super.child,
  });

  final double descent;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      RenderEmoticonBaseline(descent);

  @override
  void updateRenderObject(
    BuildContext context,
    RenderEmoticonBaseline renderObject,
  ) {
    renderObject.descent = descent;
  }
}

/// [EmoticonBaseline] 的渲染对象。
class RenderEmoticonBaseline extends RenderProxyBox {
  RenderEmoticonBaseline(this._descent);

  double _descent;

  set descent(double value) {
    if (value == _descent) return;
    _descent = value;
    markNeedsLayout();
  }

  @override
  double? computeDistanceToActualBaseline(TextBaseline baseline) =>
      child?.getDistanceToActualBaseline(baseline) ?? size.height - _descent;

  @override
  double? computeDryBaseline(
    BoxConstraints constraints,
    TextBaseline baseline,
  ) =>
      child?.getDryBaseline(constraints, baseline) ??
      getDryLayout(constraints).height - _descent;
}

/// 注册 NGA 自定义块级标签，并把图片加载 / 失败占位换成 material_ui 组件。
class NgaHtmlWidgetFactory extends WidgetFactory {
  BuildOp? _quoteOp;
  BuildOp? _albumOp;
  BuildOp? _collapseOp;
  BuildOp? _dictOp;

  @override
  void parse(BuildTree tree) {
    switch (tree.element.localName) {
      case 'br':
        // 对齐 flutter_html：块元素后紧跟的第一个换行不再额外占一行。
        if (_followsBlockElement(tree.element)) return;
      case 'td':
      case 'th':
        // NGA 的 [td20] 会输出 width:20%，fwfh 会把它作用在单元格内容上，
        // 导致文字被挤成竖排；样式解析前去掉，列宽交给表格自适应。
        final style = tree.element.attributes['style'];
        if (style != null && style.contains('width')) {
          tree.element.attributes['style'] = style.replaceAll(_widthDecl, '');
        }
      case 'nga_quote':
        tree.register(
          _quoteOp ??= BuildOp(
            debugLabel: 'nga_quote',
            onRenderBlock: (tree, placeholder) => _NgaQuoteBar(
              attributes: _attributesOf(tree),
              body: placeholder.isEmpty ? null : placeholder,
            ),
          ),
        );
      case 'album':
        tree.register(
          _albumOp ??= BuildOp(
            debugLabel: 'album',
            onRenderBlock: (tree, placeholder) => _NgaAlbum(
              title: tree.element.attributes['title'],
              body: placeholder,
            ),
          ),
        );
      case 'collapse':
        tree.register(
          _collapseOp ??= BuildOp(
            debugLabel: 'collapse',
            onRenderBlock: (tree, placeholder) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: CollapseWidget.fromNodes(
                title: tree.element.attributes['title'],
                child: placeholder,
              ),
            ),
          ),
        );
      case 'nga_dict':
        // 行内块：沿用继承来的文字样式渲染词条，外面包一层点击弹出注释。
        tree.register(
          _dictOp ??= BuildOp.inline(
            debugLabel: 'nga_dict',
            onRenderInlineBlock: (tree, child) {
              final term = (tree.element.attributes['term'] ?? '').trim();
              final definition = (tree.element.attributes['definition'] ?? '')
                  .trim();
              if (term.isEmpty || definition.isEmpty) return child;
              return _NgaDictionaryTerm(
                term: term,
                definition: definition,
                child: child,
              );
            },
          ),
        );
    }
    super.parse(tree);
  }

  static final _widthDecl = RegExp(r'(?<![-\w])width\s*:[^;]*;?');

  static const _blockTags = {
    'address',
    'album',
    'article',
    'aside',
    'blockquote',
    'body',
    'center',
    'collapse',
    'dd',
    'details',
    'div',
    'dl',
    'dt',
    'figure',
    'footer',
    'h1',
    'h2',
    'h3',
    'h4',
    'h5',
    'h6',
    'header',
    'hr',
    'li',
    'main',
    'nav',
    'nga_quote',
    'ol',
    'p',
    'pre',
    'section',
    'table',
    'ul',
  };

  /// [node] 之前（文档顺序、跳过空白文本，并穿过以它开头的行内父元素）
  /// 最近的节点是否为块元素。
  static bool _followsBlockElement(dom.Node node) {
    var current = node;
    while (true) {
      final parent = current.parentNode;
      if (parent == null) return false;
      final siblings = parent.nodes;
      var index = siblings.indexOf(current) - 1;
      while (index >= 0) {
        final prev = siblings[index];
        if (prev is dom.Text && prev.text.trim().isEmpty) {
          index--;
          continue;
        }
        return prev is dom.Element && _blockTags.contains(prev.localName);
      }
      // 是父元素的首个内容：父元素为行内元素时继续向外找。
      if (parent is! dom.Element || _blockTags.contains(parent.localName)) {
        return false;
      }
      current = parent;
    }
  }

  static Map<String, String> _attributesOf(BuildTree tree) => {
    for (final entry in tree.element.attributes.entries)
      '${entry.key}': entry.value,
  };

  @override
  Widget? onLoadingBuilder(
    BuildContext context,
    BuildTree tree, [
    double? loadingProgress,
    dynamic data,
  ]) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: SizedBox.square(
          dimension: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            value: loadingProgress,
          ),
        ),
      ),
    );
  }

  @override
  Widget? onErrorBuilder(
    BuildContext context,
    BuildTree tree, [
    dynamic error,
    dynamic data,
  ]) {
    return Icon(
      Icons.broken_image_outlined,
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );
  }
}

class _NgaAlbum extends StatelessWidget {
  const _NgaAlbum({required this.title, required this.body});

  final String? title;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = (title ?? '').trim();
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text.isEmpty ? '相册' : text,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          body,
        ],
      ),
    );
  }
}

class _NgaDictionaryTerm extends StatelessWidget {
  final String term;
  final String definition;
  final Widget child;

  const _NgaDictionaryTerm({
    required this.term,
    required this.definition,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: term,
      hint: '查看词条注释',
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _showDefinition(context),
        child: child,
      ),
    );
  }

  void _showDefinition(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(term),
        content: SingleChildScrollView(
          child: NgaHtml(
            definition,
            textStyle: TextStyle(
              color: Theme.of(dialogContext).textTheme.bodyMedium?.color,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }
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
    final baseStyle = textTheme.bodySmall?.copyWith(
      color: colorScheme.onSurfaceVariant,
    );

    final header = Row(
      children: [
        Icon(Icons.format_quote, size: 16, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Expanded(
          child: Row(
            children: [
              Text('回复', style: baseStyle),
              if (author.isNotEmpty)
                Flexible(
                  child: UsernameText(
                    username: author,
                    uid: int.tryParse(uid ?? ''),
                    suffix: floor == null ? '' : '($floor)',
                    style: baseStyle?.copyWith(color: colorScheme.primary),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
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
