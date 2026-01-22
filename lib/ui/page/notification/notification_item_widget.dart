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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Card(
        elevation: 0,
        color: colorScheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimen.radiusM),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: _onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              notification.getNotificationMessage(),
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
          ),
        ),
      ),
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Card(
        elevation: 0,
        color: colorScheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimen.radiusM),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: _onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              notification.getNotificationMessage(),
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
          ),
        ),
      ),
    );
  }

  _onTap() {
    // TODO: 实现具体的跳转逻辑，目前保留原有 Toast 提示
    Fluttertoast.showToast(msg: notification.getNotificationMessage());
  }
}