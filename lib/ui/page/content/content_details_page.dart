import 'package:flutter/material.dart';
import 'package:flutter_nga/utils/dimen.dart';

class ContentDetailsPage extends StatelessWidget {
  final List<Widget> children;

  const ContentDetailsPage(this.children, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child: DefaultTextStyle.merge(
            child: Wrap(children: children),
            style: TextStyle(
              fontSize: Dimen.display1.toDouble(),
            ),
          ),
        ),
      ),
    );
  }
}
