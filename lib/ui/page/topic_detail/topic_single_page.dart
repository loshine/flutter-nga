import 'package:flutter/material.dart';
import 'package:flutter_nga/data/entity/topic_detail.dart';
import 'package:flutter_nga/data/entity/user.dart';
import 'package:flutter_nga/providers/topic/topic_detail_provider.dart';
import 'package:flutter_nga/providers/topic/topic_single_page_provider.dart';
import 'package:flutter_nga/ui/page/topic_detail/topic_reply_item_widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class TopicSinglePage extends ConsumerStatefulWidget {
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
  ConsumerState<TopicSinglePage> createState() => _TopicSingleState();
}

class _TopicSingleState extends ConsumerState<TopicSinglePage> {
  final _refreshController = RefreshController(initialRefresh: true);

  TopicSinglePageKey get _providerKey => TopicSinglePageKey(
        tid: widget.tid,
        page: widget.page,
        authorid: widget.authorid,
      );

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(topicSinglePageProvider(_providerKey));
    return SmartRefresher(
      onRefresh: _onRefresh,
      enablePullUp: false,
      controller: _refreshController,
      physics: ClampingScrollPhysics(),
      child: ListView.builder(
        itemCount: state.replyList.length,
        itemBuilder: (context, position) => _buildListItem(context, position, state),
      ),
    );
  }

  _onRefresh() {
    map.clear();
    final notifier = ref.read(topicSinglePageProvider(_providerKey).notifier);
    final detailNotifier = ref.read(topicDetailProvider.notifier);
    notifier
        .refresh(widget.tid, widget.page, widget.authorid)
        .then((state) {
      detailNotifier.setMaxPage(state.maxPage);
      detailNotifier.setMaxFloor(state.maxFloor);
      detailNotifier.setTopic(state.topic);
    }).whenComplete(() {
      _refreshController.refreshCompleted();
    }).catchError((err) {
      _refreshController.loadFailed();
      Fluttertoast.showToast(msg: err.message);
    });
  }

  final map = <String, Widget>{};

  Widget _buildListItem(BuildContext context, int position, TopicSinglePageState state) {
    final reply = state.replyList[position];
    if (position == 0 &&
        state.page == 1 &&
        state.hotReplyList.isNotEmpty) {
      // 显示热评
      return Column(
        children: [_buildReplyWidget(context, reply, state)]..addAll(state
            .hotReplyList
            .map((e) => _buildReplyWidget(context, e, state, hot: true))),
      );
    } else {
      return _buildReplyWidget(context, reply, state);
    }
  }

  Widget _buildReplyWidget(BuildContext context, Reply reply, TopicSinglePageState state,
      {bool hot = false}) {
    final uniqueId = "${reply.pid}_${reply.tid}_${reply.fid}_$hot";
    var widget = map[uniqueId];
    if (widget != null) {
      return widget;
    } else {
      User? user;
      for (var u in state.userList) {
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
        for (var g in state.groupSet) {
          if (g.id == user.memberId) {
            group = g;
            break;
          }
        }
      }

      List<Medal> medalList = [];
      if (user.medal != null && user.medal!.isNotEmpty) {
        user.medal!.split(",").forEach((id) {
          for (var m in state.medalSet) {
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
          for (var user in state.userList) {
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
