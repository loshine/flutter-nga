import 'package:html_unescape/html_unescape.dart';

class CodeUtils {
  static final _htmlUnescape = HtmlUnescape();

  static String unescapeHtml(String data) {
    return _htmlUnescape.convert(data);
  }
}
