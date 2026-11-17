import 'dart:math';

import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:flutter_nga/data/core/nga_domains.dart';
import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/data/entity/emoticon.dart';
import 'package:flutter_nga/utils/code_utils.dart' as code_utils;
import 'package:flutter_nga/utils/dice_roller.dart';
import 'package:flutter_nga/utils/name_utils.dart';
import 'package:flutter_nga/utils/parser/nga_crypt.dart';

class NgaContentParser {
  static final Parser _lesserNukeParser = _LesserNukeParser();
  static final Parser _replyParser = _ReplyParser();
  static final Parser _commentParser = _CommentParser();
  static final Parser _randomBlockParser = _RandomBlockParser();
  static final Parser _albumParser = _AlbumParser();
  static final Parser _tableParser = _TableParser();
  static final Parser _headlineParser = _HeadlineParser();
  static final Parser _emoticonParser = _EmoticonParser();
  static final Parser _dictionaryParser = _DictionaryParser();
  static final Parser _fallbackParser = _UnsupportedTagFallbackParser();

  // 优化 3: LRU 缓存（最多缓存 256 条）
  static final _parseCache = <String, String>{};
  static final _cacheKeys = <String>[];
  static const _maxCacheSize = 256;

  /// 与官网一致：缓存每层正文前 250 字（去掉引用头），供 Reply to 补原文
  static const quoteSnippetMaxLength = 250;

  static final _quoteBlockRegex = RegExp(
    r'\[quote\][\s\S]*?\[/quote\]',
    caseSensitive: false,
  );
  static final _replyToLineRegex = RegExp(
    r'^\[b\]Reply to \[pid=\d+,\d+,\d+\]Reply\[/pid\] Post by .+?\[/b\]\s*',
    caseSensitive: false,
  );
  // Reply to → 展开为 [quote]…[/quote]（官网 contentQuoteCache 逻辑）
  static final _expandReplyToPidRegex = RegExp(
    r'\[b\]Reply to \[pid=(\d+),(\d+)?,(\d+)?\]Reply\[/pid\] Post by (\[uid(?:=\d+)?\][\s\S]*?\[/uid\](?:\[color=gray\]\([\s\S]*?\)\[/color\])? \([\s\S]*?\))\[/b\]',
    caseSensitive: false,
  );

  static List<Parser> _buildParserList({
    int? authorId,
    int? tid,
    int? pid,
    int? postDateTimestamp,
  }) {
    return [
      _CryptParser(
        authorId: authorId,
        tid: tid,
        pid: pid,
        postDateTimestamp: postDateTimestamp,
      ),
      _randomBlockParser,
      _albumParser,
      _tableParser,
      _headlineParser,
      _ContentParser(postDateTimestamp: postDateTimestamp),
      _emoticonParser,
      _dictionaryParser,
      _fallbackParser,
    ];
  }

  /// 从同页楼层构建 pid → 可引用正文片段（对齐官网 contentQuoteCache）
  static Map<int, String> buildQuoteBodyCache(
    Iterable<({int? pid, String content})> posts,
  ) {
    final map = <int, String>{};
    for (final post in posts) {
      final pid = post.pid;
      if (pid == null || pid == 0) continue;
      final snippet = extractQuoteSnippet(post.content);
      if (snippet.isNotEmpty) {
        map[pid] = snippet;
      }
    }
    return map;
  }

  /// 去掉引用 / Reply to 头后取前 [quoteSnippetMaxLength] 字
  static String extractQuoteSnippet(String content) {
    var text = content;
    // 多层 [quote] 由内到外剥掉
    for (var i = 0; i < 8; i++) {
      final next = text.replaceAll(_quoteBlockRegex, '');
      if (next == text) break;
      text = next;
    }
    text = text.replaceFirst(_replyToLineRegex, '');
    text = text.replaceAll(_LesserNukeParser._tagRegex, '');
    text = text.trim();
    if (text.length > quoteSnippetMaxLength) {
      text = text.substring(0, quoteSnippetMaxLength);
    }
    return text;
  }

  /// 将「Reply to」在缓存命中时展开为带原文的 [quote]（与官网一致）
  static String expandReplyToWithCachedBody(
    String content,
    Map<int, String> quoteBodyByPid,
  ) {
    if (content.isEmpty || quoteBodyByPid.isEmpty) return content;
    if (!content.contains('Reply to')) return content;

    return content.replaceAllMapped(_expandReplyToPidRegex, (m) {
      final pid = int.tryParse(m.group(1) ?? '');
      if (pid == null) return m.group(0)!;
      final body = quoteBodyByPid[pid];
      if (body == null || body.isEmpty) return m.group(0)!;

      final tid = m.group(2) ?? '';
      final flag = m.group(3) ?? '1';
      final postBy = m.group(4) ?? '';
      // 转成标准引用格式，后续 _ReplyParser 会收成 <nga_quote>body</nga_quote>
      return '[quote][pid=$pid,$tid,$flag]Reply[/pid] [b]Post by $postBy:[/b]\n\n$body[/quote]';
    });
  }

  static String parse(
    String? content, {
    int? authorId,
    int? tid,
    int? pid,
    int? postDateTimestamp,
    Map<int, String>? quoteBodyByPid,
  }) {
    if (content == null || content.isEmpty) return '';

    final quoteSuffix = (quoteBodyByPid == null || quoteBodyByPid.isEmpty)
        ? ''
        : '__q${quoteBodyByPid.length}_${quoteBodyByPid.keys.fold<int>(0, (a, b) => a ^ b)}';
    final cacheKey = authorId != null
        ? '__dice_${authorId}_${tid}_${pid}_$postDateTimestamp${quoteSuffix}__$content'
        : '__postdate_$postDateTimestamp${quoteSuffix}__$content';
    if (_parseCache.containsKey(cacheKey)) {
      return _parseCache[cacheKey]!;
    }

    var parseContent = _lesserNukeParser.parse(
      code_utils.unescapeHtml(content),
    );
    // 官网：Reply to 用同页 pid 缓存补原文，再当 quote 渲染
    if (quoteBodyByPid != null && quoteBodyByPid.isNotEmpty) {
      parseContent = expandReplyToWithCachedBody(parseContent, quoteBodyByPid);
    }
    parseContent = _replyParser.parse(parseContent);
    if (authorId != null && tid != null && pid != null) {
      parseContent = _DiceParser(
        authorId: authorId,
        tid: tid,
        pid: pid,
      ).parse(parseContent);
    }
    for (final parser in _buildParserList(
      authorId: authorId,
      tid: tid,
      pid: pid,
      postDateTimestamp: postDateTimestamp,
    )) {
      parseContent = parser.parse(parseContent);
    }

    _cacheKeys.add(cacheKey);
    _parseCache[cacheKey] = parseContent;
    if (_cacheKeys.length > _maxCacheSize) {
      _parseCache.remove(_cacheKeys.removeAt(0));
    }

    return parseContent;
  }

  static String parseComment(
    String? content, {
    int? authorId,
    int? tid,
    int? pid,
    int? postDateTimestamp,
  }) {
    if (content == null || content.isEmpty) return '';

    final cacheKey = authorId != null
        ? '__comment_dice_${authorId}_${tid}_${pid}_${postDateTimestamp}__$content'
        : '__comment_postdate_${postDateTimestamp}__$content';
    if (_parseCache.containsKey(cacheKey)) {
      return _parseCache[cacheKey]!;
    }

    var parseContent = _lesserNukeParser.parse(
      code_utils.unescapeHtml(content),
    );
    parseContent = _commentParser.parse(parseContent);
    if (authorId != null && tid != null && pid != null) {
      parseContent = _DiceParser(
        authorId: authorId,
        tid: tid,
        pid: pid,
      ).parse(parseContent);
    }
    for (final parser in _buildParserList(
      authorId: authorId,
      tid: tid,
      pid: pid,
      postDateTimestamp: postDateTimestamp,
    )) {
      parseContent = parser.parse(parseContent);
    }

    _cacheKeys.add(cacheKey);
    _parseCache[cacheKey] = parseContent;
    if (_cacheKeys.length > _maxCacheSize) {
      _parseCache.remove(_cacheKeys.removeAt(0));
    }

    return parseContent;
  }

