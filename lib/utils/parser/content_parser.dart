import 'dart:math';

import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/data/entity/emoticon.dart';
import 'package:flutter_nga/utils/code_utils.dart' as code_utils;
import 'package:flutter_nga/utils/dice_roller.dart';
import 'package:flutter_nga/utils/name_utils.dart';

class NgaContentParser {
  static final Parser _replyParser = _ReplyParser();
  static final Parser _commentParser = _CommentParser();
  static final Parser _randomBlockParser = _RandomBlockParser();
  static final Parser _albumParser = _AlbumParser();
  static final Parser _tableParser = _TableParser();
  static final Parser _emoticonParser = _EmoticonParser();
  static final Parser _dictionaryParser = _DictionaryParser();
  static final Parser _fallbackParser = _UnsupportedTagFallbackParser();

  // 优化 3: LRU 缓存（最多缓存 256 条）
  static final _parseCache = <String, String>{};
  static final _cacheKeys = <String>[];
  static const _maxCacheSize = 256;

  /// 与官网一致：缓存每层正文前 250 字（去掉引用头），供 Reply to 补原文
  static const quoteSnippetMaxLength = 250;

  static final _quoteBlockRegex =
      RegExp(r'\[quote\][\s\S]*?\[/quote\]', caseSensitive: false);
  static final _replyToLineRegex = RegExp(
      r'^\[b\]Reply to \[pid=\d+,\d+,\d+\]Reply\[/pid\] Post by .+?\[/b\]\s*',
      caseSensitive: false);
  // Reply to → 展开为 [quote]…[/quote]（官网 contentQuoteCache 逻辑）
  static final _expandReplyToPidRegex = RegExp(
      r'\[b\]Reply to \[pid=(\d+),(\d+)?,(\d+)?\]Reply\[/pid\] Post by (\[uid(?:=\d+)?\][\s\S]*?\[/uid\](?:\[color=gray\]\([\s\S]*?\)\[/color\])? \([\s\S]*?\))\[/b\]',
      caseSensitive: false);

