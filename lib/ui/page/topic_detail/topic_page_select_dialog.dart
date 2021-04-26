import 'package:flutter/material.dart';
import 'package:flutter_nga/utils/palette.dart';
import 'package:flutter_nga/utils/route.dart';

class TopicPageSelectDialog extends StatefulWidget {
  final int currentPage;
  final int maxPage;
  final int maxFloor;

  const TopicPageSelectDialog(
      {Key? key, required this.maxPage, required this.maxFloor, required this.currentPage})
      : super(key: key);

  @override
  _TopicPageSelectState createState() => _TopicPageSelectState();
}

class _TopicPageSelectState extends State<TopicPageSelectDialog> {
  int _currentVal = 1;
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
              value: _currentVal.toDouble(),
              min: 1,
              max: _isPage
                  ? widget.maxPage.toDouble()
                  : widget.maxFloor.toDouble(),
              divisions: _isPage ? widget.maxPage : widget.maxFloor,
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
                              : Theme
                              .of(context)
                              .textTheme
                              .bodyText1
                              ?.color),
                    ),
                    selectedColor: Theme
                        .of(context)
                        .primaryColor,
                    selected: _isPage,
                    onSelected: (selected) {
                      setState(() {
                        _isPage = selected;
                        _currentVal = widget.currentPage;
                      });
                    },
                  ),
                ),
                ChoiceChip(
                  label: Text(
                    "楼层",
                    style: TextStyle(
                        color: !_isPage
                            ? Colors.white
                            : Theme
                            .of(context)
                            .textTheme
                            .bodyText1
                            ?.color),
                  ),
                  selectedColor: Theme
                      .of(context)
                      .primaryColor,
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
        TextButton(
          child: Text("取消"),
          style: TextButton.styleFrom(
              primary: Theme
                  .of(context)
                  .textTheme
                  .bodyText2
                  ?.color),
          onPressed: () => Routes.pop(context),
        ),
        TextButton(
          child: Text("确认"),
          onPressed: () => Routes.pop(context),
        ),
      ],
    );
  }
}
