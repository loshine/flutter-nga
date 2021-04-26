import 'package:flutter/material.dart';
import 'package:flutter_nga/utils/route.dart';

typedef PageSelectedCallback = Function(bool, int);

class TopicPageSelectDialog extends StatefulWidget {
  final int currentPage;
  final int maxPage;
  final int maxFloor;
  final PageSelectedCallback? pageSelectedCallback;

  const TopicPageSelectDialog(
      {Key? key,
      required this.maxPage,
      required this.maxFloor,
      required this.currentPage,
      this.pageSelectedCallback})
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
              divisions: _calcDivision(),
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
                              : Theme.of(context).textTheme.bodyText1?.color),
                    ),
                    selectedColor: Theme.of(context).primaryColor,
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
                            : Theme.of(context).textTheme.bodyText1?.color),
                  ),
                  selectedColor: Theme.of(context).primaryColor,
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
              primary: Theme.of(context).textTheme.bodyText2?.color),
          onPressed: () => Routes.pop(context),
        ),
        TextButton(
          child: Text("确认"),
          onPressed: () {
            if (widget.pageSelectedCallback != null) {
              widget.pageSelectedCallback!(_isPage, _currentVal);
            }
            Routes.pop(context);
          },
        ),
      ],
    );
  }

  int _calcDivision() {
    if (_isPage) {
      return widget.maxPage > 1 ? widget.maxPage - 1 : 1;
    } else {
      return widget.maxFloor > 1 ? widget.maxFloor - 1 : 1;
    }
  }
}
