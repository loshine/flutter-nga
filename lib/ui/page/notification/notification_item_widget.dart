import 'package:flutter/material.dart';
import 'package:flutter_nga/data/entity/notification.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ReplyNotificationItemWidget extends StatelessWidget {
  final ReplyNotification notification;

  const ReplyNotificationItemWidget({Key? key, required this.notification})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _onTap,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            child: Text(notification.getNotificationMessage()),
          ),
          Divider(height: 1),
        ],
      ),
    );
  }

  _onTap() {
    if (notification.type == SystemNotification.TYPE_SELF_KEYWORD) {
      Fluttertoast.showToast(msg: notification.toString());
    } else {
      Fluttertoast.showToast(msg: notification.toString());
    }
  }
}

class SystemNotificationItemWidget extends StatelessWidget {
  final SystemNotification notification;

  const SystemNotificationItemWidget({Key? key, required this.notification})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _onTap,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            child: Text(notification.getNotificationMessage()),
          ),
          Divider(height: 1),
        ],
      ),
    );
  }

  _onTap() {
    if (notification.type == SystemNotification.TYPE_SELF_KEYWORD) {
      Fluttertoast.showToast(msg: notification.toString());
    } else {
      Fluttertoast.showToast(msg: notification.toString());
    }
  }
}
