import 'package:flutter_nga/data/data.dart';

class NgaContentParser {
  static List<Parser> _parserList = [
    _AlbumParser(),
    _TableParser(),
    _ContentParser(),
    _EmoticonParser(),
  ];

  static String parse(String content) {
    var parseContent = content;
    _parserList.forEach((parser) {
      parseContent = parser.parse(parseContent);
    });
    return parseContent;
  }
}

abstract class Parser {
  String parse(String content);
}

class _AlbumParser implements Parser {
  @override
  String parse(String content) {
    return content.replaceAllMapped(
        RegExp("\\[album(=([\\s\\S]*?)?)?]([\\s\\S]*?)?\\[/album]"), (match) {
      final value = match.group(3).replaceAllMapped(
          RegExp("\\[url]([\\s\\S]*?)?\\[/url]"),
          (m) => "<img src='${m.group(1)}'/>");
      return "<album>${match.group(1) != null ? match.group(2) : "相册"}$value</album>";
    });
  }
}

class _TableParser implements Parser {
  @override
  String parse(String content) {
    return content
        .replaceAllMapped(RegExp("\\[([/]?(tr|td))]"),
            (match) => "<${match.group(1)}>") // 处理tr, td
        .replaceAll("[table]", "<div><table><tbody>")
        .replaceAll("[/table]", "</tbody></table></div>")
        .replaceAllMapped(RegExp("\\[td([\\d]{1,3})+]"),
            (match) => "<td style='width:${match.group(1)}%;'>") // 处理 [td20]
        .replaceAllMapped(RegExp("\\[td (rowspan|colspan)=([\\d]+?)]"),
            (match) => "<td ${match.group(1)}='${match.group(2)}'")
        .replaceAllMapped(
            RegExp(
                "\\[td (rowspan|colspan)=([\\d]+?) (rowspan|colspan)=([\\d]+?)]"),
            (match) =>
                "<td ${match.group(1)}='${match.group(2)}' ${match.group(3)}='${match.group(4)}'")
        .replaceAllMapped(RegExp("<([/]?(table|tbody|tr|td))><br/>"),
            (match) => "<${match.group(1)}>") // 处理表格外面的额外空行
        .replaceAllMapped(RegExp("[ ]?<br/><(table|tbody|tr|td)>"),
            (match) => "<${match.group(1)}>");
  }
}

