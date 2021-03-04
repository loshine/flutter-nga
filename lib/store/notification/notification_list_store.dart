import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/data/entity/notification.dart';
import 'package:mobx/mobx.dart';

part 'notification_list_store.g.dart';

class NotificationListStore = _NotificationListStore
    with _$NotificationListStore;

abstract class _NotificationListStore with Store {
  @observable
  NotificationInfoListData state = NotificationInfoListData(
    replyNotificationList: [],
    messageNotificationList: [],
    systemNotificationList: [],
    unread: 0,
  );

  int get count =>
      3 +
      state.replyNotificationList.length +
      state.messageNotificationList.length +
      state.systemNotificationList.length;

  @action
  Future<NotificationInfoListData> refresh() async {
    try {
      return Data()
          .messageRepository
          .getNotificationList()
          .then((v) => state = v);
    } catch (err) {
      rethrow;
    }
  }
}
