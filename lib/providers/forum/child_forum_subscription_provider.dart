import 'package:flutter_nga/data/data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_nga/utils/app_toast.dart';

class ChildForumSubscriptionNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void setSubscribed(bool subscribed) {
    state = subscribed;
  }

  void addSubscription(int fid, int? parentId) {
    Data().forumRepository.addChildForumSubscription(fid, parentId).then((s) {
      AppToast.success("订阅成功");
      state = true;
    }).catchError((e) {
      AppToast.error(e.message);
    });
  }

  void deleteSubscription(int fid, int? parentId) {
    Data()
        .forumRepository
        .deleteChildForumSubscription(fid, parentId)
        .then((s) {
      AppToast.success("取消订阅成功");
      state = false;
    }).catchError((e) {
      AppToast.error(e.message);
    });
  }
}

final childForumSubscriptionProvider =
    NotifierProvider<ChildForumSubscriptionNotifier, bool>(
        ChildForumSubscriptionNotifier.new);
