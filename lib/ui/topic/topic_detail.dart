import 'dart:collection';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/data/entity/topic.dart';
import 'package:flutter_nga/data/entity/topic_detail.dart';
import 'package:flutter_nga/ui/reply/publish_reply.dart';
import 'package:flutter_nga/utils/code_utils.dart';
import 'package:flutter_nga/utils/dimen.dart';
import 'package:flutter_nga/utils/palette.dart';
import 'package:flutter_nga/utils/parser/content_parser.dart';
import 'package:flutter_nga/utils/renderer.dart';
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
          _replyList.clear();
          _replyList.addAll(data.replyList.values);
          _userList.clear();
          _userList.addAll(data.userList.values);
          _groupSet.clear();
          _groupSet.addAll(data.groupList.values);
          _medalSet.clear();
          _medalSet.addAll(data.medalList.values);
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
          _medalSet.addAll(data.medalList.values);
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
    return _TopicReplyItemWidget(
      reply: reply,
      user: user,
      group: group,
      medalList: medalList,
    );
  }
}

class _TopicReplyItemWidget extends StatefulWidget {
  final Reply reply;
  final User user;
  final Group group;
  final List<Medal> medalList;

  const _TopicReplyItemWidget(
      {Key key, this.reply, this.user, this.group, this.medalList})
      : super(key: key);

  @override
  _TopicReplyItemState createState() => _TopicReplyItemState();
}

class _TopicReplyItemState extends State<_TopicReplyItemWidget> {
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
                            widget.user.getShowName(),
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                        Text(
                          "[${widget.reply.lou} 楼]",
                          style: TextStyle(
                            color: Palette.colorTextSecondary,
                            fontSize: Dimen.caption,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          "级别: ${widget.group == null ? "" : widget.group.name}",
                          style: TextStyle(
                            color: Palette.colorTextSecondary,
                            fontSize: Dimen.caption,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(16, 0, 0, 0),
                          child: Text(
                            "威望: ${widget.user.getShowReputation()}",
                            style: TextStyle(
                              color: Palette.colorTextSecondary,
                              fontSize: Dimen.caption,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(16, 0, 0, 0),
                          child: Text(
                            "发帖: ${widget.user.postNum ?? 0}",
                            style: TextStyle(
                              color: Palette.colorTextSecondary,
                              fontSize: Dimen.caption,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 6),
                      child: Wrap(children: _getMedalListWidgets()),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Html(
            data: NgaContentParser.parse(widget.reply.content),
            customRender: ngaRenderer(),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Palette.colorThumbBackground,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(8, 2, 8, 2),
                  child: Row(
                    children: <Widget>[
                      GestureDetector(
                        child: Icon(
                          CommunityMaterialIcons.thumb_up,
                          color: Colors.white,
                          size: 14,
                        ),
                        onTap: toggleLike,
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: Text(
                          "${widget.reply.score}",
                          style: TextStyle(
                            fontSize: Dimen.caption,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: GestureDetector(
                          onTap: toggleDislike,
                          child: Icon(
                            CommunityMaterialIcons.thumb_down,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Spacer(),
              Text(
                widget.reply.postDate,
                style: TextStyle(
                  fontSize: Dimen.caption,
                  color: Palette.colorTextSecondary,
                ),
              ),
            ],
          ),
        ),
        Divider(
          color: Palette.colorDivider,
          height: 1,
        ),
      ],
    );
  }

  Widget _getAvatar() {
    return widget.user.avatar != null
        ? CachedNetworkImage(
            width: 48,
            height: 48,
            fit: BoxFit.cover,
            imageUrl: widget.user.avatar,
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

  List<Widget> _getMedalListWidgets() {
    if (widget.medalList.isEmpty)
      return [
        Text(
          "-",
          style: TextStyle(
            fontSize: Dimen.caption,
            color: Palette.colorTextSecondary,
          ),
        )
      ];
    return widget.medalList.map((medal) {
      return Padding(
        padding: EdgeInsets.only(right: 4),
        child: CachedNetworkImage(
          imageUrl: "https://img4.nga.178.com/ngabbs/medal/${medal.image}",
          width: 12,
          height: 12,
          fit: BoxFit.cover,
        ),
      );
    }).toList();
  }

  toggleLike() async {
    try {
      final reaction = await Data()
          .topicRepository
          .likeReply(widget.reply.tid, widget.reply.pid);
      setState(() => widget.reply.score += reaction.countChange);
      Fluttertoast.instance.showToast(
        msg: reaction.message,
        gravity: ToastGravity.CENTER,
      );
    } catch (err) {
      print(err.toString());
      Fluttertoast.instance.showToast(
        msg: err.message,
        gravity: ToastGravity.CENTER,
      );
    }
  }

  toggleDislike() async {
    try {
      final reaction = await Data()
          .topicRepository
          .dislikeReply(widget.reply.tid, widget.reply.pid);
      setState(() => widget.reply.score += reaction.countChange);
      Fluttertoast.instance.showToast(
        msg: reaction.message,
        gravity: ToastGravity.CENTER,
      );
    } catch (err) {
      print(err.toString());
      Fluttertoast.instance.showToast(
        msg: err.message,
        gravity: ToastGravity.CENTER,
      );
    }
  }
}
