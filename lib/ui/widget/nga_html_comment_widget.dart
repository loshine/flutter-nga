import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/style.dart';
import 'package:flutter_nga/store/common/interface_settings_store.dart';
import 'package:flutter_nga/utils/dimen.dart';
import 'package:flutter_nga/utils/parser/content_parser.dart';
import 'package:provider/provider.dart';

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
          fontSize: FontSize(Dimen.body *
              Provider.of<InterfaceSettingsStore>(context).contentSizeMultiple),
          lineHeight: LineHeight(
              Provider.of<InterfaceSettingsStore>(context).lineHeight.size),
          padding: EdgeInsets.all(0),
          margin: EdgeInsets.all(0),
          color: Theme.of(context).textTheme.bodyText1?.color,
        ),
      },
    );
  }
}