  // 清理缓存（内存紧张时调用）
  static void clearCache() {
    _parseCache.clear();
    _cacheKeys.clear();
  }
}

abstract class Parser {
  String parse(String? content);
}

class _RandomBlockParser implements Parser {
  static final _randomBlockRegex = RegExp(
    r'\[randomblock\]([\s\S]*?)\[/randomblock\]',
    caseSensitive: false,
  );
  static final _random = Random();

  @override
  String parse(String? content) {
    if (content == null || content.isEmpty) return '';

    final matches = _randomBlockRegex.allMatches(content).toList();
    if (matches.isEmpty) return content;

    final selectedIndex = matches.length == 1
        ? 0
        : _random.nextInt(matches.length);
    final result = StringBuffer();
    var cursor = 0;
    for (var index = 0; index < matches.length; index++) {
      final match = matches[index];
      result.write(content.substring(cursor, match.start));
      if (index == selectedIndex) {
        result.write(match.group(1) ?? '');
      }
      cursor = match.end;
    }
    result.write(content.substring(cursor));
    return result.toString();
  }
}

/// `[lessernuke]` / `[lessernuke1]`…`[lessernuke9]`：被处罚的发言，网页版只认
/// 正文开头的开标签和结尾的闭标签，整段内容折叠成「点击查看」。这里复用
/// `collapse` 渲染；不在首尾的标签直接去掉，不露出原文。
class _LesserNukeParser implements Parser {
  static final _openRegex = RegExp(
    r'^(?:\s|<br\s*/?>)*\[lessernuke(\d)?\]',
    caseSensitive: false,
  );
  static final _closeRegex = RegExp(
    r'\[/lessernuke\d?\](?:\s|<br\s*/?>)*$',
    caseSensitive: false,
  );
  static final _tagRegex = RegExp(r'\[/?lessernuke\d?\]', caseSensitive: false);

  @override
  String parse(String? content) {
    if (content == null || content.isEmpty) return '';
    if (!_tagRegex.hasMatch(content)) return content;

    final open = _openRegex.firstMatch(content);
    if (open == null) return content.replaceAll(_tagRegex, '');
    final body = content
        .substring(open.end)
        .replaceFirst(_closeRegex, '')
        .replaceAll(_tagRegex, '');
    final title = switch (open.group(1)) {
      '2' => '用户在主题中被处罚',
      '3' => '被锁定账号发布的内容无法查看',
      _ => '用户因此帖中的发言被处罚',
    };
    return "<collapse title='$title'>$body</collapse>";
  }
}

/// `[crypt]密文[/crypt]`：网页版输入密码后用 RC4 解密（见 [NgaCrypt]）。
/// 这里输出 `<nga_crypt data='…'>`，由渲染层提供密码输入框；密文按十六进制
/// 存放，避免后续 Parser（如 `===`、`------`）误改。
///
/// 明文要按所在楼层的参数重新解析（`[noimg]` 补日期目录、`[dice]` 掷骰），
/// 所以把楼层参数一并写进属性（`author` / `tid` / `pid` / `date`），
/// 渲染层原样传回 [NgaContentParser.parse]。这些参数都已在解析缓存的 key 里。
class _CryptParser implements Parser {
  _CryptParser({this.authorId, this.tid, this.pid, this.postDateTimestamp});

  final int? authorId;
  final int? tid;
  final int? pid;
  final int? postDateTimestamp;

  static final _cryptRegex = RegExp(
    r'\[crypt\]([\s\S]*?)\[/crypt\]',
    caseSensitive: false,
  );

  @override
  String parse(String? content) {
    if (content == null || content.isEmpty) return '';
    return content.replaceAllMapped(_cryptRegex, (m) {
      final cipher = (m.group(1) ?? '').trim();
      if (!NgaCrypt.isValidCipher(cipher)) return '<nga_crypt></nga_crypt>';
      final buffer = StringBuffer(
        "<nga_crypt data='${NgaCrypt.toHex(cipher)}'",
      );
      void writeAttr(String key, int? value) {
        if (value != null) buffer.write(" $key='$value'");
      }

      writeAttr('author', authorId);
      writeAttr('tid', tid);
      writeAttr('pid', pid);
      writeAttr('date', postDateTimestamp);
      buffer.write('></nga_crypt>');
      return buffer.toString();
    });
  }
}

/// `[headline]…[/headline]`：帖子头条，内容一般是 `[img]` 加 `[url]` /
/// `[tid]` / `[hltxt]` 标题。网页版把所有头条合成一个轮播放在第一处，这里
/// 同样合并为一个 `<nga_headline>` 块，每条一个 `<div>`；里面的 UBB 交给后续
/// Parser，`[hltxt]` 按加粗显示。
class _HeadlineParser implements Parser {
  static final _headlineRegex = RegExp(
    r'(?:\s|<br\s*/?>)*\[headline\]([\s\S]*?)\[/headline\](?:\s|<br\s*/?>)*',
    caseSensitive: false,
  );
  static final _hltxtRegex = RegExp(
    r'\[hltxt\]([\s\S]*?)\[/hltxt\]',
    caseSensitive: false,
  );

  @override
  String parse(String? content) {
    if (content == null || content.isEmpty) return '';
    final matches = _headlineRegex.allMatches(content).toList();
    if (matches.isEmpty) return content;

    final items = StringBuffer();
    for (final match in matches) {
      final item = (match.group(1) ?? '')
          .replaceAllMapped(_hltxtRegex, (m) => '<b>${m.group(1)}</b>')
          .trim();
      if (item.isNotEmpty) items.write('<div>$item</div>');
    }
    final block = items.isEmpty ? '' : '<nga_headline>$items</nga_headline>';

    final result = StringBuffer();
    var cursor = 0;
    for (var index = 0; index < matches.length; index++) {
      final match = matches[index];
      result.write(content.substring(cursor, match.start));
      if (index == 0) result.write(block);
      cursor = match.end;
    }
    result.write(content.substring(cursor));
    return result.toString();
  }
}

// 优化 1: 预编译正则
class _AlbumParser implements Parser {
  static final _albumRegex = RegExp(
    r'\[album(=([\s\S]*?)?)?\]([\s\S]*?)?\[/album\]',
    caseSensitive: false,
  );
  static final _urlRegex = RegExp(
    r'\[url\]([\s\S]*?)?\[/url\]',
    caseSensitive: false,
  );

  @override
  String parse(String? content) {
    if (content == null || content.isEmpty) return '';
    return content.replaceAllMapped(_albumRegex, (match) {
      final title = (match.group(2) ?? '').trim();
      final safeTitle = title.isEmpty ? '相册' : title;
      final value = (match.group(3) ?? '').replaceAllMapped(
        _urlRegex,
        (m) => "[img]${m.group(1) ?? ''}[/img]<br/>",
      );
      return "<album title='${_escapeHtmlAttribute(safeTitle)}'>$value</album>";
    });
  }
}

/// 表格：对齐网页版 `parseTable`。
///
/// - 标签可带选项：`[table noborder]`、`[tr th]`（表头行）、
///   `[td20]` / `[td width50]`（列宽）、`[td colspan2 rowspan=3]`（`=` 可省略）。
/// - 按栈配对：`[td]` 前缺 `[tr]` 时补开一行，`[/tr]`、`[/table]` 会先关掉未闭合的
///   单元格 / 行；没有对应开标签的闭标签丢弃，表格外的 `[tr]`、`[td]` 原样保留，
///   保证输出的 HTML 始终配对。
class _TableParser implements Parser {
  /// 选项须以空白、`=` 或数字开头，避免把 `[trick]` 之类当成 `[tr]`。
  static final _tokenRegex = RegExp(
    r'\[(/?)(table|tr|td)((?:[\s=\d][^\]\[]*)?)\]',
    caseSensitive: false,
  );
  static final _leadingWidthRegex = RegExp(r'^\s*(\d{1,3})(?!\d)');
  static final _namedWidthRegex = RegExp(
    r'(?:^|\s)width\s*=?\s*(\d{1,3})(?!\d)',
    caseSensitive: false,
  );
  static final _tdSpanAttrRegex = RegExp(
    r'(rowspan|colspan)\s*=?\s*(\d{1,2})',
    caseSensitive: false,
  );
  static final _optionWordRegex = RegExp(r'[a-zA-Z]+');
  static final _tagBrRegex = RegExp(
    r'<(/?(?:table|tbody|tr|td)(?:\s[^>]*)?)><br/>',
  );
  static final _brTagRegex = RegExp(
    r'[ ]?<br/><(/?(?:table|tbody|tr|td)(?:\s[^>]*)?)>',
  );

