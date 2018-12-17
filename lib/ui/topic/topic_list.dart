import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/data/entity/forum.dart';
import 'package:flutter_nga/data/entity/topic.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TopicListPage extends StatefulWidget {
  TopicListPage(this.forum, {Key key}) : super(key: key);

  final Forum forum;

  @override
  _TopicListState createState() => _TopicListState();
}

class _TopicListState extends State<TopicListPage> {
  bool _defaultFavourite = false;
  bool isFavourite = false;

  List<Topic> _topicList = [];

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.pop(context, _defaultFavourite != isFavourite);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.forum.name),
          actions: <Widget>[
            IconButton(
              icon: SvgPicture.asset(
                "images/star${isFavourite ? '' : '-outline'}.svg",
                fit: BoxFit.none,
                color: Colors.white,
              ),
              onPressed: () => _switchFavourite(),
            ),
          ],
        ),
        body: ListView.builder(
          itemCount: _topicList.length + 1,
          itemBuilder: (context, index) {
            if (index == _topicList.length) {
              // 加载更多
              return _buildProgressIndicator();
            } else {
              return _buildListItemWidget(_topicList[index]);
            }
          },
        ),
      ),
    );
  }

  @override
  void initState() {
    Data().forumRepository.isFavourite(widget.forum).then((isFavourite) {
      setState(() {
        _defaultFavourite = isFavourite;
        this.isFavourite = isFavourite;
      });
    });
    Data()
        .topicRepository
        .getTopicList(widget.forum.fid, 1)
        .then((TopicListData data) =>
            setState(() => _topicList.addAll(data.topicList.values)))
        .catchError((DioError error) => debugPrint(error.message));
    super.initState();
  }

  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Opacity(
//          opacity: isPerformingRequest ? 1.0 : 0.0,
          opacity: 1.0,
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  Widget _buildListItemWidget(Topic topic) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        children: [
          Text(topic.subject),
        ],
      ),
    );
  }

  _switchFavourite() async {
    if (isFavourite) {
      await Data().forumRepository.deleteFavourite(widget.forum);
    } else {
      await Data().forumRepository.saveFavourite(widget.forum);
    }
    setState(() {
      isFavourite = !isFavourite;
    });
  }
}
