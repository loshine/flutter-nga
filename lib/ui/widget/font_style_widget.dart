import 'package:community_material_icon/community_material_icon.dart';
import 'package:cupertino_ui/cupertino_ui.dart' show CupertinoIcons;
import 'package:material_ui/material_ui.dart';

import 'package:flutter_nga/providers/settings/design_style_provider.dart';
import 'package:flutter_nga/ui/widget/font_color_dialog.dart';
import 'package:flutter_nga/ui/widget/font_size_dialog.dart';

typedef InputCallback = void Function(
  String startTag,
  String endTag,
  bool hasEnd,
);

class FontStyleWidget extends StatelessWidget {
  const FontStyleWidget({this.callback, super.key});

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

  static const _appleOperationMap = {
    "字号": CupertinoIcons.textformat_size,
    "颜色": CupertinoIcons.paintbrush,
    "加粗": CupertinoIcons.bold,
    "斜体": CupertinoIcons.italic,
    "下划线": CupertinoIcons.underline,
    "删除线": CupertinoIcons.strikethrough,
    "[@用户]": CupertinoIcons.at,
    "[quote]": CupertinoIcons.text_quote,
    "[url]": CupertinoIcons.link,
    ">折叠<": CupertinoIcons.chevron_up_chevron_down,
  };

  final InputCallback? callback;

  @override
  Widget build(BuildContext context) {
    final isApple = context.isAppleStyle;
    final colorScheme = Theme.of(context).colorScheme;
    final operations = isApple ? _appleOperationMap : _operationMap;

    return GridView.count(
      crossAxisCount: 4,
      crossAxisSpacing: isApple ? 8 : 0,
      mainAxisSpacing: isApple ? 8 : 0,
      children: operations.entries.map((entry) {
        final content = Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              entry.value,
              size: isApple ? 20 : 24,
              color: isApple ? colorScheme.onSurface : null,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                entry.key,
                style: isApple
                    ? TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      )
                    : null,
              ),
            ),
          ],
        );

        if (isApple) {
          return Material(
            color: colorScheme.surfaceContainerLow,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(color: colorScheme.outlineVariant, width: 0.5),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => handleByKey(context, entry.key),
              child: content,
            ),
          );
        }

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => handleByKey(context, entry.key),
            child: content,
          ),
        );
      }).toList(),
    );
  }

  void handleByKey(BuildContext context, String key) {
    if (callback == null) return;
    switch (key) {
      case "字号":
        FontSizeDialog.show(context, callback: callback);
        break;
      case "颜色":
        FontColorDialog.show(context, callback: callback);
        break;
      case "加粗":
        callback?.call("[b]", "[/b]", true);
        break;
      case "斜体":
        callback?.call("[i]", "[/i]", true);
        break;
      case "下划线":
        callback?.call("[u]", "[/u]", true);
        break;
      case "删除线":
        callback?.call("[del]", "[/del]", true);
        break;
      case "[@用户]":
        callback?.call("[@", "]", true);
        break;
      case "[quote]":
        callback?.call("[quote]", "[/quote]", true);
        break;
      case "[url]":
        callback?.call("[url]", "[/url]", true);
        break;
      case ">折叠<":
        callback?.call("[collapse]", "[/collapse]", true);
        break;
    }
  }
}