  @override
  String parse(String? content) {
    if (content == null || content.isEmpty) return '';
    if (!_tokenRegex.hasMatch(content)) return content;

    final output = StringBuffer();
    final stack = <_TableState>[];
    var cursor = 0;

    void closeCell(_TableState table) {
      if (!table.cellOpen) return;
      output.write('</td>');
      table.cellOpen = false;
    }

    void closeRow(_TableState table) {
      closeCell(table);
      if (!table.rowOpen) return;
      output.write('</tr>');
      table.rowOpen = false;
    }

    void closeTable() {
      closeRow(stack.removeLast());
      output.write('</tbody></table></div>');
    }

    for (final match in _tokenRegex.allMatches(content)) {
      output.write(content.substring(cursor, match.start));
      cursor = match.end;

      final isClose = match.group(1)!.isNotEmpty;
      final tag = match.group(2)!.toLowerCase();
      final options = match.group(3) ?? '';
      if (tag != 'table' && stack.isEmpty) {
        output.write(match.group(0));
        continue;
      }

      switch ((tag, isClose)) {
        case ('table', false):
          stack.add(_TableState());
          final noBorder = _hasOption(options, 'noborder');
          output.write(
            noBorder
                ? "<div><table class='noborder'><tbody>"
                : '<div><table><tbody>',
          );
        case ('table', true):
          if (stack.isNotEmpty) closeTable();
        case ('tr', false):
          final table = stack.last;
          closeRow(table);
          output.write(_hasOption(options, 'th') ? "<tr class='th'>" : '<tr>');
          table.rowOpen = true;
        case ('tr', true):
          closeRow(stack.last);
        case ('td', false):
          final table = stack.last;
          closeCell(table);
          if (!table.rowOpen) {
            output.write('<tr>');
            table.rowOpen = true;
          }
          output.write(_buildCellTag(options));
          table.cellOpen = true;
        case ('td', true):
          closeCell(stack.last);
      }
    }
    output.write(content.substring(cursor));
    while (stack.isNotEmpty) {
      closeTable();
    }

    return output
        .toString()
        .replaceAllMapped(_tagBrRegex, (match) => '<${match.group(1)}>')
        .replaceAllMapped(_brTagRegex, (match) => '<${match.group(1)}>')
        .replaceAll('</table>', '</table><br/><br/>');
  }

  static bool _hasOption(String options, String name) => _optionWordRegex
      .allMatches(options)
      .any((m) => m.group(0)!.toLowerCase() == name);

  static String _buildCellTag(String options) {
    final raw = options.trim();
    if (raw.isEmpty) return '<td>';

    final widthMatch =
        _leadingWidthRegex.firstMatch(raw) ?? _namedWidthRegex.firstMatch(raw);
    final widthPercent = int.tryParse(widthMatch?.group(1) ?? '');

    final attrs = <String, String>{};
    for (final spanMatch in _tdSpanAttrRegex.allMatches(raw)) {
      final value = int.tryParse(spanMatch.group(2)!);
      if (value != null && value > 0) {
        attrs[spanMatch.group(1)!.toLowerCase()] = '$value';
      }
    }

    final buffer = StringBuffer('<td');
    if (widthPercent != null && widthPercent > 0) {
      final clamped = widthPercent.clamp(1, 100);
      buffer.write(" style='width:$clamped%;'");
    }
    if (attrs.containsKey('rowspan')) {
      buffer.write(" rowspan='${attrs['rowspan']}'");
    }
    if (attrs.containsKey('colspan')) {
      buffer.write(" colspan='${attrs['colspan']}'");
    }
    buffer.write('>');
    return buffer.toString();
  }
}

class _TableState {
  bool rowOpen = false;
  bool cellOpen = false;
}

class _ReplyParser implements Parser {
  /// 最内层 [quote]…[/quote]（内容中不再含 [quote]），用于嵌套由内到外折叠
  static final _innermostQuoteRegex = RegExp(
    r'\[quote\]((?:(?!\[quote\])[\s\S])*?)\[/quote\]',
  );

  /// 引用块开头可能的空白 / <br>
  static final _leadingBreaksRegex = RegExp(r'^(?:\s|<br\s*/?>)*');

  // 引用头：匹配「引用」类（带原文 body，通常包在 [quote] 内）
  static final _topicRegex = RegExp(
    r'\[tid=(\d+)?\]Topic\[/tid\] \[b\]Post by \[uid=(\d+)?\]([\s\S]*?)\[/uid\] \(([\s\S]*?)\):\[/b\]',
  );
  static final _replyRegex = RegExp(
    r'\[pid=(\d+)?,(\d+)?,(\d+)?\]Reply\[/pid\] \[b\]Post by \[uid=(\d+)?\]([\s\S]*?)\[/uid\] \(([\s\S]*?)\):\[/b\]',
  );
  static final _anonyRegex = RegExp(
    r'\[pid=(\d+)?,(\d+)?,(\d+)?\]Reply\[/pid\] \[b\]Post by \[uid\]#anony_([0-9a-zA-Z]*)\[/uid\]\[color=gray\]\((\d+)?楼\)\[/color\] \(([\s\S]*?)\):\[/b\]',
  );
  // 引用头：「回复」类（通常无原文，仅指向原帖）
  static final _replyTopicRegex = RegExp(
    r'\[b\]Reply to \[tid=(\d+)?\]Topic\[/tid\] Post by \[uid=(\d+)?\]([\s\S]*?)\[/uid\] \(([\s\S]*?)\)\[/b\]',
  );
  static final _replyPostRegex = RegExp(
    r'\[b\]Reply to \[pid=(\d+)?,(\d+)?,(\d+)?\]Reply\[/pid\] Post by \[uid=(\d+)?\]([\s\S]*?)\[/uid\] \(([\s\S]*?)\)\[/b\]',
  );
  static final _anonyReplyTopicRegex = RegExp(
    r'\[b\]Reply to \[tid=(\d+)?\]Topic\[/tid\] Post by \[uid\]#anony_([0-9a-zA-Z]*)\[/uid\]\[color=gray\]\((\d+)?楼\)\[/color\] \(([\s\S]*?)\)\[/b\]',
  );
  static final _anonyReplyPostRegex = RegExp(
    r'\[b\]Reply to \[pid=(\d+)?,(\d+)?,(\d+)?\]Reply\[/pid\] Post by \[uid\]#anony_([0-9a-zA-Z]*)\[/uid\]\[color=gray\]\((\d+)?楼\)\[/color\] \(([\s\S]*?)\)\[/b\]',
  );

  @override
  String parse(String? content) {
    if (content == null || content.isEmpty) return '';

    // 1) 由内到外处理 [quote] 块：带头的引用把原文 body 收进 <nga_quote>
    var result = content;
    for (var i = 0; i < 8; i++) {
      final before = result;
      result = result.replaceAllMapped(_innermostQuoteRegex, (m) {
        final converted = _convertQuoteBlock(m.group(1) ?? '');
        // 未识别为带头发 → 保留 [quote] 交给 ContentParser 转 blockquote
        return converted ?? m.group(0)!;
      });
      if (result == before) break;
    }

    // 2) 剩余独立引用头（Reply to / 无 [quote] 包裹）→ 仅标题条
    return _replaceStandaloneHeaders(result);
  }

