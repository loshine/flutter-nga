import 'package:flutter/material.dart';
import 'package:flutter_nga/providers/message/conversation_detail_provider.dart';
import 'package:flutter_nga/utils/route.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'message_item_widget.dart';

class ConversationDetailPage extends ConsumerStatefulWidget {
  final int? mid;

  const ConversationDetailPage({Key? key, this.mid}) : super(key: key);

  @override
  ConsumerState<ConversationDetailPage> createState() =>
      _ConversationDetailState();
}

class _ConversationDetailState extends ConsumerState<ConversationDetailPage> {
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
    final state = ref.watch(conversationDetailProvider);
    final notifier = ref.read(conversationDetailProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text('消息详情'),
      ),
      body: SmartRefresher(
        onLoading: () => _onLoading(notifier),
        controller: _refreshController,
        enablePullUp: state.enablePullUp,
        onRefresh: () => _onRefresh(notifier),
        child: ListView.builder(
          itemCount: state.list.length,
          itemBuilder: (context, index) =>
              MessageItemWidget(message: state.list[index]),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: '回复',
        onPressed: () => Routes.navigateTo(
          context,
          "${Routes.SEND_MESSAGE}?mid=${widget.mid}",
        ),
        child: Icon(
          Icons.reply,
          color: Colors.white,
        ),
      ),
    );
  }

  void _onRefresh(ConversationDetailNotifier notifier) {
    notifier.refresh(widget.mid).catchError((err) {
      _refreshController.refreshFailed();
      Fluttertoast.showToast(
        msg: err.toString(),
      );
      return ref.read(conversationDetailProvider);
    }).whenComplete(
        () => _refreshController.refreshCompleted(resetFooterState: true));
  }

  void _onLoading(ConversationDetailNotifier notifier) async {
    notifier.loadMore(widget.mid).then((state) {
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
