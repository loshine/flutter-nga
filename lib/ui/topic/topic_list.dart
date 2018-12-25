import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/data/entity/forum.dart';
import 'package:flutter_nga/data/entity/topic.dart';
import 'package:flutter_nga/utils/code_utils.dart';
import 'package:flutter_nga/utils/dimen.dart';
import 'package:flutter_nga/utils/palette.dart';
import "package:pull_to_refresh/pull_to_refresh.dart";
import 'package:timeago/timeago.dart' as timeago;

class TopicListPage extends StatefulWidget {
  TopicListPage(this.forum, {Key key}) : super(key: key);

  final Forum forum;

  @override
  _TopicListState createState() => _TopicListState();
}

class _TopicListState extends State<TopicListPage> {
  bool _isFavourite = false;
  bool _defaultFavourite = false;
  bool _enablePullUp = false;
  bool _fabVisible = true;

  var _page = 1;
  List<Topic> _topicList = [];

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
          title: Text(widget.forum.name),
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
              itemCount: _topicList.length,
              itemBuilder: (context, index) =>
                  _buildListItemWidget(_topicList[index]),
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
    Data().forumRepository.isFavourite(widget.forum).then((isFavourite) {
      setState(() {
        _defaultFavourite = isFavourite;
        this._isFavourite = isFavourite;
      });
    });
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

  Widget _buildListItemWidget(Topic topic) {
    return Column(
      children: <Widget>[
        Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: Column(
            children: [
              SizedBox(
                child: _getTitleText(topic),
                width: double.infinity,
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
                child: Row(
                  children: [
                    Padding(
                      child: Icon(
                        CommunityMaterialIcons.account,
                        size: 12,
                        color: Palette.colorIcon,
                      ),
                      padding: EdgeInsets.fromLTRB(0, 0, 8, 0),
                    ),
                    Expanded(
                      child: Text(
                        topic.author,
                        style: TextStyle(
                          fontSize: Dimen.caption,
                          color: Palette.colorTextSecondary,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 0, 16, 0),
                      child: (topic.hasAttachment()
                          ? Icon(
                              Icons.attachment,
                              size: 12,
                              color: Palette.colorIcon,
                            )
                          : null),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 0, 8, 0),
                      child: Icon(
                        CommunityMaterialIcons.comment,
                        size: 12,
                        color: Palette.colorIcon,
                      ),
                    ),
                    Text(
                      "${topic.replies}",
                      style: TextStyle(
                        fontSize: Dimen.caption,
                        color: Palette.colorTextSecondary,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(16, 0, 8, 0),
                      child: Icon(
                        CommunityMaterialIcons.clock,
                        size: 12,
                        color: Palette.colorIcon,
                      ),
                    ),
                    Text(
                      "${timeago.format(DateTime.fromMillisecondsSinceEpoch(topic.lastPost * 1000))}",
                      style: TextStyle(
                        fontSize: Dimen.caption,
                        color: Palette.colorTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Divider(height: 1),
      ],
    );
  }

  _switchFavourite() async {
    if (_isFavourite) {
      await Data().forumRepository.deleteFavourite(widget.forum);
    } else {
      await Data().forumRepository.saveFavourite(widget.forum);
    }
    setState(() {
      _isFavourite = !_isFavourite;
    });
  }

  _onRefresh(BuildContext context, bool up) async {
    if (up) {
      //headerIndicator callback
      try {
        _page = 1;
        TopicListData data =
            await Data().topicRepository.getTopicList(widget.forum.fid, _page);
        _page++;
        _refreshController.sendBack(true, RefreshStatus.completed);
        setState(() {
          if (!_enablePullUp) {
            _enablePullUp = true;
          }
          _topicList.clear();
          _topicList.addAll(data.topicList.values);
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
        TopicListData data =
            await Data().topicRepository.getTopicList(widget.forum.fid, _page);
        _page++;
        _refreshController.sendBack(false, RefreshStatus.canRefresh);
        setState(() => _topicList.addAll(data.topicList.values));
      } catch (err) {
        _refreshController.sendBack(false, RefreshStatus.failed);
        Scaffold.of(context).showSnackBar(
          SnackBar(content: Text(err.message)),
        );
      }
    }
  }

  _scrollListener() {
    if (_refreshController.scrollController.position.userScrollDirection ==
        ScrollDirection.reverse) {
      if (_fabVisible) {
        setState(() => _fabVisible = false);
      }
    }
    if (_refreshController.scrollController.position.userScrollDirection ==
        ScrollDirection.forward) {
      if (!_fabVisible) {
        setState(() => _fabVisible = true);
      }
    }
  }

  _getTitleText(Topic topic) {
    return RichText(
      text: TextSpan(
        // Note: Styles for TextSpans must be explicitly defined.
        // Child text spans will inherit styles from parent
        text: CodeUtils.unescapeHtml(topic.subject),
        style: TextStyle(
          fontSize: Dimen.subheading,
          color: topic.getSubjectColor(),
          fontWeight: topic.isBold() ? FontWeight.bold : null,
          fontStyle: topic.isItalic() ? FontStyle.italic : FontStyle.normal,
          decoration: topic.isUnderline() ? TextDecoration.underline : null,
        ),
        children: <TextSpan>[
          TextSpan(
            text: (topic.locked() ? " [锁定]" : ""),
            style: TextStyle(color: Palette.colorTextLock),
          ),
          TextSpan(
            text: (topic.isAssemble() ? " [合集]" : ""),
            style: TextStyle(color: Palette.colorTextAssemble),
          ),
        ],
      ),
    );
  }
}