  /// 尝试把 quote 内部「引用头 + 原文」合成一个 nga_quote；识别失败返回 null
  static String? _convertQuoteBlock(String inner) {
    final trimmed = inner.replaceFirst(_leadingBreaksRegex, '');
    final header = _matchHeaderAtStart(trimmed);
    if (header == null) return null;

    // 去掉引用头后的 body（原文），保留后续 UBB 给下游 Parser
    var body = trimmed.substring(header.match.end);
    body = body.replaceFirst(_leadingBreaksRegex, '');
    return _buildQuoteTag(
      pid: header.pid,
      tid: header.tid,
      uid: header.uid,
      author: header.author,
      floor: header.floor,
      date: header.date,
      body: body,
    );
  }

  static String _replaceStandaloneHeaders(String content) {
    return content
        .replaceAllMapped(
          _topicRegex,
          (m) => _buildQuoteTag(
            tid: m.group(1),
            uid: m.group(2),
            author: m.group(3),
            date: m.group(4),
          ),
        )
        .replaceAllMapped(
          _replyRegex,
          (m) => _buildQuoteTag(
            pid: m.group(1),
            uid: m.group(4),
            author: m.group(5),
            date: m.group(6),
          ),
        )
        .replaceAllMapped(
          _anonyRegex,
          (m) => _buildQuoteTag(
            pid: m.group(1),
            author: getShowName("#anony_${m.group(4)}"),
            floor: "${m.group(5)}楼",
            date: m.group(6),
          ),
        )
        .replaceAllMapped(
          _replyTopicRegex,
          (m) => _buildQuoteTag(
            tid: m.group(1),
            uid: m.group(2),
            author: m.group(3),
            date: m.group(4),
          ),
        )
        .replaceAllMapped(
          _replyPostRegex,
          (m) => _buildQuoteTag(
            pid: m.group(1),
            uid: m.group(4),
            author: m.group(5),
            date: m.group(6),
          ),
        )
        .replaceAllMapped(
          _anonyReplyTopicRegex,
          (m) => _buildQuoteTag(
            tid: m.group(1),
            author: getShowName("#anony_${m.group(2)}"),
            floor: "${m.group(3)}楼",
            date: m.group(4),
          ),
        )
        .replaceAllMapped(
          _anonyReplyPostRegex,
          (m) => _buildQuoteTag(
            pid: m.group(1),
            author: getShowName("#anony_${m.group(4)}"),
            floor: "${m.group(5)}楼",
            date: m.group(6),
          ),
        );
  }

  static _QuoteHeader? _matchHeaderAtStart(String text) {
    Match? m;
    m = _replyRegex.matchAsPrefix(text);
    if (m != null) {
      return _QuoteHeader(
        match: m,
        pid: m.group(1),
        uid: m.group(4),
        author: m.group(5),
        date: m.group(6),
      );
    }
    m = _anonyRegex.matchAsPrefix(text);
    if (m != null) {
      return _QuoteHeader(
        match: m,
        pid: m.group(1),
        author: getShowName("#anony_${m.group(4)}"),
        floor: "${m.group(5)}楼",
        date: m.group(6),
      );
    }
    m = _topicRegex.matchAsPrefix(text);
    if (m != null) {
      return _QuoteHeader(
        match: m,
        tid: m.group(1),
        uid: m.group(2),
        author: m.group(3),
        date: m.group(4),
      );
    }
    m = _replyPostRegex.matchAsPrefix(text);
    if (m != null) {
      return _QuoteHeader(
        match: m,
        pid: m.group(1),
        uid: m.group(4),
        author: m.group(5),
        date: m.group(6),
      );
    }
    m = _replyTopicRegex.matchAsPrefix(text);
    if (m != null) {
      return _QuoteHeader(
        match: m,
        tid: m.group(1),
        uid: m.group(2),
        author: m.group(3),
        date: m.group(4),
      );
    }
    m = _anonyReplyPostRegex.matchAsPrefix(text);
    if (m != null) {
      return _QuoteHeader(
        match: m,
        pid: m.group(1),
        author: getShowName("#anony_${m.group(4)}"),
        floor: "${m.group(5)}楼",
        date: m.group(6),
      );
    }
    m = _anonyReplyTopicRegex.matchAsPrefix(text);
    if (m != null) {
      return _QuoteHeader(
        match: m,
        tid: m.group(1),
        author: getShowName("#anony_${m.group(2)}"),
        floor: "${m.group(3)}楼",
        date: m.group(4),
      );
    }
    return null;
  }

  /// 构建 `<nga_quote>` 标签；[body] 为被引用原文（UBB，后续 Parser 继续处理）
  static String _buildQuoteTag({
    String? pid,
    String? tid,
    String? uid,
    String? author,
    String? floor,
    String? date,
    String? body,
  }) {
    final buffer = StringBuffer('<nga_quote');
    void writeAttr(String key, String? value) {
      final trimmed = value?.trim();
      if (trimmed != null && trimmed.isNotEmpty) {
        buffer.write(" $key='${_escapeHtmlAttribute(trimmed)}'");
      }
    }

    writeAttr('pid', pid);
    writeAttr('tid', tid);
    writeAttr('uid', uid);
    writeAttr('author', author);
    writeAttr('floor', floor);
    writeAttr('date', date);
    final bodyContent = body ?? '';
    if (bodyContent.trim().isEmpty) {
      buffer.write('></nga_quote>');
    } else {
      buffer.write('>$bodyContent</nga_quote>');
    }
    return buffer.toString();
  }
}

class _QuoteHeader {
  final Match match;
  final String? pid;
  final String? tid;
  final String? uid;
  final String? author;
  final String? floor;
  final String? date;

  const _QuoteHeader({
    required this.match,
    this.pid,
    this.tid,
    this.uid,
    this.author,
    this.floor,
    this.date,
  });
}

class _CommentParser implements Parser {
  static final _removePatterns = [
    RegExp(
      r'\[pid=(\d+)?,(\d+)?,(\d+)?\]Reply\[/pid\] \[b\]Post by \[uid(=\d+)?\]([\s\S]*?)\[/uid\] \(([\s\S]*?)\):\[/b\]',
    ),
    RegExp(
      r'\[b\]Reply to \[pid=(\d+)?,(\d+)?,(\d+)?\]Reply\[/pid\] Post by \[uid=(\d+)?\]([\s\S]*?)\[/uid\] \(([\s\S]*?)\)\[/b\]',
    ),
    RegExp(
      r'\[b\]Reply to \[tid=(\d+)?\]Topic\[/tid\] Post by \[uid(=(\d+)?)?\]([\s\S]*?)\[/uid\] \(([\s\S]*?)\)\[/b\]',
    ),
    RegExp(
      r'\[b\]Reply to \[tid=(\d+)?\]Topic\[/tid\] Post by \[uid\]([\s\S]*?)\[/uid\]\[color=gray\]\(([\s\S]*?)\)\[/color\] \(([\s\S]*?)\)\[/b\]',
    ),
  ];
  static final _trimBrRegex = RegExp(r'^(<br/>)+|(<br/>)+$');

  @override
  String parse(String? content) {
    if (content == null || content.isEmpty) return '';
    var result = content.replaceAll('[color=gray](楼)[/color]', '');
    for (final pattern in _removePatterns) {
      result = result.replaceAll(pattern, '');
    }
    return result.replaceAll(_trimBrRegex, '');
  }
}

// 优化 2: 简单标签映射表 + 复杂标签正则合并
class _ContentParser implements Parser {
  static const _ngaAttachmentBase = ngaAttachmentBase;
  final int? postDateTimestamp;

  _ContentParser({this.postDateTimestamp});

  // 简单替换（不需要捕获组的标签）。与网页版一致，标签名不区分大小写。
  static const _simpleTagReplacements = {
    '/size': '</span>',
    '/font': '</span>',
    'quote': '<blockquote>',
    '/quote': '</blockquote>',
    'stripbr': '<br/>',
  };
  static final _simpleTagRegex = RegExp(
    r'\[(/size|/font|/?quote|stripbr)\]',
    caseSensitive: false,
  );

