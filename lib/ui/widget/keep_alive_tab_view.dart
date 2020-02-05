import 'package:flutter/material.dart';

class KeepAliveTabView extends StatefulWidget {
  final Widget child;

  const KeepAliveTabView({this.child, Key key}) : super(key: key);

  @override
  _KeepAliveTabState createState() => _KeepAliveTabState();
}

class _KeepAliveTabState extends State<KeepAliveTabView>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }

  @override
  bool get wantKeepAlive => true;
}
