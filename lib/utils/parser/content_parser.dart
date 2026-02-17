import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/data/entity/emoticon.dart';
import 'package:flutter_nga/utils/code_utils.dart' as code_utils;
import 'package:flutter_nga/utils/dice_roller.dart';
import 'package:flutter_nga/utils/name_utils.dart';

class NgaContentParser {
  static final Parser _replyParser = _ReplyParser();
  static final Parser _commentParser = _CommentParser();

  // 优化 3: LRU 缓存（最多缓存 256 条）
  static final _parseCache = <String, String>{};
  static final _cacheKeys = <String>[];
  static const _maxCacheSize = 256;

  static List<Parser> _buildParserList({int? postDateTimestamp}) {
    return [
      _AlbumParser(),
      _TableParser(),
      _ContentParser(postDateTimestamp: postDateTimestamp),
      _EmoticonParser(),
      _UnsupportedTagFallbackParser(),
    ];
  }

  static String parse(
    String? content, {
    int? authorId,
    int? tid,
    int? pid,
    int? postDateTimestamp,
  }) {
    if (content == null || content.isEmpty) return '';

    final cacheKey = authorId != null
        ? '__dice_${authorId}_${tid}_${pid}_${postDateTimestamp}__$content'
        : '__postdate_${postDateTimestamp}__$content';
    if (_parseCache.containsKey(cacheKey)) {
      return _parseCache[cacheKey]!;
    }

    var parseContent = code_utils.unescapeHtml(content);
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

// 优化 1: 预编译正则
class _AlbumParser implements Parser {
  static final _albumRegex =
      RegExp(r'\[album(=([\s\S]*?)?)?\]([\s\S]*?)?\[/album\]');
  static final _urlRegex = RegExp(r'\[url\]([\s\S]*?)?\[/url\]');

  @override
  String parse(String? content) {
    if (content == null || content.isEmpty) return '';
    return content.replaceAllMapped(_albumRegex, (match) {
      final value = (match.group(3) ?? '').replaceAllMapped(
        _urlRegex,
        (m) => "<img src='${m.group(1)}'/>",
      );
      return "<album>${match.group(1) != null ? match.group(2) : "相册"}$value</album>";
    });
  }
}

class _TableParser implements Parser {
  static final _trTdRegex = RegExp(r'\[([/]?(tr|td))\]');
  static final _tdNumRegex = RegExp(r'\[td([\d]{1,3})+\]');
  static final _tdSpanRegex = RegExp(r'\[td (rowspan|colspan)=([\d]+?)\]');
  static final _tdDoubleSpanRegex =
      RegExp(r'\[td (rowspan|colspan)=([\d]+?) (rowspan|colspan)=([\d]+?)\]');
  static final _tagBrRegex = RegExp(r'<([/]?(table|tbody|tr|td))><br/>');
  static final _brTagRegex = RegExp(r'[ ]?<br/><[/]?(table|tbody|tr|td)>');

  @override
  String parse(String? content) {
    if (content == null || content.isEmpty) return '';
    return content
        .replaceAllMapped(_trTdRegex, (match) => '<${match.group(1)}>')
        .replaceAll('[table]', '<div><table><tbody>')
        .replaceAll('[/table]', '</tbody></table></div>')
        .replaceAllMapped(
            _tdNumRegex, (match) => "<td style='width:${match.group(1)}%;'>")
        .replaceAllMapped(_tdSpanRegex,
            (match) => "<td ${match.group(1)}='${match.group(2)}'")
        .replaceAllMapped(
            _tdDoubleSpanRegex,
            (match) =>
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
    // 使用 Data 中的动态 baseUrl
    final baseUrl = Data().baseUrl;
    return content
        .replaceAllMapped(
            _topicRegex,
            (m) =>
                "<a href='${baseUrl}read.php?tid=${m.group(1)}'>Topic</a> Post by <a href='${baseUrl}nuke.php?func=ucp&uid=${m.group(2)}'>[${m.group(3)}]</a> <small>(${m.group(4)})</small>")
        .replaceAllMapped(
            _replyRegex,
            (m) =>
                "<a href='${baseUrl}read.php?searchpost=1&pid=${m.group(1)}'>Reply</a> Post by <a href='${baseUrl}nuke.php?func=ucp&uid=${m.group(4)}'>[${m.group(5)}]</a> <small>(${m.group(6)})</small>:")
        .replaceAllMapped(
            _anonyRegex,
            (m) =>
                "<a href='${baseUrl}read.php?searchpost=1&pid=${m.group(1)}'>Reply</a> Post by ${getShowName("#anony_${m.group(4)}")}</a><font color='gray'>(${m.group(5)}楼)</font> <small>(${m.group(6)})</small>:")
        .replaceAllMapped(
            _replyTopicRegex,
            (m) =>
                "Reply to <a href='${baseUrl}read.php?searchpost=1&pid=${m.group(1)}'>Topic</a> Post by ${m.group(2)} ${m.group(3)}")
        .replaceAllMapped(
            _replyPostRegex,
            (m) =>
                "Reply to <a href='${baseUrl}read.php?searchpost=1&pid=${m.group(1)}'>Post</a> by ${m.group(5)} ${m.group(6)}");
  }
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
    '[list]': '<ul>',
    '[/list]': '</ul>',
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
  static final _colorRegex = RegExp(r'\[color=([a-z]+?)\]([\s\S]*?)\[/color\]');
  static final _alignRegex = RegExp(r'\[align=([a-z]+?)\]([\s\S]*?)\[/align\]');
  static final _lrRegex = RegExp(r'\[(l|r)\]([\s\S]*?)\[/\1\]');
  static final _hRegex = RegExp(r'\[h\]([\s\S]*?)\[/h\]');
  static final _h2Regex = RegExp(r'===([^\n]*?)===');
  static final _sizeRegex = RegExp(r'\[size=(\d+)%\]');
  static final _fontRegex = RegExp(r'\[font=([^\[\]]+)\]');
  static final _formatRegex = RegExp(r'\[([/]?(?:b|u|i|del))\]');
  static final _listItemRegex = RegExp(r'\[\*\](.+?)(?=<br/>|\[|$)');
  static final _dashRegex = RegExp(r'[-]{6,}');

  @override
  String parse(String? content) {
    if (content == null || content.isEmpty) return '';

    var result = content;

    // 先执行简单替换（字符串查找比正则快）
    _simpleReplacements.forEach((key, value) {
      result = result.replaceAll(key, value);
    });

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
    result = result.replaceAllMapped(_listItemRegex, _listItemReplacer);
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
    final label = flashType == 'audio' ? '[站外音频]' : '[站外视频]';
    if (url.isEmpty) return label;
    return "<a href='${_escapeHtmlAttribute(url)}'>$label</a>";
  }

  static String _flashReplacer(Match m) {
    final raw = m.group(1) ?? '';
    final url = _normalizeGeneralUrl(raw);
    if (url.isEmpty) return '[站外视频]';
    return "<a href='${_escapeHtmlAttribute(url)}'>[站外视频]</a>";
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

  static String _fontReplacer(Match m) =>
      "<span style='font-family:${m.group(1)}'>";

  static String _formatReplacer(Match m) => '<${m.group(1)}>';

  static String _listItemReplacer(Match m) => '<li>${m.group(1)}</li>';

  static String _dashReplacer(Match m) => '<h5></h5>';
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