  // 复杂标签的预编译正则（需要捕获内容的）
  /// `[img0]`、`[img-50]` 等带参数的写法（网页版的缩放 / 对齐参数）按普通
  /// 图片处理。
  static final _imgRegex = RegExp(
    r'\[img-?\d{0,3}\]([\s\S]*?)\[/img\]',
    caseSensitive: false,
  );
  static final _noImgRegex = RegExp(
    r'\[noimg\]([\s\S]*?)\[/noimg\]',
    caseSensitive: false,
  );
  static final _uidWithIdRegex = RegExp(
    r'\[uid=([^\]]+?)\]([\s\S]*?)\[/uid\]',
    caseSensitive: false,
  );
  static final _uidTextRegex = RegExp(
    r'\[uid\]([\s\S]*?)\[/uid\]',
    caseSensitive: false,
  );
  static final _pidRegex = RegExp(
    r'\[pid=(\d+)?(?:,(\d+)?)?(?:,(\d+)?)?\]([\s\S]*?)\[/pid\]',
    caseSensitive: false,
  );
  static final _tidRegex = RegExp(
    r'\[tid=(\d+)?\]([\s\S]*?)\[/tid\]',
    caseSensitive: false,
  );

  /// `[fid=7]名称[/fid]` / `[stid=7]名称[/stid]`；不带参数时内容即 ID，
  /// 文字按网页版补「版面」「合集」前缀。ID 可为负数（如网事杂谈 fid=-7）。
  static final _forumLinkRegex = RegExp(
    r'\[(fid|stid)(?:=(-?\d*))?\]([\s\S]*?)\[/\1\]',
    caseSensitive: false,
  );
  static final _signedIdRegex = RegExp(r'^-?\d+$');
  static final _atRegex = RegExp(r'\[@([^\]\r\n]+)\]');
  static final _urlWithTitleRegex = RegExp(
    r'\[url=([\s\S]*?)\]([\s\S]*?)\[/url\]',
    caseSensitive: false,
  );
  static final _urlRegex = RegExp(
    r'\[url\]([\s\S]*?)\[/url\]',
    caseSensitive: false,
  );
  static final _attachRegex = RegExp(
    r'\[attach\]([\s\S]*?)\[/attach\]',
    caseSensitive: false,
  );

  /// `[flash]` 与 `[media]` 网页版同一套处理，可带 `=video` / `=audio`。
  static final _flashRegex = RegExp(
    r'\[(flash|media)(?:=([a-z]*))?\]([\s\S]*?)\[/\1\]',
    caseSensitive: false,
  );

  /// `[iframe]` / `[iframe=高,宽]`：App 里不嵌入网页，降级成链接。
  static final _iframeRegex = RegExp(
    r'\[iframe(?:=[\d,]*)?\]([\s\S]*?)\[/iframe\]',
    caseSensitive: false,
  );
  static final _httpUrlRegex = RegExp(r'^https?://\S+$', caseSensitive: false);

  /// `[code=js]` 等带语言的写法按普通代码块显示。
  static final _codeRegex = RegExp(
    r'\[code(?:=[^\]]*)?\]([\s\S]*?)\[/code\]',
    caseSensitive: false,
  );
  static final _collapseWithTitleRegex = RegExp(
    r'\[collapse=([\s\S]*?)\]([\s\S]*?)\[/collapse\]',
    caseSensitive: false,
  );
  static final _collapseRegex = RegExp(
    r'\[collapse\]([\s\S]*?)\[/collapse\]',
    caseSensitive: false,
  );
  static final _colorRegex = RegExp(
    r'\[color=([^\]]+?)\]([\s\S]*?)\[/color\]',
    caseSensitive: false,
  );
  static final _alignRegex = RegExp(
    r'\[align=([a-z]+?)\]([\s\S]*?)\[/align\]',
    caseSensitive: false,
  );

  /// `[l]` / `[r]`：网页版输出 `display:block` 的 `.left` / `.right`（左右浮动）
  /// 块，并吞掉标签两侧各一个换行；带参数的 `[l=…]` 保留原文。fwfh 不支持
  /// 浮动，这里输出靠左 / 靠右对齐的块（不用 `<p>`，避免多出段落间距）。
  /// 只匹配内部不再含 `[l]` / `[r]` 标签的一层，由内到外处理嵌套。
  static final _lrRegex = RegExp(
    r'\s*(?:<br\s*/?>)?\s*\[(l|r)\]\s*(?:<br\s*/?>)?'
    r'((?:(?!\[/?[lr]\])[\s\S])*?)'
    r'\s*(?:<br\s*/?>)?\s*\[/\1\](?:\s*<br\s*/?>)?\s*',
    caseSensitive: false,
  );
  static final _hRegex = RegExp(r'\[h\]([\s\S]*?)\[/h\]', caseSensitive: false);
  static final _h2Regex = RegExp(r'===([^\n]*?)===');

  /// `---小标题---`（网页版 `parseTitle`）：须独占一行，即前面是行首 / 标签，
  /// 后面是行尾 / 标签；标题不能跨行，为空时是一条细分隔（同 `------`）。
  static final _dashTitleRegex = RegExp(
    r'(^|>|\]|\n)[ \t]*---((?:(?!<br\s*/?>)[^\n]){0,100}?)-{3,}[ \t]*(?=<|\[|\n|$)',
    caseSensitive: false,
  );
  static final _dashTrimRegex = RegExp(r'^-+|-+$');
  static final _sizeRegex = RegExp(r'\[size=([^\]]+)\]', caseSensitive: false);
  static final _fontRegex = RegExp(
    r'\[font=([^\[\]]+)\]',
    caseSensitive: false,
  );
  static final _formatRegex = RegExp(
    r'\[(/?(?:b|u|i|del|sup|sub))\]',
    caseSensitive: false,
  );

  /// `[upup]`：网页版加粗后再挂一个顶贴效果，这里只保留加粗。
  static final _upupRegex = RegExp(
    r'\[(/?)upup(?:[=\s][^\]]*)?\]',
    caseSensitive: false,
  );

  /// 网页版 `[color=bgxxx]` 可用的底色（文字为白色的色块）。
  static const _backgroundColors = {
    'skyblue', 'royalblue', 'blue', 'darkblue', 'orange', 'orangered', //
    'crimson', 'red', 'firebrick', 'darkred', 'green', 'limegreen', //
    'seagreen', 'teal', 'deeppink', 'tomato', 'coral', 'purple', 'indigo', //
    'burlywood', 'sandybrown', 'sienna', 'chocolate', 'silver', 'gray',
  };
  static final _namedColorRegex = RegExp(r'^[a-zA-Z]+$');
  static final _hexColorRegex = RegExp(
    r'^#(?:[0-9a-fA-F]{3}|[0-9a-fA-F]{6}|[0-9a-fA-F]{8})$',
  );
  static final _rgbColorRegex = RegExp(
    r'^rgba?\(\s*\d{1,3}\s*,\s*\d{1,3}\s*,\s*\d{1,3}(?:\s*,\s*(?:0|0?\.\d+|1(?:\.0+)?)\s*)?\)$',
    caseSensitive: false,
  );
  static final _listTokenRegex = RegExp(
    r'\[list(?:=[^\]]*)?\]|\[/list\]|\[\*\]',
    caseSensitive: false,
  );
  static final _dashRegex = RegExp(r'[-]{6,}');

