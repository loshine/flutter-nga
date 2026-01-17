import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/utils/code_utils.dart' as code_utils;
import 'package:flutter_nga/utils/constant.dart';
import 'package:flutter_nga/utils/name_utils.dart';

class NgaContentParser {
  static final List<Parser> _parserList = [
    _AlbumParser(),
    _TableParser(),
    _ContentParser(),
    _EmoticonParser(),
  ];

  static final Parser _replyParser = _ReplyParser();
  static final Parser _commentParser = _CommentParser();

  // 优化 3: LRU 缓存（最多缓存 256 条）
  static final _parseCache = <String, String>{};
  static final _cacheKeys = <String>[];
  static const _maxCacheSize = 256;

  static String parse(String? content) {
    if (content == null || content.isEmpty) return '';

    // 缓存命中
    if (_parseCache.containsKey(content)) {
      return _parseCache[content]!;
    }

    var parseContent = code_utils.unescapeHtml(content);
    parseContent = _replyParser.parse(parseContent);
    for (final parser in _parserList) {
      parseContent = parser.parse(parseContent);
    }

    // 写入缓存（LRU 淘汰）
    _cacheKeys.add(content);
    _parseCache[content] = parseContent;
    if (_cacheKeys.length > _maxCacheSize) {
      _parseCache.remove(_cacheKeys.removeAt(0));
    }

    return parseContent;
  }

