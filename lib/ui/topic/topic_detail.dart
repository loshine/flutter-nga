import 'package:flutter/material.dart';
import 'package:flutter_nga/data/entity/topic.dart';

class TopicDetailPage extends StatefulWidget {
  const TopicDetailPage({Key key, this.topic}) : super(key: key);

  final Topic topic;

  @override
  _TopicDetailState createState() => _TopicDetailState();
}

class _TopicDetailState extends State<TopicDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.topic.subject),
      ),
    );
  }
}
