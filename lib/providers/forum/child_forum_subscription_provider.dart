import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/utils/app_toast.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Family key for child-forum subscription state.
///
/// Equality is by [tid] only so list items stay isolated, while
/// [initialSelected] is used solely when the notifier is first created.
class ChildForumSubscriptionKey {
  const ChildForumSubscriptionKey(this.tid, {this.initialSelected = false});

  final int tid;
  final bool initialSelected;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChildForumSubscriptionKey && other.tid == tid;

  @override
  int get hashCode => tid.hashCode;
}

class ChildForumSubscriptionNotifier extends Notifier<bool> {
  ChildForumSubscriptionNotifier(this.key);

  final ChildForumSubscriptionKey key;

  @override
  bool build() => key.initialSelected;

  void setSubscribed(bool subscribed) {
    state = subscribed;
  }

  void addSubscription(int? parentId) {
    Data()
        .forumRepository
        .addChildForumSubscription(key.tid, parentId)
        .then((_) {
      AppToast.success("订阅成功");
      state = true;
    }).catchError((e) {
      AppToast.error(e.message);
    });
  }

  void deleteSubscription(int? parentId) {
    Data()
        .forumRepository
        .deleteChildForumSubscription(key.tid, parentId)
        .then((_) {
      AppToast.success("取消订阅成功");
      state = false;
    }).catchError((e) {
      AppToast.error(e.message);
    });
  }
}

final childForumSubscriptionProvider = NotifierProvider.family<
    ChildForumSubscriptionNotifier, bool, ChildForumSubscriptionKey>(
  ChildForumSubscriptionNotifier.new,
);