  @override
  String parse(String? content) {
    if (content == null || content.isEmpty) return '';

    var result = content;

    result = result
        .replaceAll('======', '<br/><hr/>')
        .replaceAllMapped(
          _simpleTagRegex,
          (m) => _simpleTagReplacements[m.group(1)!.toLowerCase()]!,
        );
    result = _rewriteListSyntax(result);

    result = result.replaceAllMapped(_noImgRegex, _noImgReplacer);
    result = result.replaceAllMapped(_imgRegex, _imgReplacer);
    result = result.replaceAllMapped(_uidWithIdRegex, _uidWithIdReplacer);
    result = result.replaceAllMapped(_uidTextRegex, _uidTextReplacer);
    result = result.replaceAllMapped(_pidRegex, _pidReplacer);
    result = result.replaceAllMapped(_tidRegex, _tidReplacer);
    result = result.replaceAllMapped(_forumLinkRegex, _forumLinkReplacer);
    result = result.replaceAllMapped(_atRegex, _atReplacer);
    result = result.replaceAllMapped(_urlWithTitleRegex, _urlWithTitleReplacer);
    result = result.replaceAllMapped(_urlRegex, _urlReplacer);
    result = result.replaceAllMapped(_attachRegex, _attachReplacer);
    result = result.replaceAllMapped(_flashRegex, _flashReplacer);
    result = result.replaceAllMapped(_iframeRegex, _iframeReplacer);
    result = result.replaceAllMapped(_codeRegex, _codeReplacer);
    result = result.replaceAllMapped(
      _collapseWithTitleRegex,
      _collapseWithTitleReplacer,
    );
    result = result.replaceAllMapped(_collapseRegex, _collapseReplacer);
    result = result.replaceAllMapped(_colorRegex, _colorReplacer);
    result = result.replaceAllMapped(_alignRegex, _alignReplacer);
    for (var i = 0; i < 8; i++) {
      final next = result.replaceAllMapped(_lrRegex, _lrReplacer);
      if (next == result) break;
      result = next;
    }
    result = result.replaceAllMapped(_hRegex, _hReplacer);
    result = result.replaceAllMapped(_h2Regex, _h2Replacer);
    result = result.replaceAllMapped(_dashTitleRegex, _dashTitleReplacer);
    result = result.replaceAllMapped(_sizeRegex, _sizeReplacer);
    result = result.replaceAllMapped(_fontRegex, _fontReplacer);
    result = result.replaceAllMapped(_formatRegex, _formatReplacer);
    result = result.replaceAllMapped(_upupRegex, (m) => '<${m.group(1)}b>');
    result = result.replaceAllMapped(_dashRegex, _dashReplacer);

    return result;
  }

  String _imgReplacer(Match m) {
    final mediaUrl = _normalizeAttachmentUrl(m.group(1) ?? '');
    return _buildMediaElement(mediaUrl);
  }

  String _noImgReplacer(Match m) {
    final mediaUrl = _normalizeNoImgUrl(m.group(1) ?? '');
    return _buildMediaElement(mediaUrl);
  }

  static String _uidWithIdReplacer(Match m) {
    final uid = (m.group(1) ?? '').trim();
    final displayText = (m.group(2) ?? '').trim();
    if (uid.isEmpty) return displayText;
    return _buildUserLink(uid, displayText.isEmpty ? uid : displayText);
  }

  static String _uidTextReplacer(Match m) {
    final value = (m.group(1) ?? '').trim();
    if (value.isEmpty) return '';
    return _buildUserLink(value, value);
  }

  static String _pidReplacer(Match m) {
    final pid = (m.group(1) ?? '').trim();
    if (pid.isEmpty) return m.group(0) ?? '';
    final text = (m.group(4) ?? '').trim();
    final title = text.isEmpty ? 'Reply' : text;
    final href = _resolveInternalUrl('/read.php?searchpost=1&pid=$pid');
    return "<a href='${_escapeHtmlAttribute(href)}'>${_escapeHtmlText(title)}</a>";
  }

  static String _tidReplacer(Match m) {
    final tid = (m.group(1) ?? '').trim();
    if (tid.isEmpty) return m.group(0) ?? '';
    final text = (m.group(2) ?? '').trim();
    final title = text.isEmpty ? 'Topic' : text;
    final href = _resolveInternalUrl('/read.php?tid=$tid');
    return "<a href='${_escapeHtmlAttribute(href)}'>${_escapeHtmlText(title)}</a>";
  }

  static String _atReplacer(Match m) {
    final user = (m.group(1) ?? '').trim();
    if (user.isEmpty) return '';
    return _buildUserLink(user, '@$user');
  }

  static String _urlWithTitleReplacer(Match m) {
    final href = m.group(1)!;
    final text = m.group(2) ?? '';
    final normalized = _normalizeGeneralUrl(href);
    if (normalized.isEmpty) return text;
    return "<a href='${_escapeHtmlAttribute(normalized)}'>$text</a>";
  }

  static String _urlReplacer(Match m) {
    final raw = m.group(1)!;
    final url = _normalizeGeneralUrl(raw);
    if (url.isEmpty) return raw;
    return raw.startsWith('/')
        ? "<a href='${_escapeHtmlAttribute(url)}'>[站内链接]</a>"
        : "<a href='${_escapeHtmlAttribute(url)}'>${_escapeHtmlText(raw)}</a>";
  }

  String _attachReplacer(Match m) {
    final url = _normalizeAttachmentUrl(m.group(1) ?? '');
    if (url.isEmpty) return '[附件]';
    return "<a class='nga-attach' href='${_escapeHtmlAttribute(url)}'>[附件]</a>";
  }

  static String _forumLinkReplacer(Match m) {
    final tag = m.group(1)!.toLowerCase();
    final arg = m.group(2);
    final text = (m.group(3) ?? '').trim();
    final id = (arg != null && arg.isNotEmpty) ? arg : text;
    if (!_signedIdRegex.hasMatch(id)) return m.group(0)!;
    final title = arg != null && arg.isNotEmpty
        ? (text.isEmpty ? id : text)
        : '${tag == 'stid' ? '合集' : '版面'}$text';
    final href = _resolveInternalUrl('/thread.php?$tag=$id');
    return "<a href='${_escapeHtmlAttribute(href)}'>${_escapeHtmlText(title)}</a>";
  }

  /// `[flash]` / `[media]`：站内附件（`./mon_…`）按附件地址拼接，其余视为站外链接。
  static String _flashReplacer(Match m) {
    final flashType = (m.group(2) ?? '').toLowerCase();
    final raw = (m.group(3) ?? '').trim();
    final isAttachment =
        raw.startsWith('./') ||
        raw.startsWith('mon_') ||
        raw.startsWith('/attachments/');
    final url = isAttachment
        ? _normalizeAttachmentUrl(raw)
        : _normalizeGeneralUrl(raw);
    final mediaType = _resolveFlashMediaType(flashType: flashType, url: url);
    final isAudio = mediaType == _FlashMediaType.audio;
    final label = isAttachment
        ? (isAudio ? '[音频]' : '[视频]')
        : (isAudio ? '[站外音频]' : '[站外视频]');
    if (url.isEmpty) return label;
    return "<a href='${_escapeHtmlAttribute(url)}'>$label</a>";
  }

  static String _iframeReplacer(Match m) {
    final raw = (m.group(1) ?? '').trim();
    if (!_httpUrlRegex.hasMatch(raw)) return _escapeHtmlText(raw);
    final url = _normalizeGeneralUrl(raw);
    return "<a href='${_escapeHtmlAttribute(url)}'>[网页] ${_escapeHtmlText(raw)}</a>";
  }

  static String _codeReplacer(Match m) {
    final raw = (m.group(1) ?? '').replaceAll('<br/>', '\n');
    return '<pre><code>${_escapeHtmlText(raw)}</code></pre>';
  }

  static String _resolveInternalUrl(String path) {
    final baseUrl = Data().baseUrl.endsWith('/')
        ? Data().baseUrl.substring(0, Data().baseUrl.length - 1)
        : Data().baseUrl;
    return '$baseUrl$path';
  }

  static String _normalizeGeneralUrl(String raw) {
    final value = normalizeNgaImageUrl(raw.trim());
    if (value.isEmpty) return '';
    if (value.startsWith('http://')) {
      return value.replaceFirst('http://', 'https://');
    }
    if (value.startsWith('https://')) {
      return value;
    }
    if (value.startsWith('/')) {
      return _resolveInternalUrl(value);
    }
    return value;
  }

