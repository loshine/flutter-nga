import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';

class FontStyleWidget extends StatelessWidget {
  final _operationMap = {
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
                  padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
                ),
              ],
            ),
            onTap: () {
              // todo: 点击事件
            },
          ),
          color: Colors.transparent,
        );
      }).toList(),
    );
  }
}
