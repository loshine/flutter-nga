import 'dart:async';

import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_nga/data/entity/topic.dart';
import 'package:flutter_nga/data/entity/topic_detail.dart';
import 'package:flutter_nga/ui/page/publish/publish_reply.dart';
import 'package:flutter_nga/ui/page/topic_detail/topic_detail_bloc.dart';
import 'package:flutter_nga/ui/page/topic_detail/topic_detail_state.dart';
import 'package:flutter_nga/ui/page/topic_detail/topic_reply_item_widget.dart';
import 'package:flutter_nga/utils/code_utils.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class TopicDetailPage extends StatefulWidget {
  const TopicDetailPage(this.topic, {Key key}) : super(key: key);

  final Topic topic;

  @override
  _TopicDetailState createState() => _TopicDetailState();
}

class _TopicDetailState extends State<TopicDetailPage> {
  bool _fabVisible = true;

  final _refreshController = RefreshController();
  final _refreshKey = GlobalKey<RefreshIndicatorState>();
  final _bloc = TopicDetailBloc();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: _bloc,
      builder: (_, TopicDetailState state) {
        return Scaffold(
          appBar:
              AppBar(title: Text(CodeUtils.unescapeHtml(widget.topic.subject))),
          body: RefreshIndicator(
            key: _refreshKey,
            onRefresh: _onRefresh,
            child: SmartRefresher(
              enablePullDown: false,
              enablePullUp: state.enablePullUp,
              enableOverScroll: false,
              controller: _refreshController,
              onRefresh: _onLoadMore,
              child: ListView.builder(
                itemCount: state.replyList.length,
                itemBuilder: (context, position) =>
                    _buildListItem(context, position, state),
              ),
            ),
          ),
          floatingActionButton: _fabVisible
              ? FloatingActionButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => PublishPage(topic: widget.topic)));
                  },
                  child: Icon(
                    CommunityMaterialIcons.comment,
                    color: Colors.white,
                  ),
                )
              : null,
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 0)).then((val) {
      // 进入的时候自动刷新
      _refreshKey.currentState.show();
      _refreshController.scrollController.addListener(_scrollListener);
    });
  }

  Future<void> _onRefresh() {
    final completer = Completer<void>();
    _bloc.onRefresh(widget.topic.tid, completer);
    return completer.future;
  }

  _onLoadMore(bool up) {
    _bloc.onLoadMore(widget.topic.tid, _refreshController);
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

  Widget _buildListItem(
      BuildContext context, int index, TopicDetailState state) {
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
