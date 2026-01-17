import 'package:flutter/material.dart';
import 'package:flutter_nga/providers/user/user_replies_provider.dart';
import 'package:flutter_nga/ui/widget/topic_list_item_widget.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class UserRepliesPage extends ConsumerStatefulWidget {
  final int uid;
  final String username;

  const UserRepliesPage({
    Key? key,
    required this.uid,
    required this.username,
  }) : super(key: key);

  @override
  ConsumerState<UserRepliesPage> createState() => _UserRepliesPageState();
}

class _UserRepliesPageState extends ConsumerState<UserRepliesPage> {
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
    final state = ref.watch(userRepliesProvider);
    final notifier = ref.read(userRepliesProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text("${widget.username}发布的回复")),
      body: SmartRefresher(
        onLoading: () => _onLoading(notifier),
        controller: _refreshController,
        enablePullUp: state.enablePullUp,
        onRefresh: () => _onRefresh(notifier),
        child: ListView.builder(
          itemCount: state.list.length,
          itemBuilder: (context, index) =>
              TopicListItemWidget(topic: state.list[index]),
        ),
      ),
    );
  }

  void _onRefresh(UserRepliesNotifier notifier) {
    notifier.refresh(widget.uid).catchError((err) {
      _refreshController.refreshFailed();
      Fluttertoast.showToast(msg: err.message);
      return ref.read(userRepliesProvider);
    }).whenComplete(
        () => _refreshController.refreshCompleted(resetFooterState: true));
  }

  void _onLoading(UserRepliesNotifier notifier) async {
    notifier.loadMore(widget.uid).then((state) {
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
