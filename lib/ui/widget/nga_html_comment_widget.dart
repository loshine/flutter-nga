import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/style.dart';
import 'package:flutter_nga/utils/parser/content_parser.dart';

class NgaHtmlCommentWidget extends StatelessWidget {
  final String content;

  const NgaHtmlCommentWidget({Key? key, required this.content})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Html(
      data: NgaContentParser.parseComment(content),
      style: {
        'body': Style(
          lineHeight: LineHeight(1.4),
          padding: EdgeInsets.all(0),
          margin: EdgeInsets.all(0),
          color: Theme.of(context).textTheme.bodyText1?.color,
        ),
      },
    );
  }
}
