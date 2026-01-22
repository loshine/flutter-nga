import 'package:flutter/material.dart';
import 'package:flutter_nga/providers/message/conversation_list_provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'conversation_item_widget.dart';

class ConversationListPage extends ConsumerStatefulWidget {
  const ConversationListPage({Key? key}) : super(key: key);

  @override
  ConsumerState<ConversationListPage> createState() =>
      _ConversationListState();
}

class _ConversationListState extends ConsumerState<ConversationListPage> {
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
    final state = ref.watch(conversationListProvider);
    final notifier = ref.read(conversationListProvider.notifier);

    return SmartRefresher(
      onLoading: () => _onLoading(notifier),
      controller: _refreshController,
      enablePullUp: state.enablePullUp,
      onRefresh: () => _onRefresh(notifier),
      child: ListView.builder(
        itemCount: state.list.length,
        itemBuilder: (context, index) =>
            ConversationItemWidget(conversation: state.list[index]),
      ),
    );
  }

  void _onRefresh(ConversationListNotifier notifier) {
    notifier.refresh().catchError((err) {
      _refreshController.refreshFailed();
      Fluttertoast.showToast(
        msg: err.toString(),
      );
      return ref.read(conversationListProvider);
    }).whenComplete(
        () => _refreshController.refreshCompleted(resetFooterState: true));
  }

  void _onLoading(ConversationListNotifier notifier) async {
    notifier.loadMore().then((state) {
      if (state.enablePullUp) {
        _refreshController.loadComplete();
      } else {
        _refreshController.loadNoData();
      }
    }).catchError((_) {
      _refreshController.loadFailed();
      return null;
    });
  }
}
