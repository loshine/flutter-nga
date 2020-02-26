import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_nga/data/entity/topic_detail.dart';
import 'package:flutter_nga/store/topic_single_page_store.dart';
import 'package:flutter_nga/ui/page/topic_detail/topic_reply_item_widget.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

typedef LoadCompleteCallback = void Function(int, List<Reply>);
typedef TotalCommentListCallback = List<Reply> Function();

class TopicSinglePage extends StatefulWidget {
  const TopicSinglePage({
    this.tid,
    this.page,
    this.onLoadComplete,
    this.totalCommentList,
    Key key,
  })  : assert(tid != null),
        assert(page != null),
        super(key: key);

  final int tid;
  final int page;
  final LoadCompleteCallback onLoadComplete;
  final List<Reply> totalCommentList;

  @override
  _TopicSingleState createState() => _TopicSingleState();
}

class _TopicSingleState extends State<TopicSinglePage> {
  RefreshController _refreshController;
  final _store = TopicSinglePageStore();

  @override
  void initState() {
    super.initState();
    if (widget.totalCommentList != null) {
      _store.totalCommentList.addAll(widget.totalCommentList);
    }
    _refreshController = RefreshController();
    Future.delayed(const Duration()).then((_) => _onRefresh());
  }

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
        child: ListView.builder(
          itemCount: _store.state.replyList.length,
          itemBuilder: (context, position) =>
              _buildListItem(context, _store.state.replyList[position]),
        ),
      );
    });
  }

  _onRefresh() {
    _store.refresh(widget.tid, widget.page).then((state) {
      if (widget.onLoadComplete != null) {
        widget.onLoadComplete(state.maxPage, state.commentList);
      }
    }).catchError((err) {
      _refreshController.loadFailed();
      Fluttertoast.showToast(
        msg: err.message,
        gravity: ToastGravity.CENTER,
      );
    }).whenComplete(() {
      _refreshController.refreshCompleted();
    });
  }

  Widget _buildListItem(BuildContext context, Reply reply) {
    User user;
    for (var u in _store.state.userList) {
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
      for (var g in _store.state.groupSet) {
        if (g.id == user.memberId) {
          group = g;
          break;
        }
      }
    }

    List<Medal> medalList = [];
    if (user.medal != null && user.medal.isNotEmpty) {
      user.medal.split(",").forEach((id) {
        for (var m in _store.state.medalSet) {
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
        for (var user in _store.state.userList) {
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
