import 'package:flutter/material.dart';

class CollapseWidget extends StatefulWidget {
  const CollapseWidget.fromNodes({this.title, this.children, Key key})
      : super(key: key);

  final String title;
  final List<Widget> children;

  @override
  _CollapseState createState() => _CollapseState();
}

class _CollapseState extends State<CollapseWidget> {
  var _collapsed = true; // 默认收起

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RaisedButton(
          onPressed: () => setState(() => _collapsed = !_collapsed),
          child: Text("${_collapsed ? "点击展开" : "点击收起"}:${widget.title ?? ""}"),
        ),
        SizedBox(
          height: _collapsed ? 0 : null,
          child: Wrap(children: widget.children),
        ),
      ],
    );
  }
}
