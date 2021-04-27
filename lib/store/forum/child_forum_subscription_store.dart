import 'package:flutter_nga/data/data.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mobx/mobx.dart';

part 'child_forum_subscription_store.g.dart';

class ChildForumSubscriptionStore = _ChildForumSubscriptionStore
    with _$ChildForumSubscriptionStore;

abstract class _ChildForumSubscriptionStore with Store {
  @observable
  bool subscribed = false;

  @action
  void setSubscribed(bool subscribed) {
    this.subscribed = subscribed;
  }

  @action
  void addSubscription(int fid, int? parentId) {
    Data().forumRepository.addChildForumSubscription(fid, parentId).then((s) {
      Fluttertoast.showToast(msg: "订阅成功");
      subscribed = true;
    }).catchError((e) {
      Fluttertoast.showToast(msg: e.toString());
    });
  }

  @action
  void deleteSubscription(int fid, int? parentId) {
    Data()
        .forumRepository
        .deleteChildForumSubscription(fid, parentId)
        .then((s) {
      Fluttertoast.showToast(msg: "取消订阅成功");
      subscribed = false;
    }).catchError((e) {
      Fluttertoast.showToast(msg: e.toString());
    });
  }
}
