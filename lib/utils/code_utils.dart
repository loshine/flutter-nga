import 'dart:convert';

import 'package:fast_gbk/fast_gbk.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeAgo;

final _htmlUnescape = HtmlUnescape();
final _dateTimeFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
final _postDateFormat = DateFormat('yyyy-MM-dd');

/// 解码 html 特殊字符
String unescapeHtml(String? data) {
  if (isStringEmpty(data)) return "";
  return _htmlUnescape.convert(data!);
}

/// 判断字符串是否为空
bool isStringEmpty(String? content) {
  return content == null || content.isEmpty;
}

/// 格式化大小
String formatSize(int size) {
//如果字节数少于1024，则直接以B为单位，否则先除于1024，后3位因太少无意义
  if (size < 1024) {
    return "${size}B";
  } else {
    size = size ~/ 1024;
  }
//如果原字节数除于1024之后，少于1024，则可以直接以KB作为单位
//因为还没有到达要使用另一个单位的时候
//接下去以此类推
  if (size < 1024) {
    return "${size}KB";
  } else {
    size = size ~/ 1024;
  }
  if (size < 1024) {
//因为如果以MB为单位的话，要保留最后1位小数，
//因此，把此数乘以100之后再取余
    size = size * 100;
    return "${size ~/ 100}.${size % 100}MB";
  } else {
//否则如果要以GB为单位的，先除于1024再作同样的处理
    size = size * 100 ~/ 1024;
    return "${size ~/ 100}.${size % 100}GB";
  }
}

/// 格式化日期
String formatDate(DateTime dateTime) {
  return _dateTimeFormat.format(dateTime);
}

/// 格式化贴子时间
String formatPostDate(int time) {
  final date = DateTime.fromMillisecondsSinceEpoch(time);
  final nowDate = DateTime.now();
  if (nowDate.difference(date).inDays > 2) {
    return _postDateFormat.format(date);
  } else {
    return timeAgo.format(date);
  }
}

/// fluro 传递中文参数前，先转换，fluro 不支持中文传递
String fluroCnParamsEncode(String originalCn) {
  return jsonEncode(Utf8Encoder().convert(originalCn));
}

/// fluro 传递后取出参数，解析
String fluroCnParamsDecode(String encodedCn) {
  var list = <int>[];

  ///字符串解码
  jsonDecode(encodedCn).forEach(list.add);
  String value = Utf8Decoder().convert(list);
  return value;
}

/// remove characters with a numerical value < 32 and 127.
///
/// If `keep_new_lines` is `true`, newline characters are preserved
/// `(\n and \r, hex 0xA and 0xD)`.
String stripLow(String str, [bool keepNewLines = false]) {
  String chars =
      keepNewLines == true ? '\x00-\x09\x0B\x0C\x0E-\x1F\x7F' : '\x00-\x1F\x7F';
  return blacklist(str, chars);
}

/// remove characters that appear in the blacklist.
///
/// The characters are used in a RegExp and so you will need to escape
/// some chars.
String blacklist(String str, String chars) {
  return str.replaceAll(RegExp('[' + chars + ']+'), '');
}

String urlDecode(String content) {
  return Uri.decodeQueryComponent(content,
      encoding: const GbkCodec(allowMalformed: true));
}

String urlEncode(String content) {
  return Uri.encodeQueryComponent(content,
      encoding: const GbkCodec(allowMalformed: true));
}

/// 路由查询参数编码（UTF-8）
String encodeParam(String content) {
  return Uri.encodeQueryComponent(content);
}

/// 修复非标准 JSON（将无引号的键名转换为带引号的键名）
/// 例如: {foo: "bar"} -> {"foo": "bar"}
String fixUnquotedJsonKeys(String input) {
  // 匹配对象键名：在 { 或 , 后面的标识符，后跟冒号
  // 这个正则匹配: {key: 或 ,key: 或 { key: 或 , key:
  final pattern = RegExp(r'([{,]\s*)([a-zA-Z_][a-zA-Z0-9_]*)(\s*:)');
  return input.replaceAllMapped(pattern, (match) {
    return '${match.group(1)}"${match.group(2)}"${match.group(3)}';
  });
}
