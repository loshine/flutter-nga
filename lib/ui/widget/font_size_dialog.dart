import 'package:flutter/material.dart';
import 'package:flutter_nga/ui/widget/font_style_widget.dart';
import 'package:flutter_nga/utils/route.dart';

class FontSizeDialog extends StatelessWidget {
  const FontSizeDialog({this.callback, Key key}) : super(key: key);
  final InputCallback callback;

  static const sizeList = [
    "110%",
    "120%",
    "130%",
    "150%",
    "200%",
    "300%",
    "400%",
    "500%",
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("字号"),
      content: SizedBox(
        width: 0,
        height: 408,
        child: ListView.builder(
          itemCount: sizeList.length,
          itemBuilder: (context, position) {
            return InkWell(
              child: Padding(
                padding: EdgeInsets.fromLTRB(0, 16, 0, 16),
                child: Text("${sizeList[position]}"),
              ),
              onTap: () {
                if (callback != null) {
                  callback("[size=${sizeList[position]}]", "[/size]", true);
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
