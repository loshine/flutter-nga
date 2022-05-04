import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_nga/data/entity/topic_detail.dart';
import 'package:flutter_nga/data/entity/user.dart';
import 'package:flutter_nga/store/topic/topic_detail_store.dart';
import 'package:flutter_nga/store/topic/topic_single_page_store.dart';
import 'package:flutter_nga/ui/page/topic_detail/topic_reply_item_widget.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class TopicSinglePage extends StatefulWidget {
  const TopicSinglePage({
    required this.tid,
    required this.page,
    this.authorid,
    Key? key,
  }) : super(key: key);

  final int tid;
  final int page;
  final int? authorid;

  @override
  _TopicSingleState createState() => _TopicSingleState();
}

class _TopicSingleState extends State<TopicSinglePage> {
  final _refreshController = RefreshController(initialRefresh: true);
  final _store = TopicSinglePageStore();

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (_) {
      return SmartRefresher(
        onRefresh: _onRefresh,
        enablePullUp: false,
        controller: _refreshController,
        physics: ClampingScrollPhysics(),
        child: ListView.builder(
          itemCount: _store.state.replyList.length,
          itemBuilder: (context, position) => _buildListItem(context, position),
        ),
      );
    });
  }

  _onRefresh() {
    map.clear();
    final detailStore = Provider.of<TopicDetailStore>(context, listen: false);
    _store
        .refresh(context, widget.tid, widget.page, widget.authorid)
        .then((state) {
      detailStore.setMaxPage(state.maxPage);
      detailStore.setMaxFloor(state.maxFloor);
      detailStore.setTopic(state.topic);
    }).whenComplete(() {
      _refreshController.refreshCompleted();
    }).catchError((err) {
      _refreshController.loadFailed();
      Fluttertoast.showToast(msg: err.message);
    });
  }

  final map = <String, Widget>{};

  Widget _buildListItem(BuildContext context, int position) {
    final reply = _store.state.replyList[position];
    if (position == 0 &&
        _store.state.page == 1 &&
        _store.state.hotReplyList.isNotEmpty) {
      // 显示热评
      return Column(
        children: [_buildReplyWidget(context, reply)]..addAll(_store
            .state.hotReplyList
            .map((e) => _buildReplyWidget(context, e, hot: true))),
      );
    } else {
      return _buildReplyWidget(context, reply);
    }
  }

  Widget _buildReplyWidget(BuildContext context, Reply reply,
      {bool hot = false}) {
    final uniqueId = "${reply.pid}_${reply.tid}_${reply.fid}_$hot";
    var widget = map[uniqueId];
    if (widget != null) {
      return widget;
    } else {
      User? user;
      for (var u in _store.state.userList) {
        if (u.uid == reply.authorId) {
          user = u;
          break;
        }
      }
      if (user == null) {
        user = User();
      }

      Group? group;
      if (user.memberId != null) {
        for (var g in _store.state.groupSet) {
          if (g.id == user.memberId) {
            group = g;
            break;
          }
        }
      }

      List<Medal> medalList = [];
      if (user.medal != null && user.medal!.isNotEmpty) {
        user.medal!.split(",").forEach((id) {
          for (var m in _store.state.medalSet) {
            if (id == m.id.toString()) {
              medalList.add(m);
              break;
            }
          }
        });
      }

      List<User> commentUserList = [];
      if (reply.commentList.isNotEmpty) {
        reply.commentList.forEach((comment) {
          for (var user in _store.state.userList) {
            if (user.uid == comment.authorId) {
              commentUserList.add(user);
              break;
            }
          }
        });
      }
      widget = TopicReplyItemWidget(
        reply: reply,
        user: user,
        group: group,
        medalList: medalList,
        userList: commentUserList,
        hot: hot,
      );
      map[uniqueId] = widget;
      return widget;
    }
  }
}
