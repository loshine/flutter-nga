import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/data/entity/topic.dart';
import 'package:flutter_nga/data/entity/topic_detail.dart';
import "package:pull_to_refresh/pull_to_refresh.dart";

class TopicDetailPage extends StatefulWidget {
  TopicDetailPage(this.topic, {Key key}) : super(key: key);

  final Topic topic;

  @override
  _TopicDetailState createState() {
    return _TopicDetailState();
  }
}

class _TopicDetailState extends State<TopicDetailPage> {
  bool _isFavourite = false;
  bool _defaultFavourite = false;
  bool _enablePullUp = false;
  bool _fabVisible = true;

  var _page = 1;
  List<Reply> _replyList = [];

  RefreshController _refreshController;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, _defaultFavourite != _isFavourite);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.topic.subject),
          actions: <Widget>[
            IconButton(
              icon: Icon(
                _isFavourite ? Icons.star : Icons.star_border,
                color: Colors.white,
              ),
              onPressed: () => _switchFavourite(),
            ),
          ],
        ),
        body: Builder(builder: (BuildContext context) {
          return SmartRefresher(
            enablePullDown: true,
            enablePullUp: _enablePullUp,
            controller: _refreshController,
            onRefresh: (b) => _onRefresh(context, b),
            child: ListView.builder(
              itemCount: _replyList.length,
              itemBuilder: (context, index) => _buildListItemWidget(_replyList[index]),
            ),
          );
        }),
        floatingActionButton: _fabVisible
            ? FloatingActionButton(
                onPressed: null,
                child: Icon(
                  CommunityMaterialIcons.pencil,
                  color: Colors.white,
                ),
              )
            : null,
      ),
    );
  }

  @override
  void initState() {
    _refreshController = RefreshController();
    Future.delayed(const Duration(milliseconds: 0)).then((val) {
      setState(() {
        _refreshController.sendBack(true, RefreshStatus.refreshing);
      });
      _refreshController.scrollController.addListener(_scrollListener);
      _refreshController.requestRefresh(true);
    });
    super.initState();
  }

  @override
  void dispose() {
    _refreshController.scrollController.removeListener(_scrollListener);
    super.dispose();
  }

  Widget _buildListItemWidget(Reply reply) {
    return GestureDetector(child: Column());
  }

  _switchFavourite() async {}

  _onRefresh(BuildContext context, bool up) async {
    if (up) {
      //headerIndicator callback
      try {
        _page = 1;
        TopicDetailData data = await Data().topicRepository.getTopicDetail(widget.topic.tid, _page);
        _page++;
        _refreshController.sendBack(true, RefreshStatus.completed);
        setState(() {
          if (!_enablePullUp) {
            _enablePullUp = true;
          }
          _replyList.clear();
          _replyList.addAll(data.replyList.values);
        });
      } catch (err) {
        _refreshController.sendBack(true, RefreshStatus.failed);
        Scaffold.of(context).showSnackBar(
          SnackBar(content: Text(err.message)),
        );
      }
    } else {
      //footerIndicator Callback
      try {
        TopicDetailData data = await Data().topicRepository.getTopicDetail(widget.topic.tid, _page);
        _page++;
        _refreshController.sendBack(false, RefreshStatus.canRefresh);
        setState(() => _replyList.addAll(data.replyList.values));
      } catch (err) {
        _refreshController.sendBack(false, RefreshStatus.failed);
        Scaffold.of(context).showSnackBar(
          SnackBar(content: Text(err.message)),
        );
      }
    }
  }

  _scrollListener() {
    if (_refreshController.scrollController.position.userScrollDirection == ScrollDirection.reverse) {
      if (_fabVisible) {
        setState(() => _fabVisible = false);
      }
    }
    if (_refreshController.scrollController.position.userScrollDirection == ScrollDirection.forward) {
      if (!_fabVisible) {
        setState(() => _fabVisible = true);
      }
    }
  }
}
