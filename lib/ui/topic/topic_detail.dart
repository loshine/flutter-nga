import 'dart:collection';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/data/entity/topic.dart';
import 'package:flutter_nga/data/entity/topic_detail.dart';
import 'package:flutter_nga/ui/reply/publish_reply.dart';
import 'package:flutter_nga/utils/dimen.dart';
import 'package:flutter_nga/utils/palette.dart';
import 'package:fluttertoast/fluttertoast.dart';
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

  int _maxPage;

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
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => PublishReplyPage(widget.topic)));
              },
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
        _maxPage = data.getMaxPage();
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
      } on NoSuchMethodError catch (error) {
        throw error;
      } on TypeError catch (error) {
        throw error;
      } catch (err, stackTrace) {
        debugPrint(err.toString());
        debugPrint(stackTrace.toString());
        _refreshController.sendBack(true, RefreshStatus.failed);
        if (err != null) {
//          Scaffold.of(context).showSnackBar(
//            SnackBar(content: Text(err.message)),
//          );
          Fluttertoast.instance.showToast(
            msg: err.message,
            gravity: ToastGravity.CENTER,
          );
        }
      }
    } else {
      //footerIndicator Callback
      if (_page >= _maxPage) {
        _refreshController.sendBack(false, RefreshStatus.noMore);
        return;
      }
      try {
        TopicDetailData data = await Data()
            .topicRepository
            .getTopicDetail(widget.topic.tid, _page);
        _page++;
        _maxPage = data.getMaxPage();
        _refreshController.sendBack(false, RefreshStatus.canRefresh);
        setState(() {
          _replyList.addAll(data.replyList.values);
          _userList.addAll(data.userList.values);
          _groupSet.addAll(data.groupList.values);
        });
      } on NoSuchMethodError catch (error) {
        throw error;
      } on TypeError catch (error) {
        throw error;
      } catch (err) {
        _refreshController.sendBack(false, RefreshStatus.failed);
//        Scaffold.of(context).showSnackBar(
//          SnackBar(content: Text(err.message)),
//        );
        Fluttertoast.instance.showToast(
          msg: err.message,
          gravity: ToastGravity.CENTER,
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
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(16),
              child: ClipOval(child: _getAvatar()),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(0, 8, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            user.getShowName(),
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                        Text(
                          "[${reply.lou} 楼]",
                          style: TextStyle(
                            color: Palette.colorTextSecondary,
                            fontSize: Dimen.caption,
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                      child: Row(
                        children: [
                          Text(
                            "级别: ${group == null ? "" : group.name}",
                            style: TextStyle(
                              color: Palette.colorTextSecondary,
                              fontSize: Dimen.caption,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(16, 0, 0, 0),
                            child: Text(
                              "威望: ${user.rvrc / 10.0 ?? "0.0"}",
                              style: TextStyle(
                                color: Palette.colorTextSecondary,
                                fontSize: Dimen.caption,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(16, 0, 0, 0),
                            child: Text(
                              "发帖: ${user.postNum}",
                              style: TextStyle(
                                color: Palette.colorTextSecondary,
                                fontSize: Dimen.caption,
                              ),
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
        Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: _RichTextWidget(text: reply.content),
        ),
        Divider(
          color: Palette.colorDivider,
          height: 1,
        ),
      ],
    );
  }

  Widget _getAvatar() {
    return user.avatar != null
        ? CachedNetworkImage(
            width: 48,
            height: 48,
            fit: BoxFit.cover,
            imageUrl: user.avatar,
            placeholder: Image.asset(
              'images/default_forum_icon.png',
              width: 48,
              height: 48,
            ),
            errorWidget: Image.asset(
              'images/default_forum_icon.png',
              width: 48,
              height: 48,
            ),
          )
        : Image.asset(
            'images/default_forum_icon.png',
            width: 48,
            height: 48,
          );
  }
}

class _RichTextWidget extends StatelessWidget {
  const _RichTextWidget({this.text, Key key}) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: RichText(
        textAlign: TextAlign.left,
        text: TextSpan(
          style: DefaultTextStyle.of(context).style,
          children: <TextSpan>[
            TextSpan(text: text),
          ],
        ),
      ),
    );
  }
}
