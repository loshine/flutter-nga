import 'package:flutter/cupertino.dart';
import 'package:flutter_nga/ui/widget/nga_html_widget.dart';
import 'package:flutter_nga/utils/parser/content_parser.dart';

class NgaHtmlContentWidget extends StatelessWidget {
  final String content;

  const NgaHtmlContentWidget({Key key, this.content}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return NgaHtmlWidget(content: NgaContentParser.parse(content));
  }
}
