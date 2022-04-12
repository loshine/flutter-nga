import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_nga/store/user/user_replies_store.dart';
import 'package:flutter_nga/ui/widget/topic_list_item_widget.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class UserRepliesPage extends StatefulWidget {
  final int uid;
  final String username;

  const UserRepliesPage({
    Key? key,
    required this.uid,
    required this.username,
  }) : super(key: key);

  @override
  _UserRepliesPageState createState() => _UserRepliesPageState();
}

class _UserRepliesPageState extends State<UserRepliesPage> {
  final _store = UserRepliesStore();
  late RefreshController _refreshController;

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
    return Scaffold(
      appBar: AppBar(title: Text("${widget.username}发布的回复")),
      body: Observer(
        builder: (_) {
          return SmartRefresher(
            onLoading: _onLoading,
            controller: _refreshController,
            enablePullUp: _store.state.enablePullUp,
            onRefresh: _onRefresh,
            child: ListView.builder(
              itemCount: _store.state.list.length,
              itemBuilder: (context, index) =>
                  TopicListItemWidget(topic: _store.state.list[index]),
            ),
          );
        },
      ),
    );
  }

  _onRefresh() {
    _store.refresh(widget.uid).catchError((err) {
      _refreshController.refreshFailed();
      Fluttertoast.showToast(msg: err.message);
    }).whenComplete(
        () => _refreshController.refreshCompleted(resetFooterState: true));
  }

  _onLoading() async {
    _store.loadMore(widget.uid).then((state) {
      if (state.list.length == state.page * state.size) {
        _refreshController.loadComplete();
      } else {
        _refreshController.loadNoData();
      }
    }).catchError((err) {
      Fluttertoast.showToast(msg: err.message);
      debugPrintStack(stackTrace: err.stackTrace);
      _refreshController.loadFailed();
    });
  }
}
