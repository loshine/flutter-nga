import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_nga/store/forum/forum_detail_store.dart';
import 'package:flutter_nga/ui/widget/topic_list_item_widget.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ForumRecommendTopicListPage extends StatefulWidget {
  final int fid;
  final int type;

  const ForumRecommendTopicListPage(this.fid, {this.type, Key key})
      : assert(fid != null),
        super(key: key);

  @override
  _ForumRecommendTopicListState createState() =>
      _ForumRecommendTopicListState();
}

class _ForumRecommendTopicListState extends State<ForumRecommendTopicListPage> {
  final _store = ForumDetailStore();
  RefreshController _refreshController;

  @override
  void initState() {
    super.initState();
    _refreshController = RefreshController(initialRefresh: true);
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        return SmartRefresher(
          onLoading: _onLoading,
          controller: _refreshController,
          enablePullUp: _store.state.enablePullUp,
          onRefresh: _onRefresh,
          child: ListView.builder(
            physics: BouncingScrollPhysics(),
            itemCount: _store.state.list.length,
            itemBuilder: (context, index) =>
                TopicListItemWidget(topic: _store.state.list[index]),
          ),
        );
      },
    );
  }

  _onRefresh() {
    _store.refresh(widget.fid, true, widget.type).catchError((err) {
      _refreshController.refreshFailed();
      Fluttertoast.showToast(
        msg: err.message,
        gravity: ToastGravity.CENTER,
      );
    }).whenComplete(
        () => _refreshController.refreshCompleted(resetFooterState: true));
  }

  _onLoading() async {
    _store.loadMore(widget.fid, true, widget.type).then((state) {
      if (state.page + 1 < state.maxPage) {
        _refreshController.loadComplete();
      } else {
        _refreshController.loadNoData();
      }
    }).catchError((_) => _refreshController.loadFailed());
  }
}
