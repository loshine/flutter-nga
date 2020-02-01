import 'package:flutter/material.dart';
import 'package:flutter_nga/ui/widget/font_style_widget.dart';
import 'package:flutter_nga/utils/constant.dart';
import 'package:flutter_nga/utils/route.dart';

class FontColorDialog extends StatelessWidget {
  const FontColorDialog({this.callback, Key key}) : super(key: key);
  final InputCallback callback;

  @override
  Widget build(BuildContext context) {
    final keyList = TEXT_COLOR_MAP.keys.toList();
    final valueList = TEXT_COLOR_MAP.values.toList();
    return AlertDialog(
      title: Text("颜色"),
      content: SizedBox(
        width: 0,
        height: 408,
        child: ListView.builder(
          itemCount: TEXT_COLOR_MAP.length,
          itemBuilder: (context, position) {
            return InkWell(
              child: Padding(
                padding: EdgeInsets.fromLTRB(0, 16, 0, 16),
                child: Text(
                  "${keyList[position]}",
                  style: TextStyle(color: valueList[position]),
                ),
              ),
              onTap: () {
                if (callback != null) {
                  callback("[color=${keyList[position]}]", "[/color]", true);
                }
                Routes.pop(context);
              },
            );
          },
        ),
      ),
    );
  }
}
