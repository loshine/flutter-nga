import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;

import 'package:flutter_nga/utils/parser/content_parser.dart';

/// 把楼层 UBB 正文转成适合复制的纯文本。
///
/// 先走与渲染相同的 [NgaContentParser.parse]，再把 HTML 拍平成文字：
/// - `<br>` 与块级元素边界换行，连续空行最多保留一行；
/// - 引用其他楼层的 `<nga_quote>`（含 Reply to 标题条）不复制，只保留本楼的话；
/// - 图片记作 `[图片]`，表情、加密块分别记作 `[表情]`、`[加密内容]`；
/// - 折叠块按展开后的正文输出，链接保留显示文字。
String ngaContentToPlainText(
  String? content, {
  int? authorId,
  int? tid,
  int? pid,
  int? postDateTimestamp,
}) {
  if (content == null || content.isEmpty) return '';
  final html = NgaContentParser.parse(
    content,
    authorId: authorId,
    tid: tid,
    pid: pid,
    postDateTimestamp: postDateTimestamp,
  );
  return htmlToPlainText(html);
}

/// 把 [NgaContentParser] 输出的 HTML 转成纯文本，规则见 [ngaContentToPlainText]。
String htmlToPlainText(String html) {
  if (html.isEmpty) return '';
  final fragment = html_parser.parseFragment(html);
  final buffer = StringBuffer();
  _write(fragment.nodes, buffer);
  return buffer
      .toString()
      .replaceAll(' ', ' ')
      .replaceAll(RegExp(r'[ \t]+\n'), '\n')
      .replaceAll(RegExp(r'\n{3,}'), '\n\n')
      .trim();
}

const _skippedTags = {'nga_quote', 'script', 'style'};

const _blockTags = {
  'album',
  'blockquote',
  'collapse',
  'div',
  'h1',
  'h2',
  'h3',
  'h4',
  'h5',
  'h6',
  'li',
  'nga_headline',
  'ol',
  'p',
  'pre',
  'table',
  'tr',
  'ul',
};

void _write(List<dom.Node> nodes, StringBuffer buffer) {
  for (final node in nodes) {
    if (node is dom.Text) {
      buffer.write(node.text);
    } else if (node is dom.Element) {
      _writeElement(node, buffer);
    }
  }
}

void _writeElement(dom.Element element, StringBuffer buffer) {
  final tag = element.localName;
  if (_skippedTags.contains(tag)) return;
  switch (tag) {
    case 'br':
      buffer.write('\n');
      return;
    case 'hr':
      _newLine(buffer);
      return;
    case 'img':
      buffer.write('[图片]');
      return;
    case 'nga_emoticon':
      buffer.write('[表情]');
      return;
    case 'nga_crypt':
      _newLine(buffer);
      buffer.write('[加密内容]');
      _newLine(buffer);
      return;
    case 'td' || 'th':
      _write(element.nodes, buffer);
      buffer.write('\t');
      return;
  }
  final isBlock = _blockTags.contains(tag);
  if (isBlock) _newLine(buffer);
  if (tag == 'collapse' || tag == 'album') {
    final title = element.attributes['title']?.trim();
    if (title != null && title.isNotEmpty) {
      buffer.write(title);
      _newLine(buffer);
    }
  }
  _write(element.nodes, buffer);
  if (isBlock) _newLine(buffer);
}

/// 已在行首时不重复换行，避免块元素嵌套产生多余空行。
void _newLine(StringBuffer buffer) {
  if (buffer.isEmpty) return;
  final text = buffer.toString();
  if (!text.endsWith('\n')) buffer.write('\n');
}
