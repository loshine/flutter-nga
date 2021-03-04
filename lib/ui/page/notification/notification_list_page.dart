import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_nga/store/notification/notification_list_store.dart';
import 'package:flutter_nga/utils/dimen.dart';
import 'package:flutter_nga/utils/palette.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'notification_item_widget.dart';

class NotificationListPage extends StatefulWidget {
  @override
  _NotificationListState createState() => _NotificationListState();
}

class _NotificationListState extends State<NotificationListPage> {
  final _store = NotificationListStore();
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
          controller: _refreshController,
          enablePullUp: false,
          onRefresh: _onRefresh,
          child: ListView.builder(
            itemCount: _store.count,
            itemBuilder: _itemBuilder,
            physics: BouncingScrollPhysics(),
          ),
        );
      },
    );
  }

  _onRefresh() {
    _store.refresh().catchError((err) {
      _refreshController.refreshFailed();
      Fluttertoast.showToast(
        msg: err.toString(),
        gravity: ToastGravity.CENTER,
      );
    }).whenComplete(
        () => _refreshController.refreshCompleted(resetFooterState: true));
  }

  Widget _itemBuilder(BuildContext context, int index) {
    if (index == 0) {
      return _titleBuilder('回复通知');
    } else if (index < _store.state.replyNotificationList.length + 1) {
      return Text('233');
    } else if (index == _store.state.replyNotificationList.length + 1) {
      return _titleBuilder('消息通知');
    } else if (index <
        _store.state.replyNotificationList.length +
            _store.state.messageNotificationList.length +
            2) {
      return Text('111');
    } else if (index ==
        _store.state.replyNotificationList.length +
            _store.state.messageNotificationList.length +
            2) {
      return _titleBuilder('系统通知');
    } else {
      return SystemNotificationItemWidget(
          notification: _store.state.systemNotificationList[index -
              _store.state.replyNotificationList.length -
              _store.state.messageNotificationList.length -
              3]);
    }
  }

  Widget _titleBuilder(String name) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Text(
        ":: $name ::",
        style: TextStyle(
          fontSize: Dimen.subheading,
          color: Palette.colorTextSubTitle,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
