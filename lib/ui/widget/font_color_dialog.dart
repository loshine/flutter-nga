import 'package:flutter/material.dart';
import 'package:flutter_nga/ui/widget/font_style_widget.dart';

class FontColorDialog extends StatelessWidget {
  const FontColorDialog({this.callback, Key key}) : super(key: key);
  final InputCallback callback;

  static const colorMap = {
    "skyblue": Color(0xFF87CEEB),
    "royalblue": Color(0xFF4169E1),
    "blue": Color(0xFF0000FF),
    "darkblue": Color(0xFF00008B),
    "orange": Color(0xFFFFA500),
    "orangered": Color(0xFFFF4500),
    "crimson": Color(0xFFDC143C),
    "red": Color(0xFFFF0000),
    "firebrick": Color(0xFFB22222),
    "darkred": Color(0xFF8B0000),
    "green": Color(0xFF008000),
    "limegreen": Color(0xFF32CD32),
    "seagreen": Color(0xFF2E8B57),
    "teal": Color(0xFF008080),
    "deeppink": Color(0xFFFF1493),
    "tomato": Color(0xFFFF6347),
    "coral": Color(0xFFFF7F50),
    "purple": Color(0xFF800080),
    "indigo": Color(0xFF4B0082),
    "burlywood": Color(0xFFDEB887),
    "sandybrown": Color(0xFFF4A460),
    "chocolate": Color(0xFFD2691E),
    "silver": Color(0xFFC0C0C0),
  };

  @override
  Widget build(BuildContext context) {
    final keyList = colorMap.keys.toList();
    final valueList = colorMap.values.toList();
    return AlertDialog(
      title: Text("颜色"),
      content: SizedBox(
        width: 0,
        height: 408,
        child: ListView.builder(
          itemCount: colorMap.length,
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
                Navigator.of(context).pop();
              },
            );
          },
        ),
      ),
    );
  }
}
