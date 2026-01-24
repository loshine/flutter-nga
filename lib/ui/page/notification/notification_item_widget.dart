import 'package:flutter/material.dart';
import 'package:flutter_nga/data/entity/notification.dart';
import 'package:flutter_nga/utils/dimen.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ReplyNotificationItemWidget extends StatelessWidget {
  final ReplyNotification notification;

  const ReplyNotificationItemWidget({Key? key, required this.notification})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: _onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                notification.getNotificationMessage(),
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
            ),
          ),
        ),
        Divider(
          height: 1,
          thickness: 1,
          color: colorScheme.surfaceContainerHighest,
        ),
      ],
    );
  }

  _onTap() {
    // TODO: 实现具体的跳转逻辑，目前保留原有 Toast 提示
    Fluttertoast.showToast(msg: notification.getNotificationMessage());
  }
}

class SystemNotificationItemWidget extends StatelessWidget {
  final SystemNotification notification;

  const SystemNotificationItemWidget({Key? key, required this.notification})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: _onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                notification.getNotificationMessage(),
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
            ),
          ),
        ),
        Divider(
          height: 1,
          thickness: 1,
          color: colorScheme.surfaceContainerHighest,
        ),
      ],
    );
  }

  _onTap() {
    // TODO: 实现具体的跳转逻辑，目前保留原有 Toast 提示
    Fluttertoast.showToast(msg: notification.getNotificationMessage());
  }
}