  String _normalizeNoImgUrl(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return '';
    if (value.startsWith('./mon_') ||
        value.startsWith('mon_') ||
        value.contains('/')) {
      return _normalizeAttachmentUrl(value);
    }
    final datePrefix = _buildNoImgDatePrefix(postDateTimestamp);
    if (datePrefix == null) {
      return _normalizeAttachmentUrl(value);
    }
    return '$_ngaAttachmentBase/$datePrefix$value';
  }

  static String? _buildNoImgDatePrefix(int? postDateTimestamp) {
    if (postDateTimestamp == null || postDateTimestamp <= 0) return null;
    final millis = postDateTimestamp > 1000000000000
        ? postDateTimestamp
        : postDateTimestamp * 1000;
    final utcDate = DateTime.fromMillisecondsSinceEpoch(millis, isUtc: true);
    final cstDate = utcDate.add(const Duration(hours: 8));
    final year = cstDate.year.toString().padLeft(4, '0');
    final month = cstDate.month.toString().padLeft(2, '0');
    final day = cstDate.day.toString().padLeft(2, '0');
    return 'mon_$year$month/$day/';
  }

  static String _normalizeAttachmentUrl(String raw) {
    final value = normalizeNgaImageUrl(raw.trim());
    if (value.isEmpty) return '';
    if (value.startsWith('http://')) {
      return value.replaceFirst('http://', 'https://');
    }
    if (value.startsWith('https://')) {
      return value;
    }
    if (value.startsWith('./mon_')) {
      return '$_ngaAttachmentBase${value.substring(1)}';
    }
    if (value.startsWith('mon_')) {
      return '$_ngaAttachmentBase/$value';
    }
    if (value.startsWith('/attachments/')) {
      return '$ngaImageOrigin$value';
    }
    if (value.startsWith('/')) {
      return _resolveInternalUrl(value);
    }
    return '$_ngaAttachmentBase/$value';
  }

  static String _buildMediaElement(String mediaUrl) {
    if (mediaUrl.isEmpty) return '';
    final escaped = _escapeHtmlAttribute(mediaUrl);
    if (_isVideoUrl(mediaUrl)) {
      return "<video controls src='$escaped'></video>";
    }
    return "<img src='$escaped' />";
  }

  static bool _isVideoUrl(String url) {
    final normalized = url.toLowerCase().split('#').first.split('?').first;
    return normalized.endsWith('.mp4') ||
        normalized.endsWith('.webm') ||
        normalized.endsWith('.mov') ||
        normalized.endsWith('.m4v');
  }

  static bool _isAudioUrl(String url) {
    final normalized = url.toLowerCase().split('#').first.split('?').first;
    return normalized.endsWith('.mp3') ||
        normalized.endsWith('.wav') ||
        normalized.endsWith('.aac') ||
        normalized.endsWith('.m4a') ||
        normalized.endsWith('.flac') ||
        normalized.endsWith('.ogg');
  }

  static _FlashMediaType _resolveFlashMediaType({
    String? flashType,
    required String url,
  }) {
    final normalizedType = (flashType ?? '').trim().toLowerCase();
    if (normalizedType == 'audio') return _FlashMediaType.audio;
    if (normalizedType == 'video') return _FlashMediaType.video;
    if (_isAudioUrl(url)) return _FlashMediaType.audio;
    return _FlashMediaType.video;
  }

  static String _buildUserLink(String identity, String displayText) {
    if (_isDigits(identity)) {
      final href = _resolveInternalUrl('/nuke.php?func=ucp&uid=$identity');
      return "<a href='${_escapeHtmlAttribute(href)}'>${_escapeHtmlText(displayText)}</a>";
    }
    final username = Uri.encodeQueryComponent(identity);
    final href = _resolveInternalUrl('/nuke.php?func=ucp&username=$username');
    return "<a href='${_escapeHtmlAttribute(href)}'>${_escapeHtmlText(displayText)}</a>";
  }

  static bool _isDigits(String value) {
    if (value.isEmpty) return false;
    for (final code in value.codeUnits) {
      if (code < 48 || code > 57) return false;
    }
    return true;
  }

  static String _collapseWithTitleReplacer(Match m) =>
      "<collapse title='${_escapeHtmlAttribute(m.group(1) ?? '')}'>${m.group(2) ?? ''}</collapse>";

  static String _collapseReplacer(Match m) =>
      "<collapse>${m.group(1)}</collapse>";

  static String _colorReplacer(Match m) {
    final raw = (m.group(1) ?? '').trim().toLowerCase();
    final content = m.group(2) ?? '';
    if (raw.startsWith('bg') && _backgroundColors.contains(raw.substring(2))) {
      return "<span style='background-color:${raw.substring(2)};color:white;'>$content</span>";
    }
    final colorValue = _normalizeColorValue(m.group(1) ?? '');
    if (colorValue == null) return content;
    return "<span style='color:$colorValue;'>$content</span>";
  }

  static const _supportedAligns = {'left', 'center', 'right', 'justify'};

  static String _alignReplacer(Match m) {
    final align = (m.group(1) ?? '').toLowerCase();
    final content = m.group(2) ?? '';
    if (!_supportedAligns.contains(align)) return content;
    return "<div style='text-align:$align;'>$content</div>";
  }

  static String _lrReplacer(Match m) {
    final align = m.group(1)!.toLowerCase() == 'l' ? 'left' : 'right';
    return "<div style='text-align:$align;'>${m.group(2) ?? ''}</div>";
  }

  static String _hReplacer(Match m) => '<h3>${m.group(1)}</h3>';

  static String _h2Replacer(Match m) => '<h3>${m.group(1)}</h3>';

  static String _dashTitleReplacer(Match m) {
    final title = (m.group(2) ?? '').replaceAll(_dashTrimRegex, '').trim();
    return '${m.group(1)}<h5>$title</h5>';
  }

  static String _sizeReplacer(Match m) {
    final raw = (m.group(1) ?? '').trim().toLowerCase();
    final cssValue = _normalizeFontSize(raw);
    if (cssValue == null) return '<span>';
    return "<span style='font-size:$cssValue;'>";
  }

  static String _fontReplacer(Match m) {
    final family = _resolveFontFamily(m.group(1) ?? '');
    return "<span style='font-family:$family;'>";
  }

  static String _formatReplacer(Match m) => '<${m.group(1)!.toLowerCase()}>';

  static String _dashReplacer(Match m) => '<h5></h5>';

  static String _rewriteListSyntax(String input) {
    final matches = _listTokenRegex.allMatches(input).toList();
    if (matches.isEmpty) return input;

    final output = StringBuffer();
    final listStack = <bool>[];
    var cursor = 0;

    void writeSegment(String segment) {
      if (segment.isEmpty) return;
      if (listStack.isNotEmpty &&
          !listStack.last &&
          segment.trim().isNotEmpty) {
        output.write('<li>');
        listStack[listStack.length - 1] = true;
      }
      output.write(segment);
    }

    for (final match in matches) {
      writeSegment(input.substring(cursor, match.start));
      final token = (match.group(0) ?? '').toLowerCase();

      if (token.startsWith('[list')) {
        if (listStack.isNotEmpty && !listStack.last) {
          output.write('<li>');
          listStack[listStack.length - 1] = true;
        }
        output.write('<ul>');
        listStack.add(false);
      } else if (token == '[*]') {
        if (listStack.isEmpty) {
          output.write('[*]');
        } else {
          if (listStack.last) output.write('</li>');
          output.write('<li>');
          listStack[listStack.length - 1] = true;
        }
      } else {
        if (listStack.isEmpty) {
          output.write('[/list]');
        } else {
          if (listStack.last) output.write('</li>');
          output.write('</ul>');
          listStack.removeLast();
        }
      }
      cursor = match.end;
    }

    writeSegment(input.substring(cursor));

    while (listStack.isNotEmpty) {
      if (listStack.last) output.write('</li>');
      output.write('</ul>');
      listStack.removeLast();
    }

    return output.toString();
  }