class _ContentParser implements Parser {
  @override
  String parse(String content) {
    return content
        .replaceAllMapped(
            RegExp("\\[img]([\\s\\S]*?)\\[/img]"), _imgReplaceFunc) // 处理 [img]
        .replaceAllMapped(RegExp("\\[url]([\\s\\S]*?)?\\[/url]"),
            _urlReplaceFunc) // 处理 [url]asd[/url]
        .replaceAllMapped(RegExp("\\[url=([\\s\\S]*?)?]([\\s\\S]*?)?\\[/url]"),
            _url2ReplaceFunc) // 处理[url=xxx]asd[/url]
        .replaceAllMapped(
            RegExp("\\[flash]([\\s\\S]*?)?\\[/flash]"),
            (match) =>
                "<a href='https://bbs.nga.cn${match.group(1)}'>[站外视频]</a>")
        .replaceAllMapped(RegExp("\\[h]([\\s\\S]*?)?\\[/h]"),
            (match) => "<h3>${match.group(1)}</h3>") // 处理 [h] 标题
        .replaceAllMapped(RegExp("===([\\s\\S]*?)?==="),
            (match) => "<h3>${match.group(1)}</h3>") // 处理 ===标题===
        .replaceAllMapped(RegExp("\\[(l|r)]([\\s\\S]*?)?\\[/(l|r)]"),
            (match) => "${match.group(2)}") // 对左右浮动段落不做处理，直接显示（手机屏没那么宽，不适合这种样式）
        .replaceAllMapped(
            RegExp("\\[color=([a-z]+?)]([\\s\\S]*?)\\[/color]"),
            (match) =>
                "<font color='${match.group(1)}'>${match.group(2)}</font>") // 处理[color=xx]asd[/color]
        .replaceAllMapped(
            RegExp("\\[align=([a-z]+?)]([\\s\\S]*?)\\[/align]"),
            (match) =>
                "<div align='${match.group(1)}'>${match.group(2)}</div>") // 处理[align=xx]asd[/align]
        .replaceAllMapped(RegExp("\\[size=(\\d+)%]"),
            (match) => "<span font-size='${match.group(1)}%'>") // 处理 [size=?%]
        .replaceAll("[/size]", "</span>") // [/size]
        .replaceAllMapped(
            RegExp("\\[font=([^\\[|\\]]+)]"),
            (match) =>
                "<span style='font-family:${match.group(1)}'>") // 处理 [font=?]
        .replaceAll("[/font]", "</span>") // [/font]
        .replaceAllMapped(
            RegExp(
                "\\[pid=(\\d+)?,(\\d+)?,(\\d+)?]Reply\\[/pid] \\[b]Post by \\[uid=(\\d+)?]([\\s\\S]*?)\\[/uid] \\(([\\s\\S]*?)\\):\\[/b]"),
            (match) =>
                "<a href='https://bbs.nga.cn/read.php?searchpost=1&pid=${match.group(1)}'>Reply</a> by <a href='https://bbs.nga.cn/nuke.php?func=ucp&uid=${match.group(4)}'>[${match.group(5)}]</a> (${match.group(6)}):")
        .replaceAllMapped(
            RegExp(
                "\\[b]Reply to \\[pid=(\\d+)?,(\\d+)?,(\\d+)?]Reply\\[/pid] Post by \\[uid=(\\d+)?]([\\s\\S]*?)\\[/uid] \\(([\\s\\S]*?)\\)\\[/b]"),
            (match) =>
                "<blockquote><a href='https://bbs.nga.cn/read.php?searchpost=1&pid=${match.group(1)}'>Reply</a> by ${match.group(5)} ${match.group(6)}</blockquote>")
        .replaceAllMapped(
            RegExp("\\[collapse=([\\s\\S]*?)]([\\s\\S]*?)?\\[/collapse]"),
            (match) =>
                "<collapse title='${match.group(1)}'>${match.group(2)}</collapse>")
        .replaceAllMapped(RegExp("\\[collapse]([\\s\\S]*?)?\\[/collapse]"),
            (match) => "<collapse>${match.group(1)}</collapse>")
        .replaceAllMapped(RegExp("\\[([/]?(b|u|i|del))]"),
            (match) => "<${match.group(1)}>") // 处理 b, u, i, del
        .replaceAll(RegExp("[-]{6,}"), "<h5></h5>")
        .replaceAll("[list]", "<ul>")
        .replaceAll("[/list]", "</ul>")
        .replaceAllMapped(RegExp("\\[\\*](.+?)<br/>"),
            (match) => "<li>${match.group(1)}</li>") // 处理 [*]
        .replaceAllMapped(RegExp("\\[\\*](.+?)"),
            (match) => "<li>${match.group(1)}</li>")
        .replaceAll("[quote]", "<blockquote>")
        .replaceAll("[/quote]", "</blockquote>");
  }

  String _imgReplaceFunc(Match match) {
    final group = match.group(1);
    final imgUrl = group.startsWith("./mon_")
        ? "https://img.nga.178.com/attachments${group.substring(1)}"
        : group;
    return "<a href='$imgUrl'><img src='$imgUrl' ></a>";
  }

  String _urlReplaceFunc(Match match) {
    final group = match.group(1);
    if (group.startsWith("/")) {
      return "<a href='https://bbs.nga.cn$group'>[站内链接]</a>";
    } else {
      return "<a href='$group'>$group</a>";
    }
  }

  String _url2ReplaceFunc(Match match) {
    final group1 = match.group(1);
    final group2 = match.group(2);
    if (group1.startsWith("/")) {
      return "<a href='https://bbs.nga.cn$group1'>$group2</a>";
    } else {
      return "<a href='$group1'>$group2</a>";
    }
  }
}

class _EmoticonParser implements Parser {
  static final list = Data().emoticonRepository.getEmoticonGroups();

  @override
  String parse(String content) {
    var parseContent = content;
    list.forEach((group) {
      group.expressionList.forEach((emoticon) {
        parseContent = parseContent.replaceAll(
            emoticon.content, "<img src='${emoticon.url}' >");
      });
    });
    return parseContent;
  }
}
