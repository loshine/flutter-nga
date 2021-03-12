import 'package:flutter/material.dart';
import 'package:flutter_nga/utils/palette.dart';
import 'package:flutter_nga/utils/route.dart';

class TopicPageSelectDialog extends StatefulWidget {
  final int? currentPage;
  final int? maxPage;
  final int? maxFloor;

  const TopicPageSelectDialog(
      {Key? key, this.maxPage, this.maxFloor, this.currentPage})
      : super(key: key);

  @override
  _TopicPageSelectState createState() => _TopicPageSelectState();
}

class _TopicPageSelectState extends State<TopicPageSelectDialog> {
  int? _currentVal = 1;
  bool _isPage = true;

  @override
  void initState() {
    _currentVal = widget.currentPage;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("跳转"),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("第$_currentVal${_isPage ? "页" : "楼"}"),
            Slider(
              value: _currentVal!.toDouble(),
              min: 1,
              max: _isPage
                  ? widget.maxPage!.toDouble()
                  : widget.maxPage!.toDouble() * 20,
              divisions: _isPage ? widget.maxPage! - 1 : widget.maxPage! * 20 - 1,
              onChanged: (double newValue) {
                setState(() {
                  _currentVal = newValue.round();
                });
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(
                      "页码",
                      style: TextStyle(
                          color: _isPage
                              ? Colors.white
                              : Palette.colorTextPrimary),
                    ),
                    selectedColor: Palette.colorPrimary,
                    selected: _isPage,
                    onSelected: (selected) {
                      setState(() {
                        _isPage = selected;
                      });
                    },
                  ),
                ),
                ChoiceChip(
                  label: Text(
                    "楼层",
                    style: TextStyle(
                        color:
                            !_isPage ? Colors.white : Palette.colorTextPrimary),
                  ),
                  selectedColor: Palette.colorPrimary,
                  selected: !_isPage,
                  onSelected: (selected) {
                    setState(() {
                      _isPage = !selected;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        FlatButton(
          child: Text("取消"),
          textColor: Palette.colorTextSecondary,
          onPressed: () {
            Routes.pop(context);
          },
        ),
        FlatButton(
          child: Text("确认"),
          onPressed: () {
            Routes.pop(context);
          },
        ),
      ],
    );
  }
}