  static String? _normalizeColorValue(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return null;
    if (_namedColorRegex.hasMatch(value)) return value.toLowerCase();
    if (_hexColorRegex.hasMatch(value)) return value;
    if (_rgbColorRegex.hasMatch(value)) return value;
    return null;
  }

  static String? _normalizeFontSize(String raw) {
    if (raw.isEmpty) return null;
    if (raw.endsWith('%')) {
      final number = int.tryParse(raw.substring(0, raw.length - 1).trim());
      if (number == null || number <= 0) return null;
      return '${number.clamp(1, 400)}%';
    }
    if (raw.endsWith('px')) {
      final number = int.tryParse(raw.substring(0, raw.length - 2).trim());
      if (number == null || number <= 0) return null;
      return '${number.clamp(8, 64)}px';
    }
    final number = int.tryParse(raw);
    if (number == null || number <= 0) return null;
    return '${number.clamp(8, 64)}px';
  }

  static String _resolveFontFamily(String raw) {
    final value = raw.trim().toLowerCase();
    if (value.contains('mono') || value.contains('courier')) {
      return 'monospace';
    }
    if (value.contains('song') ||
        value.contains('simsun') ||
        value.contains('times') ||
        value.contains('georgia') ||
        value.contains('宋体')) {
      return 'Times New Roman, SimSun, serif';
    }
    if (value.contains('kai') || value.contains('楷体')) {
      return 'Kaiti SC, STKaiti, serif';
    }
    if (value.contains('hei') ||
        value.contains('yahei') ||
        value.contains('arial') ||
        value.contains('verdana') ||
        value.contains('tahoma') ||
        value.contains('黑体') ||
        value.contains('微软雅黑')) {
      return 'PingFang SC, Microsoft YaHei, Arial, sans-serif';
    }
    return 'PingFang SC, Microsoft YaHei, sans-serif';
  }
}

enum _FlashMediaType { audio, video }

class _DiceParser implements Parser {
  static final _diceRegex = RegExp(
    r'\[dice\](.*?)\[/dice\]',
    caseSensitive: false,
  );

  final int authorId;
  final int tid;
  final int pid;

  _DiceParser({required this.authorId, required this.tid, required this.pid});

  @override
  String parse(String? content) {
    if (content == null || content.isEmpty) return '';
    final context = DiceContext(authorId: authorId, topicId: tid, postId: pid);
    return content.replaceAllMapped(_diceRegex, (m) {
      final expr = m.group(1) ?? '';
      final result = DiceRoller.roll(expr, context);
      return "<span style='background-color:rgba(0,122,255,0.15);"
          "font-family:monospace;padding:2px 6px;border-radius:4px;'>"
          "&#x1F3B2; ${result.original} &#x2192; ${result.total}</span>";
    });
  }
}

class _EmoticonParser implements Parser {
  static EmoticonLookup? _lookup;

  EmoticonLookup? _ensureLookup() {
    if (_lookup != null) return _lookup;
    final groups = _loadGroupsSafely();
    if (groups == null) return null;
    return _lookup = EmoticonLookup(groups);
  }

  List<EmoticonGroup>? _loadGroupsSafely() {
    try {
      return Data().emoticonRepository.getEmoticonGroups();
    } catch (_) {
      return null;
    }
  }

  @override
  String parse(String? content) {
    if (content == null || content.isEmpty) return '';
    return _ensureLookup()?.replace(content) ?? content;
  }
}

/// 把 `[s:...]` 表情代码替换为 `<nga_emoticon>`，规则对齐网页版
/// `js_bbscode_core.js`：匹配 `[s:内容]`（内容 1～10 个字符），按 `:` 拆成
/// 「分组代码:表情名」；没有 `:` 或分组代码为空（如 `[s::37]`）时属于默认分组。
/// 找不到的表情保留原文。
@visibleForTesting
class EmoticonLookup {
  EmoticonLookup(List<EmoticonGroup> groups) {
    for (final group in groups) {
      for (final emoticon in group.expressionList) {
        final body = emoticon.content.substring(3, emoticon.content.length - 1);
        final (code, name) = _split(body);
        (_htmlByGroup[code] ??= {})[name] =
            "<nga_emoticon src='${emoticon.url}' "
            "height='${emoticon.height.round()}' "
            "descent='${emoticon.descent.round()}'></nga_emoticon>";
      }
    }
  }

  static final _tagRegex = RegExp(r'\[s:(.{1,10}?)\]');

  /// 分组代码（默认分组为空串）→ 表情名 → HTML。
  final _htmlByGroup = <String, Map<String, String>>{};

  String replace(String content) => content.replaceAllMapped(_tagRegex, (m) {
    final (code, name) = _split(m[1]!);
    return _htmlByGroup[code]?[name] ?? m[0]!;
  });

  static (String, String) _split(String body) {
    final parts = body.split(':');
    return parts.length == 1 ? ('', body) : (parts[0], parts[1]);
  }
}

class _DictionaryParser implements Parser {
  static final _dictionaryRegex = RegExp(
    r'\[dict\]\[([^\]\r\n]+)\]([\s\S]*?)\[/dict\]',
    caseSensitive: false,
  );

  @override
  String parse(String? content) {
    if (content == null || content.isEmpty) return '';

    final matches = _dictionaryRegex.allMatches(content).toList();
    if (matches.isEmpty) return content;

    final definitions = <String, String>{};
    for (final match in matches) {
      final term = (match.group(1) ?? '').trim();
      final definition = (match.group(2) ?? '').trim();
      if (term.isNotEmpty && definition.isNotEmpty) {
        definitions.putIfAbsent(term, () => definition);
      }
    }

    return content.replaceAllMapped(_dictionaryRegex, (match) {
      final term = (match.group(1) ?? '').trim();
      if (term.isEmpty) return '';

      final definition = definitions[term];
      if (definition == null) return _escapeHtmlText(term);

      return "<nga_dict term='${_escapeHtmlAttribute(term)}' "
          "definition='${_escapeDictionaryDefinition(definition)}'>"
          "${_escapeHtmlText(term)}</nga_dict>";
    });
  }
}

class _UnsupportedTagFallbackParser implements Parser {
  static final _ubbTagRegex = RegExp(
    r'\[/?([a-zA-Z_][a-zA-Z0-9_]*)(?:[^\]]*)\]',
  );
  static const _knownTags = <String>{
    'album',
    'align',
    'attach',
    'b',
    'code',
    'collapse',
    'color',
    'crypt',
    'del',
    'dice',
    'dict',
    'fid',
    'flash',
    'font',
    'h',
    'headline',
    'hltxt',
    'i',
    'iframe',
    'img',
    'l',
    'lessernuke',
    'list',
    'media',
    'noimg',
    'pid',
    'quote',
    'r',
    'randomblock',
    'size',
    'stid',
    'sub',
    'sup',
    'table',
    'tbody',
    'td',
    'tid',
    'tr',
    'u',
    'uid',
    'upup',
    'url',
  };

  /// 带数字后缀的已知标签：`[td20]`、`[img0]`、`[lessernuke1]`。
  static final _numberedTagRegex = RegExp(r'^(?:td|img|lessernuke)\d+$');

  @override
  String parse(String? content) {
    if (content == null || content.isEmpty) return '';
    return content.replaceAllMapped(_ubbTagRegex, (match) {
      final rawTag = match.group(0) ?? '';
      final tag = (match.group(1) ?? '').toLowerCase();
      if (_knownTags.contains(tag) || _numberedTagRegex.hasMatch(tag)) {
        return rawTag;
      }
      return "<span class='ubb-unknown'>${_escapeHtmlText(rawTag)}</span>";
    });
  }
}

String _escapeHtmlText(String text) {
  return text
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;')
      .replaceAll("'", '&#39;');
}

String _escapeHtmlAttribute(String text) => _escapeHtmlText(text);

String _escapeDictionaryDefinition(String text) {
  return _escapeHtmlAttribute(text)
      .replaceAll('[', '&#91;')
      .replaceAll(']', '&#93;');
}
