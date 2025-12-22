import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_nga/store/message/conversation_detail_store.dart';
import 'package:flutter_nga/utils/route.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'message_item_widget.dart';

class ConversationDetailPage extends StatefulWidget {
  final int? mid;

  const ConversationDetailPage({Key? key, this.mid}) : super(key: key);

  @override
  _ConversationDetailState createState() => _ConversationDetailState();
}

class _ConversationDetailState extends State<ConversationDetailPage> {
  final _store = ConversationDetailStore();
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
      appBar: AppBar(
        title: Text('消息详情'),
      ),
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
                  MessageItemWidget(message: _store.state.list[index]),
            ),
          );
        },
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

  _onRefresh() {
    _store.refresh(context, widget.mid).catchError((err) {
      _refreshController.refreshFailed();
      Fluttertoast.showToast(
        msg: err.toString(),
      );
    }).whenComplete(
        () => _refreshController.refreshCompleted(resetFooterState: true));
  }

  _onLoading() async {
    _store.loadMore(context, widget.mid).then((state) {
      if (state.enablePullUp) {
        _refreshController.loadComplete();
      } else {
        _refreshController.loadNoData();
      }
    }).catchError((_) => _refreshController.loadFailed());
  }
}
