import 'dart:async';

import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_nga/data/entity/topic_detail.dart';
import 'package:flutter_nga/store/topic_detail_store.dart';
import 'package:flutter_nga/ui/page/topic_detail/topic_reply_item_widget.dart';
import 'package:flutter_nga/utils/code_utils.dart' as codeUtils;
import 'package:flutter_nga/utils/route.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class TopicDetailPage extends StatefulWidget {
  const TopicDetailPage(this.tid, this.fid, {this.subject, Key key})
      : super(key: key);

  final int tid;
  final int fid;
  final String subject;

  @override
  _TopicDetailState createState() => _TopicDetailState();
}

class _TopicDetailState extends State<TopicDetailPage> {
  bool _fabVisible = true;

  final _store = TopicDetailStore();
  RefreshController _refreshController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(codeUtils.unescapeHtml(widget.subject))),
      body: Observer(
        builder: (_) {
          return SmartRefresher(
            onRefresh: _onRefresh,
            enablePullUp: _store.state.enablePullUp,
            controller: _refreshController,
            onLoading: _onLoading,
            child: ListView.builder(
              itemCount: _store.state.replyList.length,
              itemBuilder: (context, position) =>
                  _buildListItem(context, position, _store.state),
            ),
          );
        },
      ),
      floatingActionButton: _fabVisible
          ? FloatingActionButton(
              onPressed: () => Routes.navigateTo(context,
                  "${Routes.TOPIC_PUBLISH}?tid=${widget.tid}&fid=${widget.fid}"),
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
    super.initState();
    _refreshController = RefreshController();
    Future.delayed(const Duration()).then((_) {
      _refreshController.requestRefresh();
      _refreshController.position.addListener(_scrollListener);
    });
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  _onRefresh() {
    _store.refresh(widget.tid).catchError((err) {
      _refreshController.loadFailed();
      Fluttertoast.showToast(
        msg: err.message,
        gravity: ToastGravity.CENTER,
      );
    }).whenComplete(
        () => _refreshController.refreshCompleted(resetFooterState: true));
  }

  _onLoading() {
    _store.loadMore(widget.tid).catchError((err) {
      _refreshController.loadFailed();
      Fluttertoast.showToast(
        msg: err.message,
        gravity: ToastGravity.CENTER,
      );
    }).whenComplete(() => _refreshController.loadComplete());
  }

  _scrollListener() {
    if (_refreshController.position.userScrollDirection ==
        ScrollDirection.reverse) {
      if (_fabVisible) {
        setState(() => _fabVisible = false);
      }
    }
    if (_refreshController.position.userScrollDirection ==
        ScrollDirection.forward) {
      if (!_fabVisible) {
        setState(() => _fabVisible = true);
      }
    }
  }

  Widget _buildListItem(
      BuildContext context, int index, TopicDetailStoreData state) {
    final reply = state.replyList[index];
    User user;
    for (var u in state.userList) {
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
      for (var g in state.groupSet) {
        if (g.id == user.memberId) {
          group = g;
          break;
        }
      }
    }

    List<Medal> medalList = [];
    if (user.medal != null && user.medal.isNotEmpty) {
      user.medal.split(",").forEach((id) {
        for (var m in state.medalSet) {
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
        for (var user in state.userList) {
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
