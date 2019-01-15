import 'dart:collection';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/data/entity/topic.dart';
import 'package:flutter_nga/data/entity/topic_detail.dart';
import 'package:flutter_nga/utils/code_utils.dart';
import 'package:flutter_nga/utils/palette.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class TopicDetailPage extends StatefulWidget {
  const TopicDetailPage(this.topic, {Key key}) : super(key: key);

  final Topic topic;

  @override
  _TopicDetailState createState() => _TopicDetailState();
}

class _TopicDetailState extends State<TopicDetailPage> {
  bool _enablePullUp = false;
  bool _fabVisible = true;

  var _page = 1;
  List<Reply> _replyList = [];
  List<User> _userList = [];
  Set<Group> _groupSet = HashSet();

  RefreshController _refreshController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.topic.subject)),
      body: Builder(builder: (BuildContext context) {
        return SmartRefresher(
          enablePullDown: true,
          enablePullUp: _enablePullUp,
          controller: _refreshController,
          onRefresh: (b) => _onRefresh(context, b),
          child: ListView.builder(
            itemCount: _replyList.length,
            itemBuilder: _buildListItem,
          ),
        );
      }),
      floatingActionButton: _fabVisible
          ? FloatingActionButton(
              onPressed: null,
              child: Icon(
                CommunityMaterialIcons.comment,
                color: Colors.white,
              ),
            )
          : null,
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

  _onRefresh(BuildContext context, bool up) async {
    if (up) {
      //headerIndicator callback
      try {
        _page = 1;
        TopicDetailData data = await Data()
            .topicRepository
            .getTopicDetail(widget.topic.tid, _page);
        _page++;
        _refreshController.sendBack(true, RefreshStatus.completed);
        setState(() {
          if (!_enablePullUp) {
            _enablePullUp = true;
          }
          _replyList.clear();
          _replyList.addAll(data.replyList.values);
          _userList.clear();
          _userList.addAll(data.userList.values);
          _groupSet.clear();
          _groupSet.addAll(data.groupList.values);
        });
      } catch (err) {
        debugPrint(err.toString());
        _refreshController.sendBack(true, RefreshStatus.failed);
        Scaffold.of(context).showSnackBar(
          SnackBar(content: Text(err.message)),
        );
      }
    } else {
      //footerIndicator Callback
      try {
        TopicDetailData data = await Data()
            .topicRepository
            .getTopicDetail(widget.topic.tid, _page);
        _page++;
        _refreshController.sendBack(false, RefreshStatus.canRefresh);
        setState(() {
          _replyList.addAll(data.replyList.values);
          _userList.addAll(data.userList.values);
          _groupSet.addAll(data.groupList.values);
        });
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

  Widget _buildListItem(BuildContext context, int index) {
    final reply = _replyList[index];
    User user;
    for (var u in _userList) {
      if (u.uid == reply.authorId) {
        user = u;
        break;
      }
    }
    if (user == null) {
      user = User();
    }

    Group group;
    if (user.memberId != null) {
      for (var g in _groupSet) {
        if (g.id == user.memberId) {
          group = g;
          break;
        }
      }
    }
    return _TopicReplyItemWidget(reply: reply, user: user, group: group);
  }
}

class _TopicReplyItemWidget extends StatelessWidget {
  final Reply reply;
  final User user;
  final Group group;

  const _TopicReplyItemWidget({Key key, this.reply, this.user, this.group})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: ClipOval(
                    child: CachedNetworkImage(
                      width: 32,
                      height: 32,
                      imageUrl: user.avatar,
                      fit: BoxFit.cover,
                      placeholder: Image.asset(
                        'images/default_forum_icon.png',
                        width: 32,
                        height: 32,
                      ),
                      errorWidget: Image.asset(
                        'images/default_forum_icon.png',
                        width: 32,
                        height: 32,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16, 0, 0, 0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(child: Text(user.username)),
                            Text(
                              "[${reply.lou} 楼]",
                              style: TextStyle(
                                color: Palette.colorTextSecondary,
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(0, 4, 0, 0),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  group == null ? "" : group.name,
                                  style: TextStyle(
                                    color: Palette.colorTextSecondary,
                                  ),
                                ),
                              ),
                              Text(
                                CodeUtils.toPostDateTimeString(
                                    DateTime.fromMillisecondsSinceEpoch(
                                        reply.postDateTimestamp * 1000)),
                                style: TextStyle(
                                  color: Palette.colorTextSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Divider(
          color: Palette.colorDivider,
          height: 1,
        )
      ],
    );
  }
}
