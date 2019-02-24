import 'package:html_unescape/html_unescape.dart';
import 'package:intl/intl.dart';

class CodeUtils {
  static final _htmlUnescape = HtmlUnescape();
  static final _dateTimeFormat = DateFormat('yyyy-MM-dd hh:mm:ss');

  static String unescapeHtml(String data) {
    return _htmlUnescape.convert(data);
  }

  static bool isStringEmpty(String content) {
    return content == null || content.isEmpty;
  }

  static String formatSize(int size) {
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

  static String formatDate(DateTime dateTime){
    return _dateTimeFormat.format(dateTime);
  }
}
