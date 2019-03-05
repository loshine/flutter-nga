import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/data/entity/forum.dart';
import 'package:flutter_nga/data/entity/topic.dart';
import 'package:flutter_nga/ui/page/favourite_forum_group/favourite_forum_group.dart';
import 'package:flutter_nga/ui/page/topic_list/topic_list_item_widget.dart';
import 'package:fluttertoast/fluttertoast.dart';

class TopicListPage extends StatefulWidget {
  const TopicListPage({this.name, this.fid, Key key})
      : assert(fid != null),
        super(key: key);

  final String name;
  final int fid;

  @override
  _TopicListState createState() => _TopicListState();
}

class _TopicListState extends State<TopicListPage> {
  bool _isFavourite = false;
  bool _fabVisible = true;

  var _page = 1;
  List<Topic> _topicList = [];

  int _maxPage;
  ScrollController _scrollController;
  final _refreshKey = GlobalKey<RefreshIndicatorState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
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
        return RefreshIndicator(
          key: _refreshKey,
          child: ListView.builder(
            controller: _scrollController,
            itemCount: _topicList.length,
            itemBuilder: (context, index) =>
                TopicListItemWidget(topic: _topicList[index]),
          ),
          onRefresh: _onRefresh,
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
    );
  }

  @override
  void initState() {
    Data()
        .forumRepository
        .isFavourite(Forum(widget.fid, widget.name))
        .then((isFavourite) {
      setState(() {
        this._isFavourite = isFavourite;
      });
    });
    super.initState();
    _scrollController = ScrollController()
      ..addListener(() {
        if (_scrollController.position.userScrollDirection ==
            ScrollDirection.reverse) {
          debugPrint("reverse");
          if (_fabVisible) setState(() => _fabVisible = false);
        }
        if (_scrollController.position.userScrollDirection ==
            ScrollDirection.forward) {
          debugPrint("forward");
          if (!_fabVisible) setState(() => _fabVisible = true);
        }
      });
    Future.delayed(const Duration(milliseconds: 0)).then((val) {
      _refreshKey.currentState.show();
    });
  }

  _switchFavourite() async {
    if (_isFavourite) {
      await Data()
          .forumRepository
          .deleteFavourite(Forum(widget.fid, widget.name));
    } else {
      await Data()
          .forumRepository
          .saveFavourite(Forum(widget.fid, widget.name));
    }
    FavouriteForumGroupBloc().onChanged();
    setState(() {
      _isFavourite = !_isFavourite;
    });
  }

  Future<void> _onRefresh() async {
    try {
      _page = 1;
      TopicListData data =
          await Data().topicRepository.getTopicList(widget.fid, _page);
      _page++;
      _maxPage = data.maxPage;
      setState(() {
        _topicList.clear();
        _topicList.addAll(data.topicList.values);
      });
    } catch (err) {
      Fluttertoast.showToast(
        msg: err.message,
        gravity: ToastGravity.CENTER,
      );
    }
  }

  Future<bool> _onLoadMore() async {
    if (_page >= _maxPage) {
      return false;
    }
    try {
      TopicListData data =
          await Data().topicRepository.getTopicList(widget.fid, _page);
      _page++;
      _maxPage = data.maxPage;
      setState(() => _topicList.addAll(data.topicList.values));
      return true;
    } catch (err) {
      Fluttertoast.showToast(
        msg: err.message,
        gravity: ToastGravity.CENTER,
      );
    }
    return false;
  }
}
