import 'package:flutter_nga/data/data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ChildForumSubscriptionNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void setSubscribed(bool subscribed) {
    state = subscribed;
  }

  void addSubscription(int fid, int? parentId) {
    Data().forumRepository.addChildForumSubscription(fid, parentId).then((s) {
      Fluttertoast.showToast(msg: "订阅成功");
      state = true;
    }).catchError((e) {
      Fluttertoast.showToast(msg: e.message);
    });
  }

  void deleteSubscription(int fid, int? parentId) {
    Data()
        .forumRepository
        .deleteChildForumSubscription(fid, parentId)
        .then((s) {
      Fluttertoast.showToast(msg: "取消订阅成功");
      state = false;
    }).catchError((e) {
      Fluttertoast.showToast(msg: e.message);
    });
  }
}

final childForumSubscriptionProvider =
    NotifierProvider<ChildForumSubscriptionNotifier, bool>(ChildForumSubscriptionNotifier.new);
