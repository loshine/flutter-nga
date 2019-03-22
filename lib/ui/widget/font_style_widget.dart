import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nga/ui/widget/font_color_dialog.dart';
import 'package:flutter_nga/ui/widget/font_size_dialog.dart';

typedef InputCallback = void Function(
    String startTag, String endTag, bool hasEnd);

class FontStyleWidget extends StatelessWidget {
  const FontStyleWidget({this.callback, Key key}) : super(key: key);

  static const _operationMap = {
    "字号": CommunityMaterialIcons.format_size,
    "颜色": CommunityMaterialIcons.format_color_text,
    "加粗": CommunityMaterialIcons.format_bold,
    "斜体": CommunityMaterialIcons.format_italic,
    "下划线": CommunityMaterialIcons.format_underline,
    "删除线": CommunityMaterialIcons.format_strikethrough,
    "[@用户]": CommunityMaterialIcons.at,
    "[quote]": CommunityMaterialIcons.format_quote_open,
    "[url]": CommunityMaterialIcons.link,
    ">折叠<": CommunityMaterialIcons.arrow_collapse_vertical,
  };

  final InputCallback callback;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 4,
      children: _operationMap.entries.map((entry) {
        return Material(
          child: InkWell(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(entry.value),
                Padding(
                  child: Text(entry.key),
                  padding: EdgeInsets.only(top: 8),
                ),
              ],
            ),
            onTap: () {
              handleByKey(context, entry.key);
            },
          ),
          color: Colors.transparent,
        );
      }).toList(),
    );
  }

  void handleByKey(BuildContext context, String key) {
    if (callback == null) return;
    switch (key) {
      case "字号":
        showDialog(
          context: context,
          builder: (context) => FontSizeDialog(callback: callback),
        );
        break;
      case "颜色":
        showDialog(
          context: context,
          builder: (context) => FontColorDialog(callback: callback),
        );
        break;
      case "加粗":
        callback("[b]", "[/b]", true);
        break;
      case "斜体":
        callback("[i]", "[/i]", true);
        break;
      case "下划线":
        callback("[u]", "[/u]", true);
        break;
      case "删除线":
        callback("[del]", "[/del]", true);
        break;
      case "[@用户]":
        callback("[@", "]", true);
        break;
      case "[quote]":
        callback("[quote]", "[/quote]", true);
        break;
      case "[url]":
        callback("[url]", "[/url]", true);
        break;
      case ">折叠<":
        callback("[collapse]", "[/collapse]", true);
        break;
    }
  }
}
