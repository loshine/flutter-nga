import 'package:flutter/material.dart';
import 'package:flutter_nga/data/entity/notification.dart';
import 'package:flutter_nga/utils/code_utils.dart' as codeUtils;
import 'package:fluttertoast/fluttertoast.dart';

class SystemNotificationItemWidget extends StatelessWidget {
  final SystemNotification? notification;

  const SystemNotificationItemWidget({Key? key, this.notification})
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
            child: Text(_getSubject()),
          ),
          Divider(height: 1),
        ],
      ),
    );
  }

  String _getSubject() {
    if (notification!.type == SystemNotification.TYPE_SELF_KEYWORD) {
      // pid 是跳转或查询的 reply id
      // 今天 12:55 FID:-3355501中的发帖触发了关键词监视 查看详细信息
      return "${codeUtils.formatPostDate(notification!.time! * 1000)} FID:${notification!.tid}中的发帖触发了关键词监视";
    } else {
      return "test";
    }
  }

  _onTap() {
    if (notification!.type == SystemNotification.TYPE_SELF_KEYWORD) {
      Fluttertoast.showToast(msg: notification.toString());
    } else {
      Fluttertoast.showToast(msg: notification.toString());
    }
  }
}
