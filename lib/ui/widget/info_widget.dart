import 'package:flutter/material.dart';

class InfoWidget extends StatelessWidget {
  const InfoWidget({this.title, this.subTitle, Key? key}) : super(key: key);

  final String? title;
  final String? subTitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title!,
          style: TextStyle(fontSize: 14),
        ),
        Text(
          subTitle!,
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).textTheme.bodyText2?.color,
          ),
        )
      ],
    );
  }
}
