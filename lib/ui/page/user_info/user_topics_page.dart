import 'package:flutter/material.dart';
import 'package:flutter_nga/providers/user/user_topics_provider.dart';
import 'package:flutter_nga/ui/widget/topic_list_item_widget.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class UserTopicsPage extends ConsumerStatefulWidget {
  final int uid;
  final String username;

  const UserTopicsPage({
    Key? key,
    required this.uid,
    required this.username,
  }) : super(key: key);

  @override
  ConsumerState<UserTopicsPage> createState() => _UserTopicsPageState();
}

class _UserTopicsPageState extends ConsumerState<UserTopicsPage> {
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
    final state = ref.watch(userTopicsProvider);
    final notifier = ref.read(userTopicsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text("${widget.username}发布的主题")),
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

  void _onRefresh(UserTopicsNotifier notifier) {
    notifier.refresh(widget.uid).catchError((err) {
      _refreshController.refreshFailed();
      Fluttertoast.showToast(msg: err.message);
      return ref.read(userTopicsProvider);
    }).whenComplete(
        () => _refreshController.refreshCompleted(resetFooterState: true));
  }

  void _onLoading(UserTopicsNotifier notifier) async {
    notifier.loadMore(widget.uid).then((state) {
      if (state.page + 1 < state.maxPage) {
        _refreshController.loadComplete();
      } else {
        _refreshController.loadNoData();
      }
    }).catchError((_) {
      _refreshController.loadFailed();
    });
  }
}
