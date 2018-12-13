import 'package:flutter/material.dart';
import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/data/entity/forum.dart';
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
    Data().topicRepository.getTopicList(widget.forum.fid, 1).then((list) {
      debugPrint(list.toString());
      setState(() {});
    });
    super.initState();
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
