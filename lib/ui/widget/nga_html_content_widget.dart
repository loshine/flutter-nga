import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/html_parser.dart';
import 'package:flutter_html/style.dart';
import 'package:flutter_nga/utils/code_utils.dart';
import 'package:flutter_nga/utils/constant.dart';
import 'package:flutter_nga/utils/dimen.dart';
import 'package:flutter_nga/utils/palette.dart';
import 'package:flutter_nga/utils/parser/content_parser.dart';
import 'package:flutter_nga/utils/route.dart';
import 'package:html/dom.dart' as dom;

import 'collapse_widget.dart';

class NgaHtmlContentWidget extends StatelessWidget {
  final String? content;

  const NgaHtmlContentWidget({Key? key, this.content}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Html(
      data: NgaContentParser.parse(content),
      customRender: {
        'div': _alignmentRender,
        'span': _fontSizeRender,
        'font': _fontColorRender,
        'collapse': _collapseRender,
        'img': _imageRender,
        'nga_emoticon': _emoticonRender,
        'blockquote': _blockquoteRender,
        'album': _albumRender,
        'nga_hr': _hrRender,
        'table': _tableRender,
      },
      style: {
        'body': Style(
          lineHeight: LineHeight(1.4),
          padding: EdgeInsets.all(0),
          margin: EdgeInsets.all(0),
          color: Theme.of(context).textTheme.bodyText1?.color,
        ),
        'blockquote': Style(
          padding: EdgeInsets.all(0),
          margin: EdgeInsets.all(0),
        ),
        'table': Style(
          margin: EdgeInsets.all(8),
          border: Border(
            left: BorderSide(color: Colors.grey.shade300),
            right: BorderSide(color: Colors.grey.shade300),
            top: BorderSide(color: Colors.grey.shade300),
          ),
        ),
        'tr': Style(
          backgroundColor: Colors.white.withAlpha(150),
          border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
        ),
        'td': Style(padding: EdgeInsets.all(8)),
      },
      onLinkTap: (String? url, RenderContext renderContext,
              Map<String, String> attributes, dom.Element? element) =>
          Routes.onLinkTap(context, url),
    );
  }

  Widget _alignmentRender(RenderContext context, Widget parsedChild) {
    final attributes = context.tree.attributes;
    if (attributes['align'] != null) {
      final align = attributes['align'];
      var alignment = WrapAlignment.start;
      if (align == "left") {
        alignment = WrapAlignment.start;
      } else if (align == "right") {
        alignment = WrapAlignment.end;
      } else if (align == "center") {
        alignment = WrapAlignment.center;
      }
      return Container(
        width: double.infinity,
        child: Wrap(
          children: [parsedChild],
          alignment: alignment,
        ),
      );
    }
    return parsedChild;
  }

  Widget _fontSizeRender(RenderContext context, Widget parsedChild) {
    final attributes = context.tree.attributes;
    if (attributes['font-size'] != null) {
      final fontSize = attributes['font-size']!;
      if (fontSize.endsWith("%")) {
        final multiple =
            int.parse(fontSize.substring(0, fontSize.length - 1)) / 100;
        return DefaultTextStyle.merge(
          child: parsedChild,
          style: TextStyle(fontSize: Dimen.body * multiple),
        );
      }
    }
    return DefaultTextStyle.merge(child: parsedChild);
  }

  Widget _fontColorRender(RenderContext context, Widget parsedChild) {
    final attributes = context.tree.attributes;
    if (attributes['color'] != null) {
      String? color = attributes['color'];
      return DefaultTextStyle.merge(
        child: parsedChild,
        style: TextStyle(
          color: TEXT_COLOR_MAP[color!],
          decorationColor: TEXT_COLOR_MAP[color],
        ),
      );
    } else {
      return DefaultTextStyle.merge(child: parsedChild);
    }
  }

  Widget _collapseRender(RenderContext context, Widget parsedChild) {
    final attributes = context.tree.attributes;
    if (attributes['title'] != null) {
      return CollapseWidget.fromNodes(
        title: attributes['title'],
        child: parsedChild,
      );
    } else {
      return CollapseWidget.fromNodes(child: parsedChild);
    }
  }

  Widget _imageRender(RenderContext context, Widget parsedChild) {
    final attributes = context.tree.attributes;
    return Builder(builder: (context) {
      return InkWell(
        onTap: () => Routes.navigateTo(context,
            "${Routes.PHOTO_PREVIEW}?url=${fluroCnParamsEncode(attributes['src']!)}&screenWidth=${MediaQuery.of(context).size.width}"),
        child: CachedNetworkImage(
          fit: BoxFit.cover,
          imageUrl: attributes['src']!,
          placeholder: (context, url) => Icon(
            Icons.image,
            size: 48,
            color: Theme.of(context).iconTheme.color,
          ),
        ),
      );
    });
  }

  Widget _emoticonRender(RenderContext context, Widget parsedChild) {
    final attributes = context.tree.attributes;
    return CachedNetworkImage(
      fit: BoxFit.cover,
      imageUrl: attributes['src']!,
      placeholder: (context, url) => Icon(
        Icons.image,
        size: 48,
        color: Theme.of(context).iconTheme.color,
      ),
    );
  }

  Widget _blockquoteRender(RenderContext renderContext, Widget parsedChild) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Palette.getColorQuoteBackground(renderContext.buildContext),
        border: Border.all(
            color: Theme.of(renderContext.buildContext).dividerColor),
      ),
      child: parsedChild,
    );
  }

  Widget _albumRender(RenderContext renderContext, Widget parsedChild) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Palette.getColorAlbumBackground(renderContext.buildContext),
        border: Border.all(
            color: Palette.getColorAlbumBorder(renderContext.buildContext)),
      ),
      child: parsedChild,
    );
  }

  Widget _hrRender(RenderContext context, Widget parsedChild) {
    return Divider(height: 1);
  }

  Widget _tableRender(RenderContext context, Widget parsedChild) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: parsedChild,
    );
  }
}
