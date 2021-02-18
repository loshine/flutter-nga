import 'package:dio/dio.dart';
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
  void addSubscription(int fid, int parentId) {
    Data().forumRepository.addChildForumSubscription(fid, parentId).then((s) {
      Fluttertoast.showToast(msg: "订阅成功");
      subscribed = true;
    }).catchError((e) {
      if (e is DioError) {
        Fluttertoast.showToast(msg: e.message, gravity: ToastGravity.CENTER);
      } else {
        Fluttertoast.showToast(msg: e.toString(), gravity: ToastGravity.CENTER);
      }
    });
  }

  @action
  void deleteSubscription(int fid, int parentId) {
    Data()
        .forumRepository
        .deleteChildForumSubscription(fid, parentId)
        .then((s) {
      Fluttertoast.showToast(msg: "取消订阅成功");
      subscribed = false;
    }).catchError((e) {
      if (e is DioError) {
        Fluttertoast.showToast(msg: e.message, gravity: ToastGravity.CENTER);
      } else {
        Fluttertoast.showToast(msg: e.toString(), gravity: ToastGravity.CENTER);
      }
    });
  }
}
