import 'dart:collection';

import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/data/entity/topic.dart';
import 'package:flutter_nga/data/entity/topic_detail.dart';
import 'package:flutter_nga/ui/page/reply/publish_reply.dart';
import 'package:flutter_nga/ui/page/topic/topic_reply_item_widget.dart';
import 'package:flutter_nga/utils/code_utils.dart';
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
  List<Reply> _commentList = [];
  Set<Group> _groupSet = HashSet();
  Set<Medal> _medalSet = HashSet();

  RefreshController _refreshController;

  int _maxPage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(CodeUtils.unescapeHtml(widget.topic.subject))),
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
          _userList.clear();
          _userList.addAll(data.userList.values);
          _groupSet.clear();
          _groupSet.addAll(data.groupList.values);
          _medalSet.clear();
          _medalSet.addAll(data.medalList.values);
          _replyList.clear();
          _commentList.clear();
          data.replyList.values.forEach((reply) {
            if (reply.tid == null) {
              Reply comment = _commentList
                  .firstWhere((comment) => comment.pid == reply.pid);
              if (comment != null) {
                reply.merge(comment);
              }
            }
            _replyList.add(reply);
            _commentList.addAll(reply.commentList);
          });
        });
      } on NoSuchMethodError catch (error) {
        throw error;
      } on TypeError catch (error) {
        throw error;
      } catch (err) {
        _refreshController.sendBack(true, RefreshStatus.failed);
        if (err != null) {
          Fluttertoast.showToast(
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
          _userList.addAll(data.userList.values);
          _groupSet.addAll(data.groupList.values);
          _medalSet.addAll(data.medalList.values);
          data.replyList.values.forEach((reply) {
            if (reply.tid == null) {
              Reply comment = _commentList
                  .firstWhere((comment) => comment.pid == reply.pid);
              if (comment != null) {
                reply.merge(comment);
              }
            }
            _replyList.add(reply);
            _commentList.addAll(reply.commentList);
          });
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
        Fluttertoast.showToast(
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

    List<Medal> medalList = [];
    if (user.medal != null && user.medal.isNotEmpty) {
      user.medal.split(",").forEach((id) {
        for (var m in _medalSet) {
          if (id == m.id.toString()) {
            medalList.add(m);
            break;
          }
        }
      });
    }

    List<User> commentUserList = [];
    if (reply.commentList != null && reply.commentList.isNotEmpty) {
      reply.commentList.forEach((comment) {
        for (var user in _userList) {
          if (user.uid == comment.authorId) {
            commentUserList.add(user);
            break;
          }
        }
      });
    }
    return TopicReplyItemWidget(
      reply: reply,
      user: user,
      group: group,
      medalList: medalList,
      userList: commentUserList,
    );
  }
}
