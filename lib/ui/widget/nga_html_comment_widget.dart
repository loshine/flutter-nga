import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_nga/utils/parser/content_parser.dart';

class NgaHtmlCommentWidget extends StatelessWidget {
  final String content;

  const NgaHtmlCommentWidget({Key key, this.content}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Html(data: NgaContentParser.parseComment(content));
  }
}