  static String parseComment(String? content) {
    if (content == null || content.isEmpty) return '';

    final cacheKey = '__comment__$content';
    if (_parseCache.containsKey(cacheKey)) {
      return _parseCache[cacheKey]!;
    }

    var parseContent = code_utils.unescapeHtml(content);
    parseContent = _commentParser.parse(parseContent);
    for (final parser in _parserList) {
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

// 优化 1: 预编译正则
class _AlbumParser implements Parser {
  static final _albumRegex = RegExp(r'\[album(=([\s\S]*?)?)?\]([\s\S]*?)?\[/album\]');
  static final _urlRegex = RegExp(r'\[url\]([\s\S]*?)?\[/url\]');

  @override
  String parse(String? content) {
    if (content == null || content.isEmpty) return '';
    return content.replaceAllMapped(_albumRegex, (match) {
      final value = (match.group(3) ?? '').replaceAllMapped(
          _urlRegex, (m) => "<img src='${m.group(1)}'/>",
      );
      return "<album>${match.group(1) != null ? match.group(2) : "相册"}$value</album>";
    });
  }
}

class _TableParser implements Parser {
  static final _trTdRegex = RegExp(r'\[([/]?(tr|td))\]');
  static final _tdNumRegex = RegExp(r'\[td([\d]{1,3})+\]');
  static final _tdSpanRegex = RegExp(r'\[td (rowspan|colspan)=([\d]+?)\]');
  static final _tdDoubleSpanRegex = RegExp(r'\[td (rowspan|colspan)=([\d]+?) (rowspan|colspan)=([\d]+?)\]');
  static final _tagBrRegex = RegExp(r'<([/]?(table|tbody|tr|td))><br/>');
  static final _brTagRegex = RegExp(r'[ ]?<br/><[/]?(table|tbody|tr|td)>');

  @override
  String parse(String? content) {
    if (content == null || content.isEmpty) return '';
    return content
        .replaceAllMapped(_trTdRegex, (match) => '<${match.group(1)}>')
        .replaceAll('[table]', '<div><table><tbody>')
        .replaceAll('[/table]', '</tbody></table></div>')
        .replaceAllMapped(_tdNumRegex, (match) => "<td style='width:${match.group(1)}%;'>")
        .replaceAllMapped(_tdSpanRegex, (match) => "<td ${match.group(1)}='${match.group(2)}'")
        .replaceAllMapped(_tdDoubleSpanRegex, (match) =>
            "<td ${match.group(1)}='${match.group(2)}' ${match.group(3)}='${match.group(4)}'")
        .replaceAllMapped(_tagBrRegex, (match) => '<${match.group(1)}>')
        .replaceAllMapped(_brTagRegex, (match) => '<${match.group(1)}>')
        .replaceAll('</table>', '</table><br/><br/>');
  }
}

class _ReplyParser implements Parser {
  static final _topicRegex = RegExp(
      r'\[tid=(\d+)?\]Topic\[/tid\] \[b\]Post by \[uid=(\d+)?\]([\s\S]*?)\[/uid\] \(([\s\S]*?)\):\[/b\]');
  static final _replyRegex = RegExp(
      r'\[pid=(\d+)?,(\d+)?,(\d+)?\]Reply\[/pid\] \[b\]Post by \[uid=(\d+)?\]([\s\S]*?)\[/uid\] \(([\s\S]*?)\):\[/b\]');
  static final _anonyRegex = RegExp(
      r'\[pid=(\d+)?,(\d+)?,(\d+)?\]Reply\[/pid\] \[b\]Post by \[uid\]#anony_([0-9a-zA-Z]*)\[/uid\]\[color=gray\]\((\d+)?楼\)\[/color\] \(([\s\S]*?)\):\[/b\]');
  static final _replyTopicRegex = RegExp(
      r'\[b\]Reply to \[tid=(\d+)?\]Topic\[/tid\] Post by \[uid=(\d+)?\]([\s\S]*?)\[/uid\] \(([\s\S]*?)\)\[/b\]');
  static final _replyPostRegex = RegExp(
      r'\[b\]Reply to \[pid=(\d+)?,(\d+)?,(\d+)?\]Reply\[/pid\] Post by \[uid=(\d+)?\]([\s\S]*?)\[/uid\] \(([\s\S]*?)\)\[/b\]');

  @override
  String parse(String? content) {
    if (content == null || content.isEmpty) return '';
    return content
        .replaceAllMapped(_topicRegex, (m) =>
            "<a href='${DOMAIN}read.php?tid=${m.group(1)}'>Topic</a> Post by <a href='${DOMAIN}nuke.php?func=ucp&uid=${m.group(2)}'>[${m.group(3)}]</a> <small>(${m.group(4)})</small>")
        .replaceAllMapped(_replyRegex, (m) =>
            "<a href='${DOMAIN}read.php?searchpost=1&pid=${m.group(1)}'>Reply</a> Post by <a href='${DOMAIN}nuke.php?func=ucp&uid=${m.group(4)}'>[${m.group(5)}]</a> <small>(${m.group(6)})</small>:")
        .replaceAllMapped(_anonyRegex, (m) =>
            "<a href='${DOMAIN}read.php?searchpost=1&pid=${m.group(1)}'>Reply</a> Post by ${getShowName("#anony_${m.group(4)}")}</a><font color='gray'>(${m.group(5)}楼)</font> <small>(${m.group(6)})</small>:")
        .replaceAllMapped(_replyTopicRegex, (m) =>
            "Reply to <a href='${DOMAIN}read.php?searchpost=1&pid=${m.group(1)}'>Topic</a> Post by ${m.group(2)} ${m.group(3)}")
        .replaceAllMapped(_replyPostRegex, (m) =>
            "Reply to <a href='${DOMAIN}read.php?searchpost=1&pid=${m.group(1)}'>Post</a> by ${m.group(5)} ${m.group(6)}");
  }
}

class _CommentParser implements Parser {
  static final _removePatterns = [
    RegExp(r'\[pid=(\d+)?,(\d+)?,(\d+)?\]Reply\[/pid\] \[b\]Post by \[uid(=\d+)?\]([\s\S]*?)\[/uid\] \(([\s\S]*?)\):\[/b\]'),
    RegExp(r'\[b\]Reply to \[pid=(\d+)?,(\d+)?,(\d+)?\]Reply\[/pid\] Post by \[uid=(\d+)?\]([\s\S]*?)\[/uid\] \(([\s\S]*?)\)\[/b\]'),
    RegExp(r'\[b\]Reply to \[tid=(\d+)?\]Topic\[/tid\] Post by \[uid(=(\d+)?)?\]([\s\S]*?)\[/uid\] \(([\s\S]*?)\)\[/b\]'),
    RegExp(r'\[b\]Reply to \[tid=(\d+)?\]Topic\[/tid\] Post by \[uid\]([\s\S]*?)\[/uid\]\[color=gray\]\(([\s\S]*?)\)\[/color\] \(([\s\S]*?)\)\[/b\]'),
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
  // 简单替换映射表（不需要捕获组的标签）
  static const _simpleReplacements = {
    '[/size]': '</span>',
    '[/font]': '</span>',
    '[list]': '<ul>',
    '[/list]': '</ul>',
    '[quote]': '<blockquote>',
    '[/quote]': '</blockquote>',
    '======': '<br/><nga_hr></nga_hr>',
  };

  // 复杂标签的预编译正则（需要捕获内容的）
  static final _complexPatterns = <({RegExp regex, String Function(Match) replacer})>[
    (regex: RegExp(r'\[img\]([\s\S]*?)\[/img\]'), replacer: _imgReplacer),
    (regex: RegExp(r'\[url=([\s\S]*?)\]([\s\S]*?)\[/url\]'), replacer: _url2Replacer),
    (regex: RegExp(r'\[url\]([\s\S]*?)\[/url\]'), replacer: _urlReplacer),
    (regex: RegExp(r'\[flash\]([\s\S]*?)\[/flash\]'), replacer: _flashReplacer),
    (regex: RegExp(r'\[collapse=([\s\S]*?)\]([\s\S]*?)\[/collapse\]'), replacer: _collapseWithTitleReplacer),
    (regex: RegExp(r'\[collapse\]([\s\S]*?)\[/collapse\]'), replacer: _collapseReplacer),
    (regex: RegExp(r'\[color=([a-z]+?)\]([\s\S]*?)\[/color\]'), replacer: _colorReplacer),
    (regex: RegExp(r'\[align=([a-z]+?)\]([\s\S]*?)\[/align\]'), replacer: _alignReplacer),
    (regex: RegExp(r'\[(l|r)\]([\s\S]*?)\[/\1\]'), replacer: _lrReplacer),
    (regex: RegExp(r'\[h\]([\s\S]*?)\[/h\]'), replacer: _hReplacer),
    (regex: RegExp(r'===([^\n]*?)==='), replacer: _h2Replacer),
    (regex: RegExp(r'\[size=(\d+)%\]'), replacer: _sizeReplacer),
    (regex: RegExp(r'\[font=([^\[\]]+)\]'), replacer: _fontReplacer),
    (regex: RegExp(r'\[([/]?(?:b|u|i|del))\]'), replacer: _formatReplacer),
    (regex: RegExp(r'\[\*\](.+?)(?=<br/>|\[|$)'), replacer: _listItemReplacer),
    (regex: RegExp(r'[-]{6,}'), replacer: _dashReplacer),
  ];

  @override
  String parse(String? content) {
    if (content == null || content.isEmpty) return '';

    var result = content;

    // 先执行简单替换（字符串查找比正则快）
    _simpleReplacements.forEach((key, value) {
      result = result.replaceAll(key, value);
    });

    // 再执行复杂正则替换
    for (final pattern in _complexPatterns) {
      result = result.replaceAllMapped(pattern.regex, pattern.replacer);
    }

    return result;
  }

  static String _imgReplacer(Match m) {
    final url = m.group(1)!;
    final imgUrl = url.startsWith('./mon_')
        ? 'https://img.nga.178.com/attachments${url.substring(1)}'
        : url.startsWith('http://')
            ? url.replaceAll('http://', 'https://')
            : url;
    return "<img src='$imgUrl' />";
  }

  static String _url2Replacer(Match m) {
    final href = m.group(1)!;
    final text = m.group(2) ?? '';
    return href.startsWith('/')
        ? "<a href='https://bbs.nga.cn$href'>$text</a>"
        : "<a href='$href'>$text</a>";
  }

  static String _urlReplacer(Match m) {
    final url = m.group(1)!;
    return url.startsWith('/')
        ? "<a href='https://bbs.nga.cn$url'>[站内链接]</a>"
        : "<a href='$url'>$url</a>";
  }

  static String _flashReplacer(Match m) =>
      "<a href='https://bbs.nga.cn${m.group(1)}'>[站外视频]</a>";

  static String _collapseWithTitleReplacer(Match m) =>
      "<collapse title='${m.group(1)}'>${m.group(2) ?? ''}</collapse>";

  static String _collapseReplacer(Match m) =>
      "<collapse>${m.group(1)}</collapse>";

  static String _colorReplacer(Match m) =>
      "<font color='${m.group(1)}'>${m.group(2) ?? ''}</font>";

  static String _alignReplacer(Match m) =>
      "<div align='${m.group(1)}'>${m.group(2) ?? ''}</div>";

  static String _lrReplacer(Match m) {
    final align = m.group(1) == 'l' ? 'left' : 'right';
    return "<p style='text-align:$align'>${m.group(2) ?? ''}</p>";
  }

  static String _hReplacer(Match m) => '<h3>${m.group(1)}</h3>';

  static String _h2Replacer(Match m) => '<h3>${m.group(1)}</h3>';

  static String _sizeReplacer(Match m) => "<span font-size='${m.group(1)}%'>";

  static String _fontReplacer(Match m) => "<span style='font-family:${m.group(1)}'>";

  static String _formatReplacer(Match m) => '<${m.group(1)}>';

  static String _listItemReplacer(Match m) => '<li>${m.group(1)}</li>';

  static String _dashReplacer(Match m) => '<h5></h5>';
}

// 优化 4: 表情解析优化（构建映射表）
class _EmoticonParser implements Parser {
  static final _emoticonMap = <String, String>{};
  static bool _initialized = false;

  void _ensureInitialized() {
    if (_initialized) return;
    final list = Data().emoticonRepository.getEmoticonGroups();
    for (final group in list) {
      for (final emoticon in group.expressionList) {
        _emoticonMap[emoticon.content] = "<nga_emoticon src='${emoticon.url}'></nga_emoticon>";
      }
    }
    _initialized = true;
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