  static List<Parser> _buildParserList({int? postDateTimestamp}) {
    return [
      _randomBlockParser,
      _albumParser,
      _tableParser,
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

    var parseContent = code_utils.unescapeHtml(content);
    // 官网：Reply to 用同页 pid 缓存补原文，再当 quote 渲染
    if (quoteBodyByPid != null && quoteBodyByPid.isNotEmpty) {
      parseContent = expandReplyToWithCachedBody(parseContent, quoteBodyByPid);
    }
    parseContent = _replyParser.parse(parseContent);
    if (authorId != null && tid != null && pid != null) {
      parseContent = _DiceParser(authorId: authorId, tid: tid, pid: pid)
          .parse(parseContent);
    }
    for (final parser
        in _buildParserList(postDateTimestamp: postDateTimestamp)) {
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

    var parseContent = code_utils.unescapeHtml(content);
    parseContent = _commentParser.parse(parseContent);
    if (authorId != null && tid != null && pid != null) {
      parseContent = _DiceParser(authorId: authorId, tid: tid, pid: pid)
          .parse(parseContent);
    }
    for (final parser
        in _buildParserList(postDateTimestamp: postDateTimestamp)) {
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

    final selectedIndex =
        matches.length == 1 ? 0 : _random.nextInt(matches.length);
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

// 优化 1: 预编译正则
class _AlbumParser implements Parser {
  static final _albumRegex =
      RegExp(r'\[album(=([\s\S]*?)?)?\]([\s\S]*?)?\[/album\]');
  static final _urlRegex =
      RegExp(r'\[url\]([\s\S]*?)?\[/url\]', caseSensitive: false);

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

class _TableParser implements Parser {
  static final _tableOpenRegex = RegExp(r'\[table\]', caseSensitive: false);
  static final _tableCloseRegex = RegExp(r'\[/table\]', caseSensitive: false);
  static final _trRegex = RegExp(r'\[([/]?tr)\]', caseSensitive: false);
  static final _tdOpenRegex = RegExp(r'\[td([^\]]*)\]', caseSensitive: false);
  static final _tdCloseRegex = RegExp(r'\[/td\]', caseSensitive: false);
  static final _tdWidthRegex = RegExp(r'^\s*(\d{1,3})\b');
  static final _tdSpanAttrRegex =
      RegExp(r'(rowspan|colspan)\s*=\s*(\d+)', caseSensitive: false);
  static final _tagBrRegex = RegExp(r'<([/]?(table|tbody|tr|td))><br/>');
  static final _brTagRegex = RegExp(r'[ ]?<br/><([/]?(table|tbody|tr|td))>');

  @override
  String parse(String? content) {
    if (content == null || content.isEmpty) return '';
    return content
        .replaceAllMapped(_tableOpenRegex, (_) => '<div><table><tbody>')
        .replaceAllMapped(_tableCloseRegex, (_) => '</tbody></table></div>')
        .replaceAllMapped(
            _trRegex, (match) => '<${match.group(1)!.toLowerCase()}>')
        .replaceAllMapped(_tdOpenRegex, _tdOpenReplacer)
        .replaceAllMapped(_tdCloseRegex, (_) => '</td>')
        .replaceAllMapped(_tagBrRegex, (match) => '<${match.group(1)}>')
        .replaceAllMapped(_brTagRegex, (match) => '<${match.group(1)}>')
        .replaceAll('</table>', '</table><br/><br/>');
  }

  static String _tdOpenReplacer(Match match) {
    final raw = (match.group(1) ?? '').trim();
    if (raw.isEmpty) return '<td>';

    var rest = raw;
    int? widthPercent;
    final widthMatch = _tdWidthRegex.firstMatch(raw);
    if (widthMatch != null) {
      widthPercent = int.tryParse(widthMatch.group(1)!);
      rest = raw.substring(widthMatch.end).trim();
    }

    final attrs = <String, String>{};
    for (final spanMatch in _tdSpanAttrRegex.allMatches(rest)) {
      final key = spanMatch.group(1)!.toLowerCase();
      final value = spanMatch.group(2)!;
      if (int.tryParse(value) != null) {
        attrs[key] = value;
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

class _ReplyParser implements Parser {
  /// 最内层 [quote]…[/quote]（内容中不再含 [quote]），用于嵌套由内到外折叠
  static final _innermostQuoteRegex =
      RegExp(r'\[quote\]((?:(?!\[quote\])[\s\S])*?)\[/quote\]');

  /// 引用块开头可能的空白 / <br>
  static final _leadingBreaksRegex = RegExp(r'^(?:\s|<br\s*/?>)*');

  // 引用头：匹配「引用」类（带原文 body，通常包在 [quote] 内）
  static final _topicRegex = RegExp(
      r'\[tid=(\d+)?\]Topic\[/tid\] \[b\]Post by \[uid=(\d+)?\]([\s\S]*?)\[/uid\] \(([\s\S]*?)\):\[/b\]');
  static final _replyRegex = RegExp(
      r'\[pid=(\d+)?,(\d+)?,(\d+)?\]Reply\[/pid\] \[b\]Post by \[uid=(\d+)?\]([\s\S]*?)\[/uid\] \(([\s\S]*?)\):\[/b\]');
  static final _anonyRegex = RegExp(
      r'\[pid=(\d+)?,(\d+)?,(\d+)?\]Reply\[/pid\] \[b\]Post by \[uid\]#anony_([0-9a-zA-Z]*)\[/uid\]\[color=gray\]\((\d+)?楼\)\[/color\] \(([\s\S]*?)\):\[/b\]');
  // 引用头：「回复」类（通常无原文，仅指向原帖）
  static final _replyTopicRegex = RegExp(
      r'\[b\]Reply to \[tid=(\d+)?\]Topic\[/tid\] Post by \[uid=(\d+)?\]([\s\S]*?)\[/uid\] \(([\s\S]*?)\)\[/b\]');
  static final _replyPostRegex = RegExp(
      r'\[b\]Reply to \[pid=(\d+)?,(\d+)?,(\d+)?\]Reply\[/pid\] Post by \[uid=(\d+)?\]([\s\S]*?)\[/uid\] \(([\s\S]*?)\)\[/b\]');
  static final _anonyReplyTopicRegex = RegExp(
      r'\[b\]Reply to \[tid=(\d+)?\]Topic\[/tid\] Post by \[uid\]#anony_([0-9a-zA-Z]*)\[/uid\]\[color=gray\]\((\d+)?楼\)\[/color\] \(([\s\S]*?)\)\[/b\]');
  static final _anonyReplyPostRegex = RegExp(
      r'\[b\]Reply to \[pid=(\d+)?,(\d+)?,(\d+)?\]Reply\[/pid\] Post by \[uid\]#anony_([0-9a-zA-Z]*)\[/uid\]\[color=gray\]\((\d+)?楼\)\[/color\] \(([\s\S]*?)\)\[/b\]');

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
                date: m.group(4)))
        .replaceAllMapped(
            _replyRegex,
            (m) => _buildQuoteTag(
                pid: m.group(1),
                uid: m.group(4),
                author: m.group(5),
                date: m.group(6)))
        .replaceAllMapped(
            _anonyRegex,
            (m) => _buildQuoteTag(
                pid: m.group(1),
                author: getShowName("#anony_${m.group(4)}"),
                floor: "${m.group(5)}楼",
                date: m.group(6)))
        .replaceAllMapped(
            _replyTopicRegex,
            (m) => _buildQuoteTag(
                tid: m.group(1),
                uid: m.group(2),
                author: m.group(3),
                date: m.group(4)))
        .replaceAllMapped(
            _replyPostRegex,
            (m) => _buildQuoteTag(
                pid: m.group(1),
                uid: m.group(4),
                author: m.group(5),
                date: m.group(6)))
        .replaceAllMapped(
            _anonyReplyTopicRegex,
            (m) => _buildQuoteTag(
                tid: m.group(1),
                author: getShowName("#anony_${m.group(2)}"),
                floor: "${m.group(3)}楼",
                date: m.group(4)))
        .replaceAllMapped(
            _anonyReplyPostRegex,
            (m) => _buildQuoteTag(
                pid: m.group(1),
                author: getShowName("#anony_${m.group(4)}"),
                floor: "${m.group(5)}楼",
                date: m.group(6)));
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
        r'\[pid=(\d+)?,(\d+)?,(\d+)?\]Reply\[/pid\] \[b\]Post by \[uid(=\d+)?\]([\s\S]*?)\[/uid\] \(([\s\S]*?)\):\[/b\]'),
    RegExp(
        r'\[b\]Reply to \[pid=(\d+)?,(\d+)?,(\d+)?\]Reply\[/pid\] Post by \[uid=(\d+)?\]([\s\S]*?)\[/uid\] \(([\s\S]*?)\)\[/b\]'),
    RegExp(
        r'\[b\]Reply to \[tid=(\d+)?\]Topic\[/tid\] Post by \[uid(=(\d+)?)?\]([\s\S]*?)\[/uid\] \(([\s\S]*?)\)\[/b\]'),
    RegExp(
        r'\[b\]Reply to \[tid=(\d+)?\]Topic\[/tid\] Post by \[uid\]([\s\S]*?)\[/uid\]\[color=gray\]\(([\s\S]*?)\)\[/color\] \(([\s\S]*?)\)\[/b\]'),
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
  static const _ngaAttachmentBase = 'https://img.nga.178.com/attachments';
  final int? postDateTimestamp;

  _ContentParser({this.postDateTimestamp});

  // 简单替换映射表（不需要捕获组的标签）
  static const _simpleReplacements = {
    '[/size]': '</span>',
    '[/font]': '</span>',
    '[quote]': '<blockquote>',
    '[/quote]': '</blockquote>',
    '======': '<br/><nga_hr></nga_hr>',
    '[stripbr]': '<br/>',
  };

  // 复杂标签的预编译正则（需要捕获内容的）
  static final _imgRegex = RegExp(r'\[img\]([\s\S]*?)\[/img\]');
  static final _noImgRegex = RegExp(r'\[noimg\]([\s\S]*?)\[/noimg\]');
  static final _uidWithIdRegex = RegExp(r'\[uid=([^\]]+?)\]([\s\S]*?)\[/uid\]');
  static final _uidTextRegex = RegExp(r'\[uid\]([\s\S]*?)\[/uid\]');
  static final _pidRegex =
      RegExp(r'\[pid=(\d+)?(?:,(\d+)?)?(?:,(\d+)?)?\]([\s\S]*?)\[/pid\]');
  static final _tidRegex = RegExp(r'\[tid=(\d+)?\]([\s\S]*?)\[/tid\]');
  static final _atRegex = RegExp(r'\[@([^\]\r\n]+)\]');
  static final _urlWithTitleRegex =
      RegExp(r'\[url=([\s\S]*?)\]([\s\S]*?)\[/url\]');
  static final _urlRegex = RegExp(r'\[url\]([\s\S]*?)\[/url\]');
  static final _attachRegex = RegExp(r'\[attach\]([\s\S]*?)\[/attach\]');
  static final _flashWithTypeRegex =
      RegExp(r'\[flash=([a-z]+?)\]([\s\S]*?)\[/flash\]', caseSensitive: false);
  static final _flashRegex = RegExp(r'\[flash\]([\s\S]*?)\[/flash\]');
  static final _codeRegex = RegExp(r'\[code\]([\s\S]*?)\[/code\]');
  static final _collapseWithTitleRegex =
      RegExp(r'\[collapse=([\s\S]*?)\]([\s\S]*?)\[/collapse\]');
  static final _collapseRegex = RegExp(r'\[collapse\]([\s\S]*?)\[/collapse\]');
  static final _colorRegex =
      RegExp(r'\[color=([^\]]+?)\]([\s\S]*?)\[/color\]', caseSensitive: false);
  static final _alignRegex = RegExp(r'\[align=([a-z]+?)\]([\s\S]*?)\[/align\]');
  static final _lrRegex = RegExp(r'\[(l|r)\]([\s\S]*?)\[/\1\]');
  static final _hRegex = RegExp(r'\[h\]([\s\S]*?)\[/h\]');
  static final _h2Regex = RegExp(r'===([^\n]*?)===');
  static final _sizeRegex = RegExp(r'\[size=([^\]]+)\]', caseSensitive: false);
  static final _fontRegex =
      RegExp(r'\[font=([^\[\]]+)\]', caseSensitive: false);
  static final _formatRegex = RegExp(r'\[([/]?(?:b|u|i|del))\]');
  static final _namedColorRegex = RegExp(r'^[a-zA-Z]+$');
  static final _hexColorRegex =
      RegExp(r'^#(?:[0-9a-fA-F]{3}|[0-9a-fA-F]{6}|[0-9a-fA-F]{8})$');
  static final _rgbColorRegex = RegExp(
      r'^rgba?\(\s*\d{1,3}\s*,\s*\d{1,3}\s*,\s*\d{1,3}(?:\s*,\s*(?:0|0?\.\d+|1(?:\.0+)?)\s*)?\)$',
      caseSensitive: false);
  static final _listTokenRegex =
      RegExp(r'\[list(?:=[^\]]*)?\]|\[/list\]|\[\*\]', caseSensitive: false);
  static final _dashRegex = RegExp(r'[-]{6,}');

  @override
  String parse(String? content) {
    if (content == null || content.isEmpty) return '';

    var result = content;

    // 先执行简单替换（字符串查找比正则快）
    _simpleReplacements.forEach((key, value) {
      result = result.replaceAll(key, value);
    });
    result = _rewriteListSyntax(result);

    result = result.replaceAllMapped(_noImgRegex, _noImgReplacer);
    result = result.replaceAllMapped(_imgRegex, _imgReplacer);
    result = result.replaceAllMapped(_uidWithIdRegex, _uidWithIdReplacer);
    result = result.replaceAllMapped(_uidTextRegex, _uidTextReplacer);
    result = result.replaceAllMapped(_pidRegex, _pidReplacer);
    result = result.replaceAllMapped(_tidRegex, _tidReplacer);
    result = result.replaceAllMapped(_atRegex, _atReplacer);
    result = result.replaceAllMapped(_urlWithTitleRegex, _urlWithTitleReplacer);
    result = result.replaceAllMapped(_urlRegex, _urlReplacer);
    result = result.replaceAllMapped(_attachRegex, _attachReplacer);
    result =
        result.replaceAllMapped(_flashWithTypeRegex, _flashWithTypeReplacer);
    result = result.replaceAllMapped(_flashRegex, _flashReplacer);
    result = result.replaceAllMapped(_codeRegex, _codeReplacer);
    result = result.replaceAllMapped(
        _collapseWithTitleRegex, _collapseWithTitleReplacer);
    result = result.replaceAllMapped(_collapseRegex, _collapseReplacer);
    result = result.replaceAllMapped(_colorRegex, _colorReplacer);
    result = result.replaceAllMapped(_alignRegex, _alignReplacer);
    result = result.replaceAllMapped(_lrRegex, _lrReplacer);
    result = result.replaceAllMapped(_hRegex, _hReplacer);
    result = result.replaceAllMapped(_h2Regex, _h2Replacer);
    result = result.replaceAllMapped(_sizeRegex, _sizeReplacer);
    result = result.replaceAllMapped(_fontRegex, _fontReplacer);
    result = result.replaceAllMapped(_formatRegex, _formatReplacer);
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

  static String _flashWithTypeReplacer(Match m) {
    final flashType = (m.group(1) ?? '').toLowerCase();
    final raw = m.group(2) ?? '';
    final url = _normalizeGeneralUrl(raw);
    final mediaType = _resolveFlashMediaType(flashType: flashType, url: url);
    final label = mediaType == _FlashMediaType.audio ? '[站外音频]' : '[站外视频]';
    if (url.isEmpty) return label;
    return "<a href='${_escapeHtmlAttribute(url)}'>$label</a>";
  }

  static String _flashReplacer(Match m) {
    final raw = m.group(1) ?? '';
    final url = _normalizeGeneralUrl(raw);
    final mediaType = _resolveFlashMediaType(url: url);
    final label = mediaType == _FlashMediaType.audio ? '[站外音频]' : '[站外视频]';
    if (url.isEmpty) return label;
    return "<a href='${_escapeHtmlAttribute(url)}'>$label</a>";
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
    final value = raw.trim();
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
    final value = raw.trim();
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
      return 'https://img.nga.178.com$value';
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
    final colorValue = _normalizeColorValue(m.group(1) ?? '');
    final content = m.group(2) ?? '';
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
    final align = m.group(1) == 'l' ? 'left' : 'right';
    return "<p style='text-align:$align'>${m.group(2) ?? ''}</p>";
  }

  static String _hReplacer(Match m) => '<h3>${m.group(1)}</h3>';

  static String _h2Replacer(Match m) => '<h3>${m.group(1)}</h3>';

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

  static String _formatReplacer(Match m) => '<${m.group(1)}>';

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

enum _FlashMediaType {
  audio,
  video,
}

class _DiceParser implements Parser {
  static final _diceRegex =
      RegExp(r'\[dice\](.*?)\[/dice\]', caseSensitive: false);

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

// 优化 4: 表情解析优化（构建映射表）
class _EmoticonParser implements Parser {
  static final _emoticonMap = <String, String>{};
  static bool _initialized = false;

  void _ensureInitialized() {
    if (_initialized) return;
    final list = _loadGroupsSafely();
    if (list == null) return;
    for (final group in list) {
      for (final emoticon in group.expressionList) {
        _emoticonMap[emoticon.content] =
            "<nga_emoticon src='${emoticon.url}'></nga_emoticon>";
      }
    }
    _initialized = true;
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
    _ensureInitialized();

    if (_emoticonMap.isEmpty) return content;

    // 单次遍历替换所有表情
    var result = content;
    for (final entry in _emoticonMap.entries) {
      result = result.replaceAll(entry.key, entry.value);
    }
    return result;
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
  static final _ubbTagRegex =
      RegExp(r'\[/?([a-zA-Z_][a-zA-Z0-9_]*)(?:[^\]]*)\]');
  static const _knownTags = <String>{
    'album',
    'align',
    'attach',
    'b',
    'code',
    'collapse',
    'color',
    'del',
    'dice',
    'dict',
    'flash',
    'font',
    'h',
    'i',
    'img',
    'l',
    'list',
    'noimg',
    'pid',
    'quote',
    'r',
    'randomblock',
    'size',
    'table',
    'tbody',
    'td',
    'tid',
    'tr',
    'u',
    'uid',
    'url',
  };

  @override
  String parse(String? content) {
    if (content == null || content.isEmpty) return '';
    return content.replaceAllMapped(_ubbTagRegex, (match) {
      final rawTag = match.group(0) ?? '';
      final tag = (match.group(1) ?? '').toLowerCase();
      if (_knownTags.contains(tag) ||
          (tag.startsWith('td') && int.tryParse(tag.substring(2)) != null)) {
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
