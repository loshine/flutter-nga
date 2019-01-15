import 'package:html_unescape/html_unescape.dart';

class CodeUtils {
  static final _htmlUnescape = HtmlUnescape();

  static String unescapeHtml(String data) {
    return _htmlUnescape.convert(data);
  }

  static String toPostDateTimeString(DateTime dateTime) {
    return "${_twoDigits(dateTime.year)}-${_twoDigits(
        dateTime.month)}-${_twoDigits(dateTime.day)} ${_twoDigits(
        dateTime.hour)}:${_twoDigits(dateTime.minute)}";
  }

  static String _twoDigits(int n) {
    if (n >= 10) return "$n";
    return "0$n";
  }
}
