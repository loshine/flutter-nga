import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nga/utils/palette.dart';
import 'package:flutter_nga_html/html_parser.dart';
import 'package:html/dom.dart' as dom;

ngaRenderer() {
  return (dom.Node node, List<Widget> children, NodeParser nodeParser,
      NodesParser nodesParser) {
    if (node is dom.Element) {
      switch (node.localName) {
        case "img":
          if (node.attributes['src'] != null) {
            return CachedNetworkImage(imageUrl: "${node.attributes['src']}");
          } else if (node.attributes['alt'] != null) {
            //Temp fix for https://github.com/flutter/flutter/issues/736
            if (node.attributes['alt'].endsWith(" ")) {
              return Container(
                  padding: EdgeInsets.only(right: 2.0),
                  child: Text(node.attributes['alt']));
            } else {
              return Text(node.attributes['alt']);
            }
          }
          return Container();
        case "blockquote":
          return Container(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
            margin: EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Palette.colorQuoteBackground,
              border: Border.all(color: Palette.colorDivider),
            ),
            child: Wrap(children: nodesParser(node.nodes)),
          );
      }
    }
    return null;
  };
}
